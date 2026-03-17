from datetime import timedelta

from django.contrib.auth import get_user_model
from django.core.files.uploadedfile import SimpleUploadedFile
from django.urls import reverse
from django.utils import timezone
from rest_framework.test import APITestCase

from apps.flyers.models import Flyer, FlyerFormat, FlyerStatus
from apps.merchants.models import MerchantProfile, MerchantStatus
from apps.shops.models import Shop, ShopStatus

User = get_user_model()


class MerchantFlyersApiTests(APITestCase):
	def setUp(self):
		self.merchant_user = User.objects.create_user(
			email="merchant.flyers@localboost.test",
			username="merchant_flyers",
			password="merchant-password-123",
			role="merchant",
		)
		self.merchant_profile = MerchantProfile.objects.create(
			user=self.merchant_user,
			business_name="Merchant Flyers",
			status=MerchantStatus.ACTIVE,
		)

		self.other_merchant_user = User.objects.create_user(
			email="merchant.flyers.other@localboost.test",
			username="merchant_flyers_other",
			password="merchant-password-123",
			role="merchant",
		)
		self.other_merchant_profile = MerchantProfile.objects.create(
			user=self.other_merchant_user,
			business_name="Merchant Flyers Other",
			status=MerchantStatus.ACTIVE,
		)

		self.shop = Shop.objects.create(
			merchant=self.merchant_profile,
			name="Flyers Shop One",
			slug="flyers-shop-one",
			category="supermarket",
			description="Primary merchant shop.",
			logo_url="https://example.com/logo-one.png",
			address_line_1="Rue 1",
			city="Djibouti",
			country="Djibouti",
			latitude=11.588600,
			longitude=43.145700,
			status=ShopStatus.ACTIVE,
			is_active=True,
		)
		self.second_shop = Shop.objects.create(
			merchant=self.merchant_profile,
			name="Flyers Shop Two",
			slug="flyers-shop-two",
			category="electronics",
			description="Secondary merchant shop.",
			address_line_1="Rue 2",
			city="Djibouti",
			country="Djibouti",
			status=ShopStatus.ACTIVE,
			is_active=True,
		)
		self.other_shop = Shop.objects.create(
			merchant=self.other_merchant_profile,
			name="Flyers Other Shop",
			slug="flyers-other-shop",
			category="pharmacy",
			description="Other merchant shop.",
			address_line_1="Rue 3",
			city="Djibouti",
			country="Djibouti",
			status=ShopStatus.ACTIVE,
			is_active=True,
		)

		now = timezone.now()
		self.flyer = Flyer.objects.create(
			shop=self.shop,
			title="March Deals",
			description="Primary merchant flyer.",
			file_format=FlyerFormat.PDF,
			file_url="https://example.com/flyers/march.pdf",
			thumbnail_url="https://example.com/flyers/march.png",
			status=FlyerStatus.DRAFT,
			starts_at=now + timedelta(days=1),
			ends_at=now + timedelta(days=7),
		)
		self.second_shop_flyer = Flyer.objects.create(
			shop=self.second_shop,
			title="Electro Week",
			description="Secondary shop flyer.",
			file_format=FlyerFormat.IMAGE,
			status=FlyerStatus.PUBLISHED,
			starts_at=now - timedelta(days=1),
			ends_at=now + timedelta(days=5),
		)
		self.other_flyer = Flyer.objects.create(
			shop=self.other_shop,
			title="Other Merchant Flyer",
			description="Should never leak.",
			file_format=FlyerFormat.IMAGE,
			status=FlyerStatus.PUBLISHED,
			starts_at=now - timedelta(days=1),
			ends_at=now + timedelta(days=4),
		)

	def authenticate(self, user):
		self.client.force_authenticate(user=user)

	def build_payload(self, **overrides):
		payload = {
			"title": "Weekend Prospectus",
			"description": "Fresh offers for the weekend.",
			"file_type": FlyerFormat.PDF,
			"file_url": "https://example.com/flyers/weekend.pdf",
			"thumbnail_url": "https://example.com/flyers/weekend.png",
			"status": FlyerStatus.DRAFT,
			"starts_at": (timezone.now() + timedelta(days=1)).isoformat(),
			"ends_at": (timezone.now() + timedelta(days=3)).isoformat(),
		}
		payload.update(overrides)
		return payload

	def build_uploaded_pdf(self, name="flyer.pdf"):
		return SimpleUploadedFile(
			name,
			b"%PDF-1.4\n1 0 obj\n<< /Type /Catalog >>\nendobj\n%%EOF",
			content_type="application/pdf",
		)

	def _extract_results(self, response):
		if isinstance(response.data, list):
			return response.data
		return response.data.get("results", response.data)

	def test_list_returns_only_flyers_for_requested_owned_shop(self):
		self.authenticate(self.merchant_user)

		response = self.client.get(
			reverse("merchant-shop-flyer-list-create", kwargs={"shop_id": self.shop.id})
		)

		self.assertEqual(response.status_code, 200)
		results = self._extract_results(response)
		self.assertEqual(len(results), 1)
		self.assertEqual(results[0]["id"], self.flyer.id)
		self.assertEqual(results[0]["shop_id"], self.shop.id)

	def test_create_flyer_assigns_shop_from_route(self):
		self.authenticate(self.merchant_user)

		response = self.client.post(
			reverse("merchant-shop-flyer-list-create", kwargs={"shop_id": self.shop.id}),
			data=self.build_payload(status=FlyerStatus.PUBLISHED),
			format="json",
		)

		self.assertEqual(response.status_code, 201)
		self.assertEqual(response.data["shop_id"], self.shop.id)
		self.assertEqual(response.data["status"], FlyerStatus.PUBLISHED)
		self.assertEqual(response.data["store_name"], self.shop.name)

		created_flyer = Flyer.objects.get(id=response.data["id"])
		self.assertEqual(created_flyer.shop_id, self.shop.id)
		self.assertEqual(created_flyer.title, "Weekend Prospectus")
		self.assertTrue(created_flyer.is_active)

	def test_create_flyer_accepts_multipart_file_upload(self):
		self.authenticate(self.merchant_user)

		response = self.client.post(
			reverse("merchant-shop-flyer-list-create", kwargs={"shop_id": self.shop.id}),
			data={
				"title": "Multipart Flyer",
				"description": "Multipart upload test.",
				"file_type": FlyerFormat.PDF,
				"status": FlyerStatus.DRAFT,
				"starts_at": (timezone.now() + timedelta(days=1)).isoformat(),
				"ends_at": (timezone.now() + timedelta(days=3)).isoformat(),
				"file": self.build_uploaded_pdf("multipart-create.pdf"),
			},
			format="multipart",
		)

		self.assertEqual(response.status_code, 201)
		created_flyer = Flyer.objects.get(id=response.data["id"])
		self.assertTrue(bool(created_flyer.file))
		self.assertIn("flyers/", created_flyer.file.name)
		self.assertIn("flyers/", response.data["file_url"])

	def test_create_flyer_rejects_other_merchants_shop(self):
		self.authenticate(self.merchant_user)

		response = self.client.post(
			reverse(
				"merchant-shop-flyer-list-create",
				kwargs={"shop_id": self.other_shop.id},
			),
			data=self.build_payload(),
			format="json",
		)

		self.assertEqual(response.status_code, 404)

	def test_create_flyer_rejects_invalid_schedule(self):
		self.authenticate(self.merchant_user)
		starts_at = timezone.now() + timedelta(days=3)
		ends_at = starts_at - timedelta(hours=1)

		response = self.client.post(
			reverse("merchant-shop-flyer-list-create", kwargs={"shop_id": self.shop.id}),
			data=self.build_payload(
				starts_at=starts_at.isoformat(),
				ends_at=ends_at.isoformat(),
			),
			format="json",
		)

		self.assertEqual(response.status_code, 400)
		self.assertIn("ends_at", response.data)

	def test_update_flyer_allows_patch_for_owner(self):
		self.authenticate(self.merchant_user)

		response = self.client.patch(
			reverse("merchant-flyer-detail", kwargs={"id": self.flyer.id}),
			data={
				"title": "Updated March Deals",
				"status": FlyerStatus.PUBLISHED,
			},
			format="json",
		)

		self.assertEqual(response.status_code, 200)
		self.assertEqual(response.data["title"], "Updated March Deals")
		self.assertEqual(response.data["status"], FlyerStatus.PUBLISHED)

		self.flyer.refresh_from_db()
		self.assertEqual(self.flyer.title, "Updated March Deals")
		self.assertTrue(self.flyer.is_active)

	def test_update_flyer_accepts_multipart_file_upload(self):
		self.authenticate(self.merchant_user)

		response = self.client.patch(
			reverse("merchant-flyer-detail", kwargs={"id": self.flyer.id}),
			data={
				"title": "Updated with file",
				"file": self.build_uploaded_pdf("multipart-update.pdf"),
			},
			format="multipart",
		)

		self.assertEqual(response.status_code, 200)
		self.flyer.refresh_from_db()
		self.assertEqual(self.flyer.title, "Updated with file")
		self.assertTrue(bool(self.flyer.file))
		self.assertIn("flyers/", self.flyer.file.name)
		self.assertIn("flyers/", response.data["file_url"])

	def test_get_flyer_detail_allows_owner(self):
		self.authenticate(self.merchant_user)

		response = self.client.get(
			reverse("merchant-flyer-detail", kwargs={"id": self.flyer.id})
		)

		self.assertEqual(response.status_code, 200)
		self.assertEqual(response.data["id"], self.flyer.id)
		self.assertEqual(response.data["shop_id"], self.shop.id)
		self.assertEqual(response.data["file_type"], FlyerFormat.PDF)

	def test_delete_flyer_removes_owned_resource(self):
		self.authenticate(self.merchant_user)

		response = self.client.delete(
			reverse("merchant-flyer-detail", kwargs={"id": self.flyer.id})
		)

		self.assertEqual(response.status_code, 204)
		self.assertFalse(Flyer.objects.filter(id=self.flyer.id).exists())

	def test_public_list_returns_only_current_published_flyers(self):
		response = self.client.get(reverse("flyer-list"))

		self.assertEqual(response.status_code, 200)
		results = self._extract_results(response)
		returned_ids = {item["id"] for item in results}
		self.assertIn(self.second_shop_flyer.id, returned_ids)
		self.assertIn(self.other_flyer.id, returned_ids)
		self.assertNotIn(self.flyer.id, returned_ids)

	def test_non_owner_merchant_cannot_manage_other_flyer(self):
		self.authenticate(self.other_merchant_user)

		response = self.client.patch(
			reverse("merchant-flyer-detail", kwargs={"id": self.flyer.id}),
			data={"title": "Should fail"},
			format="json",
		)

		self.assertEqual(response.status_code, 404)
