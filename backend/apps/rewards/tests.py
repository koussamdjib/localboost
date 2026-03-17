from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework.test import APITestCase

from apps.customers.models import CustomerProfile
from apps.enrollments.models import Enrollment, EnrollmentStatus
from apps.loyalty.models import LoyaltyProgram
from apps.merchants.models import MerchantProfile, MerchantStatus
from apps.rewards.models import RedemptionStatus, RewardRedemption
from apps.shops.models import Shop, ShopStatus

User = get_user_model()


class RewardLifecycleApiTests(APITestCase):
	"""Full lifecycle: requested -> approved -> fulfilled, with rejection path tested."""

	def setUp(self):
		self.merchant_user = User.objects.create_user(
			email="merchant.reward@localboost.test",
			username="merchant_reward",
			password="merchant-password-123",
			role="merchant",
		)
		self.merchant_profile = MerchantProfile.objects.create(
			user=self.merchant_user,
			business_name="Reward Merchant",
			status=MerchantStatus.ACTIVE,
		)

		self.other_merchant_user = User.objects.create_user(
			email="merchant.other.reward@localboost.test",
			username="merchant_other_reward",
			password="merchant-password-123",
			role="merchant",
		)
		self.other_merchant_profile = MerchantProfile.objects.create(
			user=self.other_merchant_user,
			business_name="Other Reward Merchant",
			status=MerchantStatus.ACTIVE,
		)

		self.customer_user = User.objects.create_user(
			email="customer.reward@localboost.test",
			username="customer_reward",
			password="customer-password-123",
			role="customer",
		)
		self.customer_profile = CustomerProfile.objects.create(user=self.customer_user)

		self.other_customer_user = User.objects.create_user(
			email="customer2.reward@localboost.test",
			username="customer2_reward",
			password="customer-password-123",
			role="customer",
		)
		self.other_customer_profile = CustomerProfile.objects.create(
			user=self.other_customer_user
		)

		self.shop = Shop.objects.create(
			merchant=self.merchant_profile,
			name="Reward Shop",
			slug="reward-shop",
			category="retail",
			description="Shop for reward lifecycle tests.",
			address_line_1="Rue Test",
			city="Djibouti",
			country="Djibouti",
			status=ShopStatus.ACTIVE,
			is_active=True,
		)

		self.program = LoyaltyProgram.objects.create(
			shop=self.shop,
			name="Free Coffee Program",
			reward_label="Free Coffee",
			stamps_required=3,
			is_active=True,
		)

		# Enrollment with enough stamps.
		self.enrollment = Enrollment.objects.create(
			customer=self.customer_profile,
			loyalty_program=self.program,
			status=EnrollmentStatus.COMPLETED,
			stamps_count=self.program.stamps_required,
		)

	def _auth(self, user):
		self.client.force_authenticate(user=user)

	# ---- POST /api/v1/rewards/requests/ ----

	def test_customer_can_request_reward_when_stamps_sufficient(self):
		self._auth(self.customer_user)
		response = self.client.post(
			reverse("reward-request-list-create"),
			data={"enrollment_id": self.enrollment.id},
			format="json",
		)
		self.assertEqual(response.status_code, 201)
		self.assertEqual(response.data["status"], RedemptionStatus.REQUESTED)
		self.assertEqual(response.data["enrollment_id"], self.enrollment.id)

	def test_customer_cannot_request_reward_without_enough_stamps(self):
		self._auth(self.customer_user)
		low_stamp_enrollment = Enrollment.objects.create(
			customer=self.customer_profile,
			loyalty_program=LoyaltyProgram.objects.create(
				shop=self.shop,
				name="Another Program",
				reward_label="Reward",
				stamps_required=5,
				is_active=True,
			),
			status=EnrollmentStatus.ACTIVE,
			stamps_count=2,
		)
		response = self.client.post(
			reverse("reward-request-list-create"),
			data={"enrollment_id": low_stamp_enrollment.id},
			format="json",
		)
		self.assertEqual(response.status_code, 400)

	def test_customer_cannot_request_reward_twice(self):
		self._auth(self.customer_user)
		# First request.
		r1 = self.client.post(
			reverse("reward-request-list-create"),
			data={"enrollment_id": self.enrollment.id},
			format="json",
		)
		self.assertEqual(r1.status_code, 201)

		# Second request blocked.
		r2 = self.client.post(
			reverse("reward-request-list-create"),
			data={"enrollment_id": self.enrollment.id},
			format="json",
		)
		self.assertEqual(r2.status_code, 400)

	def test_customer_cannot_request_reward_for_other_customer_enrollment(self):
		other_enrollment = Enrollment.objects.create(
			customer=self.other_customer_profile,
			loyalty_program=self.program,
			status=EnrollmentStatus.COMPLETED,
			stamps_count=self.program.stamps_required,
		)
		self._auth(self.customer_user)
		response = self.client.post(
			reverse("reward-request-list-create"),
			data={"enrollment_id": other_enrollment.id},
			format="json",
		)
		self.assertEqual(response.status_code, 404)

	def test_merchant_cannot_create_reward_request(self):
		self._auth(self.merchant_user)
		response = self.client.post(
			reverse("reward-request-list-create"),
			data={"enrollment_id": self.enrollment.id},
			format="json",
		)
		self.assertEqual(response.status_code, 403)

	# ---- GET /api/v1/rewards/requests/ ----

	def test_customer_can_list_own_reward_requests(self):
		RewardRedemption.objects.create(
			enrollment=self.enrollment,
			reward_label="Free Coffee",
			status=RedemptionStatus.REQUESTED,
		)
		self._auth(self.customer_user)
		response = self.client.get(reverse("reward-request-list-create"))
		self.assertEqual(response.status_code, 200)
		self.assertEqual(len(response.data), 1)
		self.assertEqual(response.data[0]["status"], RedemptionStatus.REQUESTED)

	def test_merchant_can_list_shop_reward_requests(self):
		RewardRedemption.objects.create(
			enrollment=self.enrollment,
			reward_label="Free Coffee",
			status=RedemptionStatus.REQUESTED,
		)
		self._auth(self.merchant_user)
		response = self.client.get(reverse("reward-request-list-create"))
		self.assertEqual(response.status_code, 200)
		self.assertEqual(len(response.data), 1)

	def test_merchant_cannot_see_other_shops_reward_requests(self):
		RewardRedemption.objects.create(
			enrollment=self.enrollment,
			reward_label="Free Coffee",
			status=RedemptionStatus.REQUESTED,
		)
		self._auth(self.other_merchant_user)
		response = self.client.get(reverse("reward-request-list-create"))
		self.assertEqual(response.status_code, 200)
		self.assertEqual(len(response.data), 0)

	# ---- POST /api/v1/rewards/requests/{id}/approve/ ----

	def test_merchant_can_approve_requested_reward(self):
		rr = RewardRedemption.objects.create(
			enrollment=self.enrollment,
			reward_label="Free Coffee",
			status=RedemptionStatus.REQUESTED,
		)
		self._auth(self.merchant_user)
		response = self.client.post(
			reverse("reward-request-approve", kwargs={"id": rr.id})
		)
		self.assertEqual(response.status_code, 200)
		self.assertEqual(response.data["status"], RedemptionStatus.APPROVED)
		rr.refresh_from_db()
		self.assertEqual(rr.status, RedemptionStatus.APPROVED)
		self.assertEqual(rr.approved_by, self.merchant_user)

	def test_customer_cannot_approve_reward_request(self):
		rr = RewardRedemption.objects.create(
			enrollment=self.enrollment,
			reward_label="Free Coffee",
			status=RedemptionStatus.REQUESTED,
		)
		self._auth(self.customer_user)
		response = self.client.post(
			reverse("reward-request-approve", kwargs={"id": rr.id})
		)
		self.assertEqual(response.status_code, 403)

	def test_other_merchant_cannot_approve_unowned_reward_request(self):
		rr = RewardRedemption.objects.create(
			enrollment=self.enrollment,
			reward_label="Free Coffee",
			status=RedemptionStatus.REQUESTED,
		)
		self._auth(self.other_merchant_user)
		response = self.client.post(
			reverse("reward-request-approve", kwargs={"id": rr.id})
		)
		self.assertEqual(response.status_code, 404)

	def test_merchant_cannot_approve_already_approved_reward(self):
		rr = RewardRedemption.objects.create(
			enrollment=self.enrollment,
			reward_label="Free Coffee",
			status=RedemptionStatus.APPROVED,
		)
		self._auth(self.merchant_user)
		response = self.client.post(
			reverse("reward-request-approve", kwargs={"id": rr.id})
		)
		self.assertEqual(response.status_code, 400)

	# ---- POST /api/v1/rewards/requests/{id}/reject/ ----

	def test_merchant_can_reject_requested_reward(self):
		rr = RewardRedemption.objects.create(
			enrollment=self.enrollment,
			reward_label="Free Coffee",
			status=RedemptionStatus.REQUESTED,
		)
		self._auth(self.merchant_user)
		response = self.client.post(
			reverse("reward-request-reject", kwargs={"id": rr.id})
		)
		self.assertEqual(response.status_code, 200)
		self.assertEqual(response.data["status"], RedemptionStatus.REJECTED)
		rr.refresh_from_db()
		self.assertEqual(rr.status, RedemptionStatus.REJECTED)

	def test_merchant_can_reject_approved_reward(self):
		rr = RewardRedemption.objects.create(
			enrollment=self.enrollment,
			reward_label="Free Coffee",
			status=RedemptionStatus.APPROVED,
		)
		self._auth(self.merchant_user)
		response = self.client.post(
			reverse("reward-request-reject", kwargs={"id": rr.id})
		)
		self.assertEqual(response.status_code, 200)
		self.assertEqual(response.data["status"], RedemptionStatus.REJECTED)

	def test_merchant_cannot_reject_fulfilled_reward(self):
		rr = RewardRedemption.objects.create(
			enrollment=self.enrollment,
			reward_label="Free Coffee",
			status=RedemptionStatus.FULFILLED,
		)
		self._auth(self.merchant_user)
		response = self.client.post(
			reverse("reward-request-reject", kwargs={"id": rr.id})
		)
		self.assertEqual(response.status_code, 400)

	# ---- POST /api/v1/rewards/requests/{id}/fulfill/ ----

	def test_merchant_can_fulfill_approved_reward(self):
		rr = RewardRedemption.objects.create(
			enrollment=self.enrollment,
			reward_label="Free Coffee",
			status=RedemptionStatus.APPROVED,
		)
		self._auth(self.merchant_user)
		response = self.client.post(
			reverse("reward-request-fulfill", kwargs={"id": rr.id})
		)
		self.assertEqual(response.status_code, 200)
		self.assertEqual(response.data["status"], RedemptionStatus.FULFILLED)
		rr.refresh_from_db()
		self.assertEqual(rr.status, RedemptionStatus.FULFILLED)
		self.assertIsNotNone(rr.redeemed_at)
		self.assertEqual(rr.approved_by, self.merchant_user)

	def test_merchant_cannot_fulfill_requested_reward(self):
		rr = RewardRedemption.objects.create(
			enrollment=self.enrollment,
			reward_label="Free Coffee",
			status=RedemptionStatus.REQUESTED,
		)
		self._auth(self.merchant_user)
		response = self.client.post(
			reverse("reward-request-fulfill", kwargs={"id": rr.id})
		)
		self.assertEqual(response.status_code, 400)

	def test_full_lifecycle_requested_approved_fulfilled(self):
		self._auth(self.customer_user)
		r1 = self.client.post(
			reverse("reward-request-list-create"),
			data={"enrollment_id": self.enrollment.id},
			format="json",
		)
		self.assertEqual(r1.status_code, 201)
		request_id = r1.data["id"]

		# Merchant approves.
		self._auth(self.merchant_user)
		r2 = self.client.post(
			reverse("reward-request-approve", kwargs={"id": request_id})
		)
		self.assertEqual(r2.status_code, 200)
		self.assertEqual(r2.data["status"], RedemptionStatus.APPROVED)

		# Merchant fulfills.
		r3 = self.client.post(
			reverse("reward-request-fulfill", kwargs={"id": request_id})
		)
		self.assertEqual(r3.status_code, 200)
		self.assertEqual(r3.data["status"], RedemptionStatus.FULFILLED)

		# Enrollment serializer now reflects is_redeemed=True.
		self._auth(self.customer_user)
		r4 = self.client.get(
			reverse("enrollment-detail", kwargs={"id": self.enrollment.id})
		)
		self.assertEqual(r4.status_code, 200)
		self.assertTrue(r4.data["is_redeemed"])
		self.assertEqual(r4.data["reward_status"], RedemptionStatus.FULFILLED)
		self.assertEqual(r4.data["reward_request_id"], request_id)

	def test_enrollment_serializer_exposes_reward_fields(self):
		rr = RewardRedemption.objects.create(
			enrollment=self.enrollment,
			reward_label="Free Coffee",
			status=RedemptionStatus.REQUESTED,
		)
		self._auth(self.customer_user)
		response = self.client.get(
			reverse("enrollment-detail", kwargs={"id": self.enrollment.id})
		)
		self.assertEqual(response.status_code, 200)
		self.assertEqual(response.data["reward_status"], RedemptionStatus.REQUESTED)
		self.assertEqual(response.data["reward_request_id"], rr.id)
		self.assertFalse(response.data["is_redeemed"])

	def test_unauthenticated_cannot_access_rewards_endpoint(self):
		response = self.client.get(reverse("reward-request-list-create"))
		self.assertEqual(response.status_code, 401)
