from django.db import transaction
from django.db.models import Q
from django.utils import timezone
from rest_framework import generics, status
from rest_framework.exceptions import PermissionDenied, ValidationError
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.throttling import UserRateThrottle
from rest_framework.views import APIView

from apps.accounts.models import UserRole
from apps.common.mixins import ProfileAccessMixin
from apps.enrollments.models import Enrollment, EnrollmentStatus
from apps.enrollments.serializers import EnrollmentSerializer
from apps.loyalty.models import LoyaltyProgram
from apps.rewards.models import RedemptionStatus, RewardRedemption
from apps.transactions.models import StampTransaction, StampTransactionType
from apps.transactions.serializers import StampHistoryItemSerializer


class EnrollmentBaseMixin(ProfileAccessMixin):
	serializer_class = EnrollmentSerializer
	permission_classes = [IsAuthenticated]

	def _owned_by_customer(self, enrollment):
		return enrollment.customer.user_id == self.request.user.id

	def _owned_by_merchant(self, enrollment):
		return enrollment.loyalty_program.shop.merchant.user_id == self.request.user.id

	def _can_redeem(self, enrollment):
		return self._can_access_enrollment(enrollment)

	def _can_access_enrollment(self, enrollment):
		user = self.request.user
		if user.role == UserRole.CUSTOMER:
			return self._owned_by_customer(enrollment)
		if user.role == UserRole.MERCHANT:
			return self._owned_by_merchant(enrollment)
		return False

	def _is_redeemed(self, enrollment):
		return enrollment.redemptions.filter(status=RedemptionStatus.FULFILLED).exists()

	def _active_program_for_shop(self, shop_id):
		program = (
			LoyaltyProgram.objects.select_related("shop")
			.filter(
				shop_id=shop_id,
				is_active=True,
				shop__is_active=True,
			)
			.order_by("-updated_at", "-id")
			.first()
		)
		if program is None:
			raise ValidationError(
				{"shop_id": "No active loyalty program found for this shop."}
			)
		return program


class EnrollmentListCreateView(EnrollmentBaseMixin, generics.ListCreateAPIView):
	"""
	GET /api/v1/enrollments/
	POST /api/v1/enrollments/

	- Customer GET: returns own enrollments.
	- Merchant GET: requires shop_id query param and returns enrollments for owned shop.
	- Customer POST: creates enrollment using shop_id payload.
	"""

	def get_queryset(self):
		user = self.request.user
		queryset = Enrollment.objects.select_related(
			"customer__user",
			"loyalty_program__shop",
			"loyalty_program__shop__merchant",
		).prefetch_related("redemptions")

		if user.role == UserRole.CUSTOMER:
			customer = self._customer_profile_for_user(user)
			return (
				queryset.filter(customer=customer)
				.exclude(status=EnrollmentStatus.CANCELED)
				.order_by("-updated_at", "-id")
			)

		if user.role == UserRole.MERCHANT:
			shop_id = self.request.query_params.get("shop_id")
			if shop_id in (None, ""):
				raise ValidationError(
					{"shop_id": "Query parameter 'shop_id' is required for merchant access."}
				)

			merchant = self._merchant_profile_for_user(user)
			qs = (
				queryset.filter(
					loyalty_program__shop_id=shop_id,
					loyalty_program__shop__merchant=merchant,
				)
				.exclude(status=EnrollmentStatus.CANCELED)
				.order_by("-updated_at", "-id")
			)

			search = self.request.query_params.get("search", "").strip()
			if search:
				qs = qs.filter(
					Q(customer__user__name__icontains=search)
					| Q(customer__user__email__icontains=search)
				)
			return qs

		raise PermissionDenied("Unsupported user role.")

	def create(self, request, *args, **kwargs):
		user = request.user
		if user.role != UserRole.CUSTOMER:
			raise PermissionDenied("Only customers can create enrollments.")

		loyalty_program_id = request.data.get("loyalty_program_id")
		shop_id = request.data.get("shop_id")

		if loyalty_program_id not in (None, ""):
			try:
				program = (
					LoyaltyProgram.objects.select_related("shop")
					.get(id=loyalty_program_id, is_active=True, shop__is_active=True)
				)
			except LoyaltyProgram.DoesNotExist:
				raise ValidationError(
					{"loyalty_program_id": "No active loyalty program found with this id."}
				)
		elif shop_id not in (None, ""):
			program = self._active_program_for_shop(shop_id)
		else:
			raise ValidationError({"shop_id": "Either 'shop_id' or 'loyalty_program_id' is required."})

		customer = self._customer_profile_for_user(user)

		enrollment, created = Enrollment.objects.get_or_create(
			customer=customer,
			loyalty_program=program,
			defaults={
				"status": EnrollmentStatus.ACTIVE,
				"last_activity_at": timezone.now(),
			},
		)

		if not created and enrollment.status == EnrollmentStatus.CANCELED:
			enrollment.status = EnrollmentStatus.ACTIVE
			enrollment.last_activity_at = timezone.now()
			enrollment.save(update_fields=["status", "last_activity_at", "updated_at"])

		serializer = self.get_serializer(enrollment)
		return Response(
			serializer.data,
			status=status.HTTP_201_CREATED if created else status.HTTP_200_OK,
		)


