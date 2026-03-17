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


class EnrollmentApiTests(APITestCase):
	def setUp(self):
		self.merchant_user = User.objects.create_user(
			email="merchant.enroll@localboost.test",
			username="merchant_enroll",
			password="merchant-password-123",
			role="merchant",
		)
		self.merchant_profile = MerchantProfile.objects.create(
			user=self.merchant_user,
			business_name="Merchant Enrollment",
			status=MerchantStatus.ACTIVE,
		)

		self.other_merchant_user = User.objects.create_user(
			email="merchant.other@localboost.test",
			username="merchant_other_enroll",
			password="merchant-password-123",
			role="merchant",
		)
		self.other_merchant_profile = MerchantProfile.objects.create(
			user=self.other_merchant_user,
			business_name="Merchant Other Enrollment",
			status=MerchantStatus.ACTIVE,
		)

		self.customer_user = User.objects.create_user(
			email="customer.enroll@localboost.test",
			username="customer_enroll",
			password="customer-password-123",
			role="customer",
		)
		self.customer_profile = CustomerProfile.objects.create(user=self.customer_user)

		self.shop = Shop.objects.create(
			merchant=self.merchant_profile,
			name="Enroll Shop",
			slug="enroll-shop",
			category="retail",
			description="Shop for enrollment tests.",
			address_line_1="Rue 1",
			city="Djibouti",
			country="Djibouti",
			status=ShopStatus.ACTIVE,
			is_active=True,
		)

		self.other_shop = Shop.objects.create(
			merchant=self.other_merchant_profile,
			name="Other Enroll Shop",
			slug="other-enroll-shop",
			category="retail",
			description="Other merchant shop.",
			address_line_1="Rue 2",
			city="Djibouti",
			country="Djibouti",
			status=ShopStatus.ACTIVE,
			is_active=True,
		)

		self.program = LoyaltyProgram.objects.create(
			shop=self.shop,
			name="Loyalty Test",
			reward_label="Free Coffee",
			stamps_required=3,
			is_active=True,
		)
		self.other_program = LoyaltyProgram.objects.create(
			shop=self.other_shop,
			name="Loyalty Other",
			reward_label="Free Dessert",
			stamps_required=4,
			is_active=True,
		)

	def authenticate(self, user):
		self.client.force_authenticate(user=user)

	def _extract_results(self, response):
		return response.data.get("results", response.data)

	def test_customer_can_create_and_list_own_enrollments(self):
		self.authenticate(self.customer_user)

		create_response = self.client.post(
			reverse("enrollment-list-create"),
			data={"shop_id": self.shop.id},
			format="json",
		)

		self.assertEqual(create_response.status_code, 201)
		self.assertEqual(create_response.data["shop_id"], str(self.shop.id))
		self.assertEqual(create_response.data["stamps_required"], 3)

		list_response = self.client.get(reverse("enrollment-list-create"))
		self.assertEqual(list_response.status_code, 200)
		results = self._extract_results(list_response)
		self.assertEqual(len(results), 1)
		self.assertEqual(results[0]["shop_name"], self.shop.name)

	def test_customer_enroll_is_idempotent(self):
		self.authenticate(self.customer_user)

		first = self.client.post(
			reverse("enrollment-list-create"),
			data={"shop_id": self.shop.id},
			format="json",
		)
		self.assertEqual(first.status_code, 201)

		second = self.client.post(
			reverse("enrollment-list-create"),
			data={"shop_id": self.shop.id},
			format="json",
		)
		self.assertEqual(second.status_code, 200)
		self.assertEqual(first.data["id"], second.data["id"])

		self.assertEqual(
			Enrollment.objects.filter(
				customer=self.customer_profile,
				loyalty_program=self.program,
			).count(),
			1,
		)

	def test_customer_can_cancel_own_enrollment(self):
		enrollment = Enrollment.objects.create(
			customer=self.customer_profile,
			loyalty_program=self.program,
			status=EnrollmentStatus.ACTIVE,
		)

		self.authenticate(self.customer_user)
		response = self.client.delete(
			reverse("enrollment-detail", kwargs={"id": enrollment.id})
		)

		self.assertEqual(response.status_code, 204)
		enrollment.refresh_from_db()
		self.assertEqual(enrollment.status, EnrollmentStatus.CANCELED)

	def test_merchant_can_list_shop_enrollments_and_stamp(self):
		enrollment = Enrollment.objects.create(
			customer=self.customer_profile,
			loyalty_program=self.program,
			status=EnrollmentStatus.ACTIVE,
		)

		self.authenticate(self.merchant_user)

		list_response = self.client.get(
			reverse("enrollment-list-create"),
			data={"shop_id": self.shop.id},
		)
		self.assertEqual(list_response.status_code, 200)
		results = self._extract_results(list_response)
		self.assertEqual(len(results), 1)
		self.assertEqual(results[0]["id"], enrollment.id)

		stamp_response = self.client.post(
			reverse("enrollment-add-stamp", kwargs={"id": enrollment.id}),
			data={"quantity": 2, "user_id": str(self.customer_user.id)},
			format="json",
		)
		self.assertEqual(stamp_response.status_code, 200)
		self.assertEqual(stamp_response.data["stamps_collected"], 2)
		self.assertFalse(stamp_response.data["is_completed"])

		enrollment.refresh_from_db()
		self.assertEqual(enrollment.stamps_count, 2)
		self.assertEqual(StampTransaction.objects.filter(enrollment=enrollment).count(), 1)

	def test_non_owner_merchant_cannot_stamp_enrollment(self):
		enrollment = Enrollment.objects.create(
			customer=self.customer_profile,
			loyalty_program=self.program,
			status=EnrollmentStatus.ACTIVE,
		)

		self.authenticate(self.other_merchant_user)
		response = self.client.post(
			reverse("enrollment-add-stamp", kwargs={"id": enrollment.id}),
			data={"quantity": 1},
			format="json",
		)
		self.assertEqual(response.status_code, 403)

	def test_merchant_can_get_enrollment_stamp_history(self):
		enrollment = Enrollment.objects.create(
			customer=self.customer_profile,
			loyalty_program=self.program,
			status=EnrollmentStatus.ACTIVE,
		)
		StampTransaction.objects.create(
			enrollment=enrollment,
			performed_by=self.merchant_user,
			transaction_type=StampTransactionType.EARN,
			quantity=2,
			notes="Achat du midi",
		)

		self.authenticate(self.merchant_user)
		response = self.client.get(
			reverse("enrollment-history", kwargs={"id": enrollment.id})
		)

		self.assertEqual(response.status_code, 200)
		self.assertEqual(len(response.data), 1)
		self.assertEqual(response.data[0]["merchant_note"], "Achat du midi")
		self.assertEqual(response.data[0]["stamps_added"], 2)
		self.assertEqual(response.data[0]["location"], "Djibouti, Djibouti")

	def test_customer_can_get_own_enrollment_stamp_history(self):
		enrollment = Enrollment.objects.create(
			customer=self.customer_profile,
			loyalty_program=self.program,
			status=EnrollmentStatus.ACTIVE,
		)
		StampTransaction.objects.create(
			enrollment=enrollment,
			performed_by=self.merchant_user,
			transaction_type=StampTransactionType.EARN,
			quantity=1,
		)

		self.authenticate(self.customer_user)
		response = self.client.get(
			reverse("enrollment-history", kwargs={"id": enrollment.id})
		)

		self.assertEqual(response.status_code, 200)
		self.assertEqual(len(response.data), 1)
		self.assertEqual(response.data[0]["merchant_note"], "1 timbre ajouté")

	def test_non_owner_merchant_cannot_get_enrollment_stamp_history(self):
		enrollment = Enrollment.objects.create(
			customer=self.customer_profile,
			loyalty_program=self.program,
			status=EnrollmentStatus.ACTIVE,
		)

		self.authenticate(self.other_merchant_user)
		response = self.client.get(
			reverse("enrollment-history", kwargs={"id": enrollment.id})
		)

		self.assertEqual(response.status_code, 403)

	def test_customer_can_redeem_when_threshold_reached(self):
		enrollment = Enrollment.objects.create(
			customer=self.customer_profile,
			loyalty_program=self.program,
			status=EnrollmentStatus.COMPLETED,
			stamps_count=self.program.stamps_required,
		)

		self.authenticate(self.customer_user)
		response = self.client.post(
			reverse("enrollment-redeem", kwargs={"id": enrollment.id}),
			format="json",
		)

		self.assertEqual(response.status_code, 200)
		self.assertTrue(response.data["is_redeemed"])
		self.assertEqual(
			RewardRedemption.objects.filter(
				enrollment=enrollment,
				status=RedemptionStatus.FULFILLED,
			).count(),
			1,
		)
