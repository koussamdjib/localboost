from django.db import transaction
from django.utils import timezone
from rest_framework import generics, status
from rest_framework.exceptions import PermissionDenied, ValidationError
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.accounts.models import UserRole
from apps.common.mixins import ProfileAccessMixin
from apps.enrollments.models import Enrollment, EnrollmentStatus
from apps.rewards.models import RedemptionStatus, RewardRedemption
from apps.rewards.serializers import (
    RewardRequestCreateSerializer,
    RewardRedemptionSerializer,
)


class RewardRedemptionBaseMixin(ProfileAccessMixin):
    permission_classes = [IsAuthenticated]
    serializer_class = RewardRedemptionSerializer

    def _queryset(self):
        return RewardRedemption.objects.select_related(
            "enrollment",
            "enrollment__customer",
            "enrollment__customer__user",
            "enrollment__loyalty_program",
            "enrollment__loyalty_program__shop",
            "enrollment__loyalty_program__shop__merchant",
            "approved_by",
        )

    def _customer_scoped_queryset(self, customer_profile):
        return self._queryset().filter(enrollment__customer=customer_profile)

    def _merchant_scoped_queryset(self, merchant_profile):
        return self._queryset().filter(
            enrollment__loyalty_program__shop__merchant=merchant_profile
        )

    def _merchant_reward_request_for_update(self, merchant_profile, request_id):
        return generics.get_object_or_404(
            self._merchant_scoped_queryset(merchant_profile).select_for_update(),
            id=request_id,
        )

    def _apply_optional_filters(self, queryset):
        status_filter = (self.request.query_params.get("status") or "").strip().lower()
        if status_filter:
            valid_values = {choice[0] for choice in RedemptionStatus.choices}
            if status_filter not in valid_values:
                raise ValidationError({"status": "Invalid status value."})
            queryset = queryset.filter(status=status_filter)

        shop_id = self.request.query_params.get("shop_id")
        if shop_id not in (None, ""):
            queryset = queryset.filter(enrollment__loyalty_program__shop_id=shop_id)

        enrollment_id = self.request.query_params.get("enrollment_id") or self.request.query_params.get("enrollmentId")
        if enrollment_id not in (None, ""):
            queryset = queryset.filter(enrollment_id=enrollment_id)

        return queryset

    def _active_request_exists(self, enrollment):
        return enrollment.redemptions.filter(
            status__in=[RedemptionStatus.REQUESTED, RedemptionStatus.APPROVED]
        ).exists()

    def _fulfilled_exists(self, enrollment):
        return enrollment.redemptions.filter(status=RedemptionStatus.FULFILLED).exists()


class RewardRequestListCreateView(RewardRedemptionBaseMixin, APIView):
    """
    GET /api/v1/rewards/requests/
    POST /api/v1/rewards/requests/

    GET:
    - customer role: own reward request history
    - merchant role: requests for owned shops

    POST:
    - customer role only: create reward request (status=requested)
    """

    def get(self, request):
        user = request.user
        if user.role == UserRole.CUSTOMER:
            customer = self._customer_profile_for_user(user)
            queryset = self._customer_scoped_queryset(customer)
        elif user.role == UserRole.MERCHANT:
            merchant = self._merchant_profile_for_user(user)
            queryset = self._merchant_scoped_queryset(merchant)
        else:
            raise PermissionDenied("Unsupported user role.")

        queryset = self._apply_optional_filters(queryset).order_by("-created_at", "-id")
        serializer = self.serializer_class(queryset, many=True)
        return Response(serializer.data, status=status.HTTP_200_OK)

    def post(self, request):
        if request.user.role != UserRole.CUSTOMER:
            raise PermissionDenied("Only customers can request rewards.")

        customer = self._customer_profile_for_user(request.user)
        payload_serializer = RewardRequestCreateSerializer(data=request.data)
        payload_serializer.is_valid(raise_exception=True)

        enrollment_id = payload_serializer.validated_data["enrollment_id"]
        with transaction.atomic():
            enrollment = generics.get_object_or_404(
                Enrollment.objects.select_for_update()
                .select_related(
                    "customer",
                    "loyalty_program",
                    "loyalty_program__shop",
                )
                .prefetch_related("redemptions"),
                id=enrollment_id,
                customer=customer,
            )

            required_stamps = int(enrollment.loyalty_program.stamps_required)
            if int(enrollment.stamps_count) < required_stamps:
                raise ValidationError({"detail": "Not enough stamps to request reward."})

            if self._fulfilled_exists(enrollment):
                raise ValidationError({"detail": "Reward already fulfilled for this enrollment."})

            if self._active_request_exists(enrollment):
                raise ValidationError({"detail": "A reward request is already pending review."})

            reward_request = RewardRedemption.objects.create(
                enrollment=enrollment,
                reward_label=enrollment.loyalty_program.reward_label,
                status=RedemptionStatus.REQUESTED,
            )

            enrollment.status = EnrollmentStatus.COMPLETED
            enrollment.last_activity_at = timezone.now()
            enrollment.save(update_fields=["status", "last_activity_at", "updated_at"])

        serializer = self.serializer_class(reward_request)
        return Response(serializer.data, status=status.HTTP_201_CREATED)


