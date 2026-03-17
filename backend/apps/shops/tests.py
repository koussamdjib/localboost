from datetime import timedelta
from decimal import Decimal

from django.contrib.auth import get_user_model
from django.urls import reverse
from django.utils import timezone
from rest_framework.test import APITestCase

from apps.deals.models import Deal, DealStatus, DealType
from apps.loyalty.models import LoyaltyProgram
from apps.merchants.models import MerchantProfile
from apps.shops.models import Shop, ShopStatus

User = get_user_model()


class ShopDiscoveryApiTests(APITestCase):
	def setUp(self):
		merchant_user = User.objects.create_user(
			email="merchant@localboost.test",
			username="merchant_discovery",
			password="merchant-password-123",
			role="merchant",
		)
		merchant_profile = MerchantProfile.objects.create(
			user=merchant_user,
			business_name="Ocean Cafe",
		)

		self.active_shop = Shop.objects.create(
			merchant=merchant_profile,
			name="Ocean Cafe Downtown",
			slug="ocean-cafe-downtown",
			category="cafe",
			description="Coffee and breakfast all day.",
			logo_url="https://cdn.localboost.test/shops/ocean/logo.png",
			cover_image_url="https://cdn.localboost.test/shops/ocean/cover.png",
			phone_number="+253700111222",
			address_line_1="Avenue 26",
			city="Djibouti",
			country="Djibouti",
			latitude=Decimal("11.588000"),
			longitude=Decimal("43.145000"),
			is_active=True,
		)

		self.inactive_shop = Shop.objects.create(
			merchant=merchant_profile,
			name="Hidden Shop",
			slug="hidden-shop",
			category="retail",
			description="Should not appear in discovery.",
			address_line_1="Secret street",
			city="Djibouti",
			country="Djibouti",
			is_active=False,
		)

		self.archived_shop = Shop.objects.create(
			merchant=merchant_profile,
			name="Archived Shop",
			slug="archived-shop",
			category="retail",
			description="Archived shops must stay hidden from discovery.",
			address_line_1="Old street",
			city="Djibouti",
			country="Djibouti",
			status=ShopStatus.ARCHIVED,
			is_active=True,
		)

		self.far_shop = Shop.objects.create(
			merchant=merchant_profile,
			name="Harbor Market",
			slug="harbor-market",
			category="grocery",
			description="Fresh products near the harbor.",
			address_line_1="Port district",
			city="Djibouti",
			country="Djibouti",
			latitude=Decimal("11.700000"),
			longitude=Decimal("43.300000"),
			is_active=True,
		)

		Deal.objects.create(
			shop=self.active_shop,
			title="20% Breakfast",
			description="Early bird discount.",
			deal_type=DealType.PERCENTAGE,
			status=DealStatus.PUBLISHED,
			starts_at=timezone.now() - timedelta(days=1),
			ends_at=timezone.now() + timedelta(days=1),
		)

		LoyaltyProgram.objects.create(
			shop=self.active_shop,
			name="Ocean Stamps",
			description="Collect 10 stamps and win a free drink.",
			reward_label="Free drink",
			stamps_required=10,
			is_active=True,
		)

	def test_shop_list_returns_only_active_shops(self):
		response = self.client.get(reverse("shop-list"))

		self.assertEqual(response.status_code, 200)
		self.assertEqual(len(response.data), 2)

		names = {shop["name"] for shop in response.data}
		self.assertIn(self.active_shop.name, names)
		self.assertIn(self.far_shop.name, names)
		self.assertNotIn(self.inactive_shop.name, names)
		self.assertNotIn(self.archived_shop.name, names)

		first = response.data[0]
		self.assertIn("has_active_deals", first)
		self.assertIn("has_loyalty_programs", first)
		self.assertNotIn("distance_km", first)

	def test_shop_search_filters_by_name_and_category(self):
		by_name = self.client.get(reverse("shop-search"), {"name": "Ocean"})
		self.assertEqual(by_name.status_code, 200)
		self.assertEqual(len(by_name.data), 1)
		self.assertEqual(by_name.data[0]["id"], self.active_shop.id)

		by_category = self.client.get(reverse("shop-search"), {"category": "grocery"})
		self.assertEqual(by_category.status_code, 200)
		self.assertEqual(len(by_category.data), 1)
		self.assertEqual(by_category.data[0]["id"], self.far_shop.id)

	def test_shop_search_supports_location_with_optional_radius(self):
		response = self.client.get(
			reverse("shop-search"),
			{
				"latitude": "11.588000",
				"longitude": "43.145000",
				"radius": "5",
			},
		)

		self.assertEqual(response.status_code, 200)
		self.assertEqual(len(response.data), 1)
		self.assertEqual(response.data[0]["id"], self.active_shop.id)
		self.assertIn("distance_km", response.data[0])

	def test_shop_search_rejects_partial_location_parameters(self):
		response = self.client.get(reverse("shop-search"), {"latitude": "11.58"})
		self.assertEqual(response.status_code, 400)
		self.assertIn("location", response.data)

	def test_shop_detail_returns_shop_payload(self):
		response = self.client.get(reverse("shop-detail", kwargs={"id": self.active_shop.id}))

		self.assertEqual(response.status_code, 200)
		self.assertEqual(response.data["id"], self.active_shop.id)
		self.assertEqual(response.data["category"], "cafe")
		self.assertTrue(response.data["has_active_deals"])
		self.assertTrue(response.data["has_loyalty_programs"])
		self.assertEqual(response.data["address"], "Avenue 26, Djibouti, Djibouti")