class EnrollmentDetailView(EnrollmentBaseMixin, generics.RetrieveDestroyAPIView):
	"""
	GET /api/v1/enrollments/{id}/
	DELETE /api/v1/enrollments/{id}/
	"""

	lookup_field = "id"

	def get_queryset(self):
		queryset = Enrollment.objects.select_related(
			"customer__user",
			"loyalty_program__shop",
			"loyalty_program__shop__merchant",
		).prefetch_related("redemptions")

		user = self.request.user
		if user.role == UserRole.CUSTOMER:
			customer = self._customer_profile_for_user(user)
			return queryset.filter(customer=customer)
		if user.role == UserRole.MERCHANT:
			merchant = self._merchant_profile_for_user(user)
			return queryset.filter(loyalty_program__shop__merchant=merchant)

		raise PermissionDenied("Unsupported user role.")

	def destroy(self, request, *args, **kwargs):
		enrollment = self.get_object()
		if request.user.role != UserRole.CUSTOMER or not self._owned_by_customer(enrollment):
			raise PermissionDenied("Only the enrolled customer can cancel this enrollment.")

		if enrollment.status != EnrollmentStatus.CANCELED:
			enrollment.status = EnrollmentStatus.CANCELED
			enrollment.last_activity_at = timezone.now()
			enrollment.save(update_fields=["status", "last_activity_at", "updated_at"])

		return Response(status=status.HTTP_204_NO_CONTENT)


class StampGrantThrottle(UserRateThrottle):
	scope = "stamp_grant"


class EnrollmentStampCreateView(EnrollmentBaseMixin, APIView):
	"""
	POST /api/v1/enrollments/{id}/stamps/

	Merchant-only action to add stamps for an enrollment.
	"""

	permission_classes = [IsAuthenticated]
	throttle_classes = [StampGrantThrottle]

	def post(self, request, id):
		if request.user.role != UserRole.MERCHANT:
			raise PermissionDenied("Only merchants can add stamps.")

		with transaction.atomic():
			enrollment = generics.get_object_or_404(
				Enrollment.objects.select_for_update()
				.select_related(
					"customer__user",
					"loyalty_program__shop",
					"loyalty_program__shop__merchant",
				)
				.prefetch_related("redemptions"),
				id=id,
			)

			if not self._owned_by_merchant(enrollment):
				raise PermissionDenied("You can only stamp enrollments for your own shop.")

			if enrollment.status == EnrollmentStatus.CANCELED:
				raise ValidationError({"detail": "Canceled enrollments cannot receive stamps."})

			if self._is_redeemed(enrollment):
				raise ValidationError({"detail": "Reward already redeemed for this enrollment."})

			quantity = request.data.get("quantity", 1)
			try:
				quantity = int(quantity)
			except (TypeError, ValueError) as exc:
				raise ValidationError({"quantity": "Quantity must be an integer."}) from exc

			if quantity <= 0:
				raise ValidationError({"quantity": "Quantity must be greater than 0."})

			# Idempotency: if a key is provided, skip if already processed
			idempotency_key = (request.data.get("idempotency_key") or "").strip()

			if idempotency_key and StampTransaction.objects.filter(
				enrollment=enrollment,
				idempotency_key=idempotency_key,
			).exists():
				serializer = EnrollmentSerializer(enrollment)
				return Response(serializer.data, status=status.HTTP_200_OK)

			enrollment.stamps_count += quantity
			required = int(enrollment.loyalty_program.stamps_required)
			enrollment.status = (
				EnrollmentStatus.COMPLETED
				if enrollment.stamps_count >= required
				else EnrollmentStatus.ACTIVE
			)
			enrollment.last_activity_at = timezone.now()
			enrollment.save(update_fields=["stamps_count", "status", "last_activity_at", "updated_at"])

			StampTransaction.objects.create(
				enrollment=enrollment,
				performed_by=request.user,
				transaction_type=StampTransactionType.EARN,
				quantity=quantity,
				reference="merchant_scan",
				notes=(request.data.get("note") or "").strip(),
				idempotency_key=idempotency_key,
			)

			# Notify customer
			shop_name = enrollment.loyalty_program.shop.name
			new_count = enrollment.stamps_count
			if enrollment.status == EnrollmentStatus.COMPLETED:
				notif_title = f"🎉 Carte complète chez {shop_name}!"
				notif_body = f"Vous avez collecté {new_count}/{required} timbres. Demandez votre récompense!"
			else:
				notif_title = f"Timbre ajouté chez {shop_name}"
				notif_body = f"{new_count}/{required} timbres collectés. Continuez!"
			from apps.notifications.models import Notification, NotificationChannel
			Notification.objects.create(
				recipient=enrollment.customer.user,
				title=notif_title,
				body=notif_body,
				channel=NotificationChannel.IN_APP,
				payload={"enrollment_id": str(enrollment.id), "shop_id": str(enrollment.loyalty_program.shop_id)},
			)

		serializer = EnrollmentSerializer(enrollment)
		return Response(serializer.data, status=status.HTTP_200_OK)