class RewardRequestDetailView(RewardRedemptionBaseMixin, generics.RetrieveAPIView):
    """
    GET /api/v1/rewards/requests/{id}/
    """

    lookup_field = "id"

    def get_queryset(self):
        user = self.request.user
        if user.role == UserRole.CUSTOMER:
            customer = self._customer_profile_for_user(user)
            return self._customer_scoped_queryset(customer)
        if user.role == UserRole.MERCHANT:
            merchant = self._merchant_profile_for_user(user)
            return self._merchant_scoped_queryset(merchant)
        raise PermissionDenied("Unsupported user role.")


class RewardRequestApproveView(RewardRedemptionBaseMixin, APIView):
    """
    POST /api/v1/rewards/requests/{id}/approve/

    Merchant owner only.
    requested -> approved
    """

    def post(self, request, id):
        if request.user.role != UserRole.MERCHANT:
            raise PermissionDenied("Only merchants can approve reward requests.")

        merchant = self._merchant_profile_for_user(request.user)
        with transaction.atomic():
            reward_request = self._merchant_reward_request_for_update(merchant, id)

            if reward_request.status != RedemptionStatus.REQUESTED:
                raise ValidationError(
                    {"detail": "Only requested rewards can be approved."}
                )

            reward_request.status = RedemptionStatus.APPROVED
            reward_request.approved_by = request.user
            reward_request.save(update_fields=["status", "approved_by", "updated_at"])

        serializer = self.serializer_class(reward_request)
        return Response(serializer.data, status=status.HTTP_200_OK)


class RewardRequestRejectView(RewardRedemptionBaseMixin, APIView):
    """
    POST /api/v1/rewards/requests/{id}/reject/

    Merchant owner only.
    requested/approved -> rejected
    """

    def post(self, request, id):
        if request.user.role != UserRole.MERCHANT:
            raise PermissionDenied("Only merchants can reject reward requests.")

        merchant = self._merchant_profile_for_user(request.user)
        with transaction.atomic():
            reward_request = self._merchant_reward_request_for_update(merchant, id)

            if reward_request.status not in [
                RedemptionStatus.REQUESTED,
                RedemptionStatus.APPROVED,
            ]:
                raise ValidationError(
                    {"detail": "Only requested or approved rewards can be rejected."}
                )

            reward_request.status = RedemptionStatus.REJECTED
            reward_request.approved_by = request.user
            reward_request.save(update_fields=["status", "approved_by", "updated_at"])

        serializer = self.serializer_class(reward_request)
        return Response(serializer.data, status=status.HTTP_200_OK)


class RewardRequestFulfillView(RewardRedemptionBaseMixin, APIView):
    """
    POST /api/v1/rewards/requests/{id}/fulfill/

    Merchant owner only.
    approved -> fulfilled
    """

    def post(self, request, id):
        if request.user.role != UserRole.MERCHANT:
            raise PermissionDenied("Only merchants can fulfill reward requests.")

        merchant = self._merchant_profile_for_user(request.user)
        with transaction.atomic():
            reward_request = self._merchant_reward_request_for_update(merchant, id)

            if reward_request.status != RedemptionStatus.APPROVED:
                raise ValidationError(
                    {"detail": "Only approved rewards can be fulfilled."}
                )

            reward_request.status = RedemptionStatus.FULFILLED
            reward_request.redeemed_at = timezone.now()
            reward_request.approved_by = request.user
            reward_request.save(
                update_fields=["status", "redeemed_at", "approved_by", "updated_at"]
            )

            enrollment = Enrollment.objects.select_for_update().get(
                id=reward_request.enrollment_id
            )
            enrollment.status = EnrollmentStatus.COMPLETED
            enrollment.stamps_count = 0
            enrollment.last_activity_at = timezone.now()
            enrollment.save(update_fields=["status", "stamps_count", "last_activity_at", "updated_at"])

        serializer = self.serializer_class(reward_request)
        return Response(serializer.data, status=status.HTTP_200_OK)
