from rest_framework import generics
from rest_framework.exceptions import PermissionDenied
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from apps.accounts.models import UserRole
from apps.customers.models import CustomerProfile
from apps.rewards.models import RedemptionStatus, RewardRedemption
from apps.transactions.models import StampTransaction
from apps.transactions.serializers import TransactionHistoryItemSerializer


class TransactionHistoryListView(generics.GenericAPIView):
	"""
	GET /api/v1/transactions/

	Customer transaction timeline composed from:
	- enrollment creation events
	- stamp collection events
	- reward redemption events
	"""

	permission_classes = [IsAuthenticated]
	serializer_class = TransactionHistoryItemSerializer

	def _customer_profile(self):
		if self.request.user.role != UserRole.CUSTOMER:
			raise PermissionDenied("Only customers can view transaction history.")

		try:
			return self.request.user.customer_profile
		except CustomerProfile.DoesNotExist as exc:
			raise PermissionDenied("Customer profile is required.") from exc

	def _shop_location_label(self, shop):
		parts = [shop.city, shop.country]
		return ", ".join([part for part in parts if part])

	def get(self, request, *args, **kwargs):
		customer = self._customer_profile()

		events = []

		enrollments = (
			customer.enrollments.select_related("loyalty_program__shop")
			.exclude(status="canceled")
			.order_by("-created_at")
		)
		for enrollment in enrollments:
			shop = enrollment.loyalty_program.shop
			events.append(
				{
					"id": f"enrollment-{enrollment.id}",
					"user_id": str(customer.user_id),
					"shop_id": str(shop.id),
					"shop_name": shop.name,
					"shop_logo_url": shop.logo_url or "",
					"type": "enrolled",
					"timestamp": enrollment.created_at,
					"location": self._shop_location_label(shop),
				}
			)

		stamp_transactions = (
			StampTransaction.objects.select_related("enrollment__loyalty_program__shop")
			.filter(enrollment__customer=customer)
			.order_by("-created_at")
		)
		for item in stamp_transactions:
			shop = item.enrollment.loyalty_program.shop
			events.append(
				{
					"id": f"stamp-{item.id}",
					"user_id": str(customer.user_id),
					"shop_id": str(shop.id),
					"shop_name": shop.name,
					"shop_logo_url": shop.logo_url or "",
					"type": "stampCollected",
					"timestamp": item.created_at,
					"stamps_added": int(item.quantity),
					"merchant_note": item.notes or "",
					"location": self._shop_location_label(shop),
				}
			)

		redemptions = (
			RewardRedemption.objects.select_related("enrollment__loyalty_program__shop")
			.filter(
				enrollment__customer=customer,
				status=RedemptionStatus.FULFILLED,
			)
			.order_by("-redeemed_at", "-created_at")
		)
		for item in redemptions:
			shop = item.enrollment.loyalty_program.shop
			timestamp = item.redeemed_at or item.created_at
			events.append(
				{
					"id": f"redemption-{item.id}",
					"user_id": str(customer.user_id),
					"shop_id": str(shop.id),
					"shop_name": shop.name,
					"shop_logo_url": shop.logo_url or "",
					"type": "rewardRedeemed",
					"timestamp": timestamp,
					"reward_value": item.reward_label,
					"location": self._shop_location_label(shop),
				}
			)

		events.sort(key=lambda event: event["timestamp"], reverse=True)
		serializer = self.get_serializer(events, many=True)
		return Response(serializer.data)