class EnrollmentRedeemView(EnrollmentBaseMixin, APIView):
	"""
	POST /api/v1/enrollments/{id}/redeem/

	Allows customer owner or merchant owner to fulfill reward redemption.
	"""

	permission_classes = [IsAuthenticated]

	def post(self, request, id):
		with transaction.atomic():
			enrollment = generics.get_object_or_404(
				Enrollment.objects.select_for_update()
				.select_related(
					"customer__user",
					"loyalty_program__shop",
					"loyalty_program__shop__merchant",
				)
				.prefetch_related("redemptions"),
				id=id,
			)

			if not self._can_redeem(enrollment):
				raise PermissionDenied("You cannot redeem this enrollment.")

			if self._is_redeemed(enrollment):
				raise ValidationError({"detail": "Reward already redeemed."})

			required = int(enrollment.loyalty_program.stamps_required)
			if int(enrollment.stamps_count) < required:
				raise ValidationError({"detail": "Not enough stamps to redeem reward."})

			RewardRedemption.objects.create(
				enrollment=enrollment,
				reward_label=enrollment.loyalty_program.reward_label,
				status=RedemptionStatus.FULFILLED,
				approved_by=request.user if request.user.role == UserRole.MERCHANT else None,
				redeemed_at=timezone.now(),
			)

			enrollment.status = EnrollmentStatus.COMPLETED
			enrollment.last_activity_at = timezone.now()
			enrollment.save(update_fields=["status", "last_activity_at", "updated_at"])

		serializer = EnrollmentSerializer(enrollment)
		return Response(serializer.data, status=status.HTTP_200_OK)


class EnrollmentStampHistoryView(EnrollmentBaseMixin, APIView):
	"""
	GET /api/v1/enrollments/{id}/history/

	Returns stamp collection history for the enrollment owner or shop owner.
	"""

	permission_classes = [IsAuthenticated]

	def get(self, request, id):
		enrollment = generics.get_object_or_404(
			Enrollment.objects.select_related(
				"customer__user",
				"loyalty_program__shop",
				"loyalty_program__shop__merchant",
			),
			id=id,
		)

		if not self._can_access_enrollment(enrollment):
			raise PermissionDenied("You cannot view this enrollment history.")

		history = (
			StampTransaction.objects.select_related("enrollment__loyalty_program__shop")
			.filter(enrollment=enrollment)
			.order_by("-created_at", "-id")
		)

		serializer = StampHistoryItemSerializer(history, many=True)
		return Response(serializer.data, status=status.HTTP_200_OK)

class EnrollmentScanView(EnrollmentBaseMixin, APIView):
	"""
	POST /api/v1/enrollments/scan/

	Merchant-only: resolve a QR token to an enrollment for the merchant's shop.
	Returns the enrollment data so the merchant can decide to stamp or redeem.
	"""

	permission_classes = [IsAuthenticated]

	def post(self, request):
		if request.user.role != UserRole.MERCHANT:
			raise PermissionDenied("Only merchants can resolve QR tokens.")

		qr_token = (request.data.get("qr_token") or "").strip()
		if not qr_token:
			raise ValidationError({"qr_token": "This field is required."})

		try:
			import uuid as _uuid
			parsed_token = _uuid.UUID(qr_token)
		except ValueError:
			raise ValidationError({"qr_token": "Invalid QR token format."})

		merchant = self._merchant_profile_for_user(request.user)
		try:
			enrollment = (
				Enrollment.objects.select_related(
					"customer__user",
					"loyalty_program__shop",
					"loyalty_program__shop__merchant",
				)
				.prefetch_related("redemptions")
				.get(qr_token=parsed_token)
			)
		except Enrollment.DoesNotExist:
			raise ValidationError({"qr_token": "No enrollment found for this QR code."})

		if not self._owned_by_merchant(enrollment):
			raise PermissionDenied("This enrollment does not belong to your shop.")

		if enrollment.status == EnrollmentStatus.CANCELED:
			raise ValidationError({"detail": "This enrollment has been canceled."})

		serializer = EnrollmentSerializer(enrollment)
		return Response(serializer.data, status=status.HTTP_200_OK)
