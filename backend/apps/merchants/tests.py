from django.contrib.auth import get_user_model
from django.urls import reverse
from rest_framework.test import APITestCase

from apps.merchants.models import MerchantProfile
from apps.shops.models import Shop, ShopStatus

User = get_user_model()


class MerchantShopBusinessHoursApiTests(APITestCase):
	def setUp(self):
		self.merchant_user = User.objects.create_user(
			email="merchant.hours@localboost.test",
			username="merchant_hours",
			password="merchant-password-123",
			role="merchant",
		)
		self.merchant_profile = MerchantProfile.objects.create(
			user=self.merchant_user,
			business_name="Merchant Hours",
		)

		self.other_merchant_user = User.objects.create_user(
			email="merchant.hours.other@localboost.test",
			username="merchant_hours_other",
			password="merchant-password-123",
			role="merchant",
		)
		self.other_merchant_profile = MerchantProfile.objects.create(
			user=self.other_merchant_user,
			business_name="Merchant Hours Other",
		)

		self.shop = Shop.objects.create(
			merchant=self.merchant_profile,
			name="Hours Shop",
			slug="hours-shop",
			category="supermarket",
			address_line_1="Rue 1",
			city="Djibouti",
			country="Djibouti",
			status=ShopStatus.ACTIVE,
			is_active=True,
		)

		self.other_shop = Shop.objects.create(
			merchant=self.other_merchant_profile,
			name="Other Hours Shop",
			slug="other-hours-shop",
			category="pharmacy",
			address_line_1="Rue 2",
			city="Djibouti",
			country="Djibouti",
			status=ShopStatus.ACTIVE,
			is_active=True,
		)

	def authenticate(self, user):
		self.client.force_authenticate(user=user)

	def build_business_hours(self):
		return {
			"monday": {
				"openHour": 9,
				"openMinute": 0,
				"closeHour": 18,
				"closeMinute": 0,
			},
			"tuesday": {
				"openHour": 9,
				"openMinute": 0,
				"closeHour": 18,
				"closeMinute": 0,
			},
			"wednesday": {
				"openHour": 9,
				"openMinute": 0,
				"closeHour": 18,
				"closeMinute": 0,
			},
			"thursday": {
				"openHour": 9,
				"openMinute": 0,
				"closeHour": 18,
				"closeMinute": 0,
			},
			"friday": {
				"openHour": 9,
				"openMinute": 0,
				"closeHour": 18,
				"closeMinute": 0,
			},
			"saturday": {
				"openHour": 9,
				"openMinute": 0,
				"closeHour": 14,
				"closeMinute": 0,
			},
			"sunday": None,
		}

	def test_owner_can_patch_business_hours(self):
		self.authenticate(self.merchant_user)
		business_hours = self.build_business_hours()

		response = self.client.patch(
			reverse("merchant-shop-detail", kwargs={"id": self.shop.id}),
			data={"business_hours": business_hours},
			format="json",
		)

		self.assertEqual(response.status_code, 200)
		self.assertEqual(response.data["business_hours"], business_hours)

		self.shop.refresh_from_db()
		self.assertEqual(self.shop.business_hours, business_hours)

	def test_non_owner_cannot_patch_business_hours(self):
		self.authenticate(self.other_merchant_user)

		response = self.client.patch(
			reverse("merchant-shop-detail", kwargs={"id": self.shop.id}),
			data={"business_hours": self.build_business_hours()},
			format="json",
		)

		self.assertEqual(response.status_code, 404)
