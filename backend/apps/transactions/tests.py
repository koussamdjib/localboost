from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework.test import APITestCase

from apps.customers.models import CustomerProfile
from apps.enrollments.models import Enrollment, EnrollmentStatus
from apps.loyalty.models import LoyaltyProgram
from apps.merchants.models import MerchantProfile, MerchantStatus
from apps.rewards.models import RedemptionStatus, RewardRedemption
from apps.shops.models import Shop, ShopStatus
from apps.transactions.models import StampTransaction, StampTransactionType

User = get_user_model()


class TransactionsApiTests(APITestCase):
	def setUp(self):
		self.merchant_user = User.objects.create_user(
			email="merchant.tx@localboost.test",
			username="merchant_tx",
			password="merchant-password-123",
			role="merchant",
		)
		self.merchant_profile = MerchantProfile.objects.create(
			user=self.merchant_user,
			business_name="Merchant Tx",
			status=MerchantStatus.ACTIVE,
		)

		self.customer_user = User.objects.create_user(
			email="customer.tx@localboost.test",
			username="customer_tx",
			password="customer-password-123",
			role="customer",
		)
		self.customer_profile = CustomerProfile.objects.create(user=self.customer_user)

		self.shop = Shop.objects.create(
			merchant=self.merchant_profile,
			name="Transactions Shop",
			slug="transactions-shop",
			category="retail",
			description="Shop for transaction tests.",
			address_line_1="Rue Tx",
			city="Djibouti",
			country="Djibouti",
			status=ShopStatus.ACTIVE,
			is_active=True,
		)

		self.program = LoyaltyProgram.objects.create(
			shop=self.shop,
			name="Tx Program",
			reward_label="Free Drink",
			stamps_required=5,
			is_active=True,
		)

		self.enrollment = Enrollment.objects.create(
			customer=self.customer_profile,
			loyalty_program=self.program,
			status=EnrollmentStatus.ACTIVE,
			stamps_count=2,
		)
		self.stamp = StampTransaction.objects.create(
			enrollment=self.enrollment,
			quantity=2,
			performed_by=self.merchant_user,
			transaction_type=StampTransactionType.EARN,
		)
		self.redemption = RewardRedemption.objects.create(
			enrollment=self.enrollment,
			reward_label=self.program.reward_label,
			status=RedemptionStatus.FULFILLED,
		)

	def authenticate(self, user):
		self.client.force_authenticate(user=user)

	def _extract_results(self, response):
		if isinstance(response.data, list):
			return response.data
		return response.data.get("results", response.data)

	def test_customer_gets_transaction_timeline(self):
		self.authenticate(self.customer_user)
		response = self.client.get(reverse("transaction-list"))

		self.assertEqual(response.status_code, 200)
		results = self._extract_results(response)
		event_types = {item["type"] for item in results}
		self.assertIn("enrolled", event_types)
		self.assertIn("stampCollected", event_types)
		self.assertIn("rewardRedeemed", event_types)

		for item in results:
			self.assertEqual(item["shop_id"], str(self.shop.id))
			self.assertEqual(item["shop_name"], self.shop.name)

	def test_merchant_cannot_access_customer_transaction_history_endpoint(self):
		self.authenticate(self.merchant_user)
		response = self.client.get(reverse("transaction-list"))
		self.assertEqual(response.status_code, 403)
