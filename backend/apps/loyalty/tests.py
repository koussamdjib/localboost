from django.test import TestCase

# Create your tests here.
from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework.test import APITestCase

from apps.loyalty.models import LoyaltyProgram
from apps.merchants.models import MerchantProfile, MerchantStatus
from apps.shops.models import Shop, ShopStatus

User = get_user_model()


class MerchantLoyaltyApiTests(APITestCase):
	def setUp(self):
		self.merchant_user = User.objects.create_user(
			email="merchant_loyalty@localboost.test",
			username="merchant_loyalty_1",
			password="merchant-password-123",
			role="merchant",
		)
		self.merchant_profile = MerchantProfile.objects.create(
			user=self.merchant_user,
			business_name="Loyalty Merchant",
			status=MerchantStatus.ACTIVE,
		)

		self.other_merchant_user = User.objects.create_user(
			email="merchant_loyalty_2@localboost.test",
			username="merchant_loyalty_2",
			password="merchant-password-123",
			role="merchant",
		)
		self.other_merchant_profile = MerchantProfile.objects.create(
			user=self.other_merchant_user,
			business_name="Other Loyalty Merchant",
			status=MerchantStatus.ACTIVE,
		)

		self.customer_user = User.objects.create_user(
			email="customer_loyalty@localboost.test",
			username="customer_loyalty_1",
			password="customer-password-123",
			role="customer",
		)

		self.shop = Shop.objects.create(
			merchant=self.merchant_profile,
			name="Loyalty Shop",
			slug="loyalty-shop",
			category="retail",
			description="Shop for loyalty program.",
			address_line_1="Main St",
			city="Djibouti",
			country="Djibouti",
			status=ShopStatus.ACTIVE,
			is_active=True,
		)

		self.other_shop = Shop.objects.create(
			merchant=self.other_merchant_profile,
			name="Other Shop",
			slug="other-shop",
			category="grocery",
			description="Other merchant shop.",
			address_line_1="Side St",
			city="Djibouti",
			country="Djibouti",
			status=ShopStatus.ACTIVE,
			is_active=True,
		)

		self.loyalty_program = LoyaltyProgram.objects.create(
			shop=self.shop,
			name="Points Program",
			description="Earn points on purchases",
			stamps_required=10,
			reward_label="Free drink",
			is_active=True,
		)

	def authenticate(self, user):
		self.client.force_authenticate(user=user)

	def build_payload(self, **overrides):
		payload = {
			"name": "Stamps Program",
			"description": "Earn stamps with every purchase",
			"stamps_required": 15,
			"reward_label": "Free dessert",
			"is_active": True,
		}
		payload.update(overrides)
		return payload

	def _extract_results(self, response):
		if isinstance(response.data, list):
			return response.data
		return response.data.get("results", response.data)

	def test_list_returns_only_loyalty_for_requested_owned_shop(self):
		self.authenticate(self.merchant_user)

		response = self.client.get(
			reverse(
				"merchant-shop-loyalty-list-create",
				kwargs={"shop_id": self.shop.id},
			)
		)

		self.assertEqual(response.status_code, 200)
		results = self._extract_results(response)
		program_ids = {item["id"] for item in results}
		self.assertIn(self.loyalty_program.id, program_ids)
		for item in results:
			self.assertEqual(item["shop_id"], self.shop.id)

	def test_create_loyalty_assigns_shop_from_route(self):
		self.authenticate(self.merchant_user)

		response = self.client.post(
			reverse(
				"merchant-shop-loyalty-list-create",
				kwargs={"shop_id": self.shop.id},
			),
			data=self.build_payload(),
			format="json",
		)

		self.assertEqual(response.status_code, 201)
		self.assertEqual(response.data["shop_id"], self.shop.id)
		self.assertEqual(response.data["name"], "Stamps Program")
		self.assertEqual(response.data["is_active"], True)

		created_program = LoyaltyProgram.objects.get(id=response.data["id"])
		self.assertEqual(created_program.shop_id, self.shop.id)

	def test_create_loyalty_rejects_other_merchants_shop(self):
		self.authenticate(self.merchant_user)

		response = self.client.post(
			reverse(
				"merchant-shop-loyalty-list-create",
				kwargs={"shop_id": self.other_shop.id},
			),
			data=self.build_payload(),
			format="json",
		)

		self.assertEqual(response.status_code, 404)

	def test_create_loyalty_validates_stamps_required(self):
		self.authenticate(self.merchant_user)

		response = self.client.post(
			reverse(
				"merchant-shop-loyalty-list-create",
				kwargs={"shop_id": self.shop.id},
			),
			data=self.build_payload(stamps_required=0),
			format="json",
		)

		self.assertEqual(response.status_code, 400)
		self.assertIn("stamps_required", response.data)

	def test_update_loyalty_allows_patch_for_owner(self):
		self.authenticate(self.merchant_user)

		response = self.client.patch(
			reverse("merchant-loyalty-detail", kwargs={"id": self.loyalty_program.id}),
			data={
				"name": "Updated Points Program",
				"stamps_required": 20,
			},
			format="json",
		)

		self.assertEqual(response.status_code, 200)
		self.assertEqual(response.data["name"], "Updated Points Program")
		self.assertEqual(response.data["stamps_required"], 20)

		self.loyalty_program.refresh_from_db()
		self.assertEqual(self.loyalty_program.name, "Updated Points Program")
		self.assertEqual(self.loyalty_program.stamps_required, 20)

	def test_get_loyalty_detail_allows_owner(self):
		self.authenticate(self.merchant_user)

		response = self.client.get(
			reverse("merchant-loyalty-detail", kwargs={"id": self.loyalty_program.id})
		)

		self.assertEqual(response.status_code, 200)
		self.assertEqual(response.data["id"], self.loyalty_program.id)
		self.assertEqual(response.data["name"], "Points Program")

	def test_update_loyalty_allows_put_for_owner(self):
		self.authenticate(self.merchant_user)

		response = self.client.put(
			reverse("merchant-loyalty-detail", kwargs={"id": self.loyalty_program.id}),
			data=self.build_payload(
				name="Put Updated Program",
				stamps_required=25,
				is_active=False,
			),
			format="json",
		)

		self.assertEqual(response.status_code, 200)
		self.assertEqual(response.data["name"], "Put Updated Program")
		self.assertEqual(response.data["is_active"], False)

		self.loyalty_program.refresh_from_db()
		self.assertEqual(self.loyalty_program.name, "Put Updated Program")
		self.assertEqual(self.loyalty_program.is_active, False)

	def test_delete_loyalty_removes_resource(self):
		self.authenticate(self.merchant_user)
		loyalty_id = self.loyalty_program.id

		response = self.client.delete(
			reverse("merchant-loyalty-detail", kwargs={"id": loyalty_id})
		)

		self.assertEqual(response.status_code, 204)
		self.assertFalse(LoyaltyProgram.objects.filter(id=loyalty_id).exists())

	def test_other_merchant_cannot_access_loyalty_detail(self):
		self.authenticate(self.other_merchant_user)

		response = self.client.get(
			reverse("merchant-loyalty-detail", kwargs={"id": self.loyalty_program.id})
		)

		self.assertEqual(response.status_code, 404)

	def test_other_merchant_cannot_update_loyalty(self):
		self.authenticate(self.other_merchant_user)

		response = self.client.patch(
			reverse("merchant-loyalty-detail", kwargs={"id": self.loyalty_program.id}),
			data={"name": "Hacked Program"},
			format="json",
		)

		self.assertEqual(response.status_code, 404)

	def test_other_merchant_cannot_delete_loyalty(self):
		self.authenticate(self.other_merchant_user)

		response = self.client.delete(
			reverse("merchant-loyalty-detail", kwargs={"id": self.loyalty_program.id})
		)

		self.assertEqual(response.status_code, 404)

	def test_non_merchant_user_is_blocked(self):
		self.authenticate(self.customer_user)

		response = self.client.get(
			reverse(
				"merchant-shop-loyalty-list-create",
				kwargs={"shop_id": self.shop.id},
			)
		)

		self.assertEqual(response.status_code, 403)

	def test_unauthenticated_user_is_blocked(self):
		response = self.client.get(
			reverse(
				"merchant-shop-loyalty-list-create",
				kwargs={"shop_id": self.shop.id},
			)
		)

		self.assertEqual(response.status_code, 401)

	def test_loyalty_response_includes_enrollment_count(self):
		self.authenticate(self.merchant_user)

		response = self.client.get(
			reverse("merchant-loyalty-detail", kwargs={"id": self.loyalty_program.id})
		)

		self.assertEqual(response.status_code, 200)
		self.assertIn("enrollment_count", response.data)
		self.assertEqual(response.data["enrollment_count"], 0)
