from datetime import timedelta

from django.contrib.auth import get_user_model
from django.urls import reverse
from django.utils import timezone
from rest_framework.test import APITestCase

from apps.customers.models import CustomerProfile
from apps.deals.models import Deal, DealStatus, DealType
from apps.enrollments.models import Enrollment
from apps.loyalty.models import LoyaltyProgram
from apps.merchants.models import MerchantProfile, MerchantStatus
from apps.rewards.models import RewardRedemption
from apps.shops.models import Shop, ShopStatus

User = get_user_model()


class MerchantDealsApiTests(APITestCase):
	def setUp(self):
		self.merchant_user = User.objects.create_user(
			email="merchant1@localboost.test",
			username="merchant_deals_1",
			password="merchant-password-123",
			role="merchant",
		)
		self.merchant_profile = MerchantProfile.objects.create(
			user=self.merchant_user,
			business_name="Merchant Deals One",
			status=MerchantStatus.ACTIVE,
		)

		self.other_merchant_user = User.objects.create_user(
			email="merchant2@localboost.test",
			username="merchant_deals_2",
			password="merchant-password-123",
			role="merchant",
		)
		self.other_merchant_profile = MerchantProfile.objects.create(
			user=self.other_merchant_user,
			business_name="Merchant Deals Two",
			status=MerchantStatus.ACTIVE,
		)

		self.customer_user = User.objects.create_user(
			email="customer@localboost.test",
			username="customer_deals_1",
			password="customer-password-123",
			role="customer",
		)
		self.second_customer_user = User.objects.create_user(
			email="customer2@localboost.test",
			username="customer_deals_2",
			password="customer-password-123",
			role="customer",
		)
		self.customer_profile = CustomerProfile.objects.create(user=self.customer_user)
		self.second_customer_profile = CustomerProfile.objects.create(
			user=self.second_customer_user
		)

		self.shop = Shop.objects.create(
			merchant=self.merchant_profile,
			name="Deals Shop One",
			slug="deals-shop-one",
			category="retail",
			description="Primary merchant shop.",
			address_line_1="Rue 1",
			city="Djibouti",
			country="Djibouti",
			status=ShopStatus.ACTIVE,
			is_active=True,
		)
		self.second_shop = Shop.objects.create(
			merchant=self.merchant_profile,
			name="Deals Shop Two",
			slug="deals-shop-two",
			category="retail",
			description="Secondary merchant shop.",
			address_line_1="Rue 2",
			city="Djibouti",
			country="Djibouti",
			status=ShopStatus.DRAFT,
			is_active=False,
		)
		self.other_shop = Shop.objects.create(
			merchant=self.other_merchant_profile,
			name="Deals Other Shop",
			slug="deals-other-shop",
			category="grocery",
			description="Other merchant shop.",
			address_line_1="Rue 3",
			city="Djibouti",
			country="Djibouti",
			status=ShopStatus.ACTIVE,
			is_active=True,
		)

		now = timezone.now()
		self.deal = Deal.objects.create(
			shop=self.shop,
			title="Launch Discount",
			description="Primary merchant deal.",
			deal_type=DealType.PERCENTAGE,
			status=DealStatus.DRAFT,
			starts_at=now + timedelta(days=1),
			ends_at=now + timedelta(days=7),
			max_redemptions=50,
		)
		self.second_shop_deal = Deal.objects.create(
			shop=self.second_shop,
			title="Second Shop Discount",
			description="Secondary shop deal.",
			deal_type=DealType.AMOUNT,
			status=DealStatus.PUBLISHED,
			starts_at=now + timedelta(days=2),
			ends_at=now + timedelta(days=5),
		)
		self.other_deal = Deal.objects.create(
			shop=self.other_shop,
			title="Other Merchant Deal",
			description="Should never leak.",
			deal_type=DealType.STAMP,
			status=DealStatus.DRAFT,
			starts_at=now + timedelta(days=1),
			ends_at=now + timedelta(days=4),
		)

		self.loyalty_program = LoyaltyProgram.objects.create(
			shop=self.shop,
			name="Deals Loyalty",
			description="Loyalty program for deal analytics.",
			reward_label="Free drink",
			stamps_required=10,
			is_active=True,
		)
		self.enrollment_one = Enrollment.objects.create(
			customer=self.customer_profile,
			loyalty_program=self.loyalty_program,
		)
		self.enrollment_two = Enrollment.objects.create(
			customer=self.second_customer_profile,
			loyalty_program=self.loyalty_program,
		)

		RewardRedemption.objects.create(
			enrollment=self.enrollment_one,
			deal=self.deal,
			reward_label="Free drink",
		)
		RewardRedemption.objects.create(
			enrollment=self.enrollment_one,
			deal=self.deal,
			reward_label="Free dessert",
		)
		RewardRedemption.objects.create(
			enrollment=self.enrollment_two,
			deal=self.deal,
			reward_label="Coffee",
		)

	def authenticate(self, user):
		self.client.force_authenticate(user=user)

	def build_payload(self, **overrides):
		payload = {
			"title": "Weekend Offer",
			"description": "Save on your next visit.",
			"deal_type": DealType.PERCENTAGE,
			"status": DealStatus.DRAFT,
			"starts_at": (timezone.now() + timedelta(days=1)).isoformat(),
			"ends_at": (timezone.now() + timedelta(days=3)).isoformat(),
			"max_redemptions": 100,
		}
		payload.update(overrides)
		return payload

	def test_list_returns_only_deals_for_requested_owned_shop(self):
		self.authenticate(self.merchant_user)

		response = self.client.get(
			reverse("merchant-shop-deal-list-create", kwargs={"shop_id": self.shop.id})
		)

		self.assertEqual(response.status_code, 200)
		results = response.data.get("results", response.data)
		self.assertEqual(len(results), 1)
		self.assertEqual(results[0]["id"], self.deal.id)
		self.assertEqual(results[0]["shop_id"], self.shop.id)

	def test_create_deal_assigns_shop_from_route(self):
		self.authenticate(self.merchant_user)

		response = self.client.post(
			reverse("merchant-shop-deal-list-create", kwargs={"shop_id": self.shop.id}),
			data=self.build_payload(),
			format="json",
		)

		self.assertEqual(response.status_code, 201)
		self.assertEqual(response.data["shop_id"], self.shop.id)
		self.assertEqual(response.data["status"], DealStatus.DRAFT)

		created_deal = Deal.objects.get(id=response.data["id"])
		self.assertEqual(created_deal.shop_id, self.shop.id)
		self.assertEqual(created_deal.title, "Weekend Offer")

	def test_create_deal_rejects_other_merchants_shop(self):
		self.authenticate(self.merchant_user)

		response = self.client.post(
			reverse(
				"merchant-shop-deal-list-create",
				kwargs={"shop_id": self.other_shop.id},
			),
			data=self.build_payload(),
			format="json",
		)

		self.assertEqual(response.status_code, 404)

	def test_create_deal_rejects_invalid_schedule(self):
		self.authenticate(self.merchant_user)
		starts_at = timezone.now() + timedelta(days=3)
		ends_at = starts_at - timedelta(hours=1)

		response = self.client.post(
			reverse("merchant-shop-deal-list-create", kwargs={"shop_id": self.shop.id}),
			data=self.build_payload(
				starts_at=starts_at.isoformat(),
				ends_at=ends_at.isoformat(),
			),
			format="json",
		)

		self.assertEqual(response.status_code, 400)
		self.assertIn("ends_at", response.data)

	def test_update_deal_allows_patch_for_owner(self):
		self.authenticate(self.merchant_user)

		response = self.client.patch(
			reverse("merchant-deal-detail", kwargs={"id": self.deal.id}),
			data={
				"title": "Updated Launch Discount",
				"status": DealStatus.PUBLISHED,
			},
			format="json",
		)

		self.assertEqual(response.status_code, 200)
		self.assertEqual(response.data["title"], "Updated Launch Discount")
		self.assertEqual(response.data["status"], DealStatus.PUBLISHED)

		self.deal.refresh_from_db()
		self.assertEqual(self.deal.title, "Updated Launch Discount")
		self.assertEqual(self.deal.status, DealStatus.PUBLISHED)

	def test_get_deal_detail_allows_owner(self):
		self.authenticate(self.merchant_user)

		response = self.client.get(
			reverse("merchant-deal-detail", kwargs={"id": self.deal.id})
		)

		self.assertEqual(response.status_code, 200)
		self.assertEqual(response.data["id"], self.deal.id)
		self.assertEqual(response.data["shop_id"], self.shop.id)

	def test_record_deal_view_increments_counter_for_owner(self):
		self.authenticate(self.merchant_user)

		response = self.client.post(
			reverse("merchant-deal-view-track", kwargs={"id": self.deal.id}),
			format="json",
		)

		self.assertEqual(response.status_code, 200)
		self.assertEqual(response.data["view_count"], 1)

		self.deal.refresh_from_db()
		self.assertEqual(self.deal.view_count, 1)
		self.assertEqual(self.deal.share_count, 0)

	def test_record_deal_share_increments_counter_for_owner(self):
		self.authenticate(self.merchant_user)

		response = self.client.post(
			reverse("merchant-deal-share-track", kwargs={"id": self.deal.id}),
			format="json",
		)

		self.assertEqual(response.status_code, 200)
		self.assertEqual(response.data["share_count"], 1)

		self.deal.refresh_from_db()
		self.assertEqual(self.deal.share_count, 1)
		self.assertEqual(self.deal.view_count, 0)

	def test_update_deal_allows_put_for_owner(self):
		self.authenticate(self.merchant_user)

		response = self.client.put(
			reverse("merchant-deal-detail", kwargs={"id": self.deal.id}),
			data=self.build_payload(
				title="Put Updated Launch Discount",
				description="Updated through PUT",
				deal_type=DealType.AMOUNT,
				status=DealStatus.PUBLISHED,
			),
			format="json",
		)

		self.assertEqual(response.status_code, 200)
		self.assertEqual(response.data["title"], "Put Updated Launch Discount")
		self.assertEqual(response.data["status"], DealStatus.PUBLISHED)

		self.deal.refresh_from_db()
		self.assertEqual(self.deal.title, "Put Updated Launch Discount")
		self.assertEqual(self.deal.status, DealStatus.PUBLISHED)

	def test_delete_deal_archives_instead_of_removing(self):
		self.authenticate(self.merchant_user)

		response = self.client.delete(
			reverse("merchant-deal-detail", kwargs={"id": self.deal.id})
		)

		self.assertEqual(response.status_code, 204)
		self.deal.refresh_from_db()
		self.assertEqual(self.deal.status, DealStatus.ARCHIVED)

	def test_other_merchant_cannot_access_deal_detail(self):
		self.authenticate(self.other_merchant_user)

		response = self.client.get(
			reverse("merchant-deal-detail", kwargs={"id": self.deal.id})
		)

		self.assertEqual(response.status_code, 404)

	def test_tracking_endpoints_enforce_merchant_ownership(self):
		self.authenticate(self.other_merchant_user)

		other_merchant_response = self.client.post(
			reverse("merchant-deal-view-track", kwargs={"id": self.deal.id}),
			format="json",
		)
		self.assertEqual(other_merchant_response.status_code, 404)

		self.authenticate(self.customer_user)
		customer_response = self.client.post(
			reverse("merchant-deal-share-track", kwargs={"id": self.deal.id}),
			format="json",
		)
		self.assertEqual(customer_response.status_code, 403)

	def test_non_merchant_user_is_blocked(self):
		self.authenticate(self.customer_user)

		response = self.client.get(
			reverse("merchant-shop-deal-list-create", kwargs={"shop_id": self.shop.id})
		)

		self.assertEqual(response.status_code, 403)

	def test_deal_responses_include_analytics_counters(self):
		self.authenticate(self.merchant_user)

		detail_response = self.client.get(
			reverse("merchant-deal-detail", kwargs={"id": self.deal.id})
		)
		self.assertEqual(detail_response.status_code, 200)
		self.assertEqual(detail_response.data["enrollment_count"], 2)
		self.assertEqual(detail_response.data["redemption_count"], 3)
		self.assertEqual(detail_response.data["view_count"], 0)
		self.assertEqual(detail_response.data["share_count"], 0)

		list_response = self.client.get(
			reverse("merchant-shop-deal-list-create", kwargs={"shop_id": self.shop.id})
		)
		self.assertEqual(list_response.status_code, 200)
		results = list_response.data.get("results", list_response.data)
		self.assertEqual(len(results), 1)
		self.assertEqual(results[0]["enrollment_count"], 2)
		self.assertEqual(results[0]["redemption_count"], 3)
		self.assertEqual(results[0]["view_count"], 0)
		self.assertEqual(results[0]["share_count"], 0)


class PublicDealsApiTests(APITestCase):
	"""Tests for public deal discovery endpoints (no authentication required)"""

	def setUp(self):
		self.merchant_user = User.objects.create_user(
			email="merchant_public@localboost.test",
			username="merchant_public",
			password="merchant-password-123",
			role="merchant",
		)
		self.merchant_profile = MerchantProfile.objects.create(
			user=self.merchant_user,
			business_name="Public Merchant",
			status=MerchantStatus.ACTIVE,
		)

		self.customer_user = User.objects.create_user(
			email="customer_public@localboost.test",
			username="customer_public",
			password="customer-password-123",
			role="customer",
		)
		self.customer_profile = CustomerProfile.objects.create(user=self.customer_user)

		now = timezone.now()
		
		# Active shop with active deals
		self.active_shop = Shop.objects.create(
			merchant=self.merchant_profile,
			name="Active Public Shop",
			slug="active-public-shop",
			category="retail",
			description="Shop for public discovery.",
			address_line_1="Main St",
			city="Djibouti",
			country="Djibouti",
			status=ShopStatus.ACTIVE,
			is_active=True,
		)

		# Inactive shop (should be filtered out)
		self.inactive_shop = Shop.objects.create(
			merchant=self.merchant_profile,
			name="Inactive Public Shop",
			slug="inactive-public-shop",
			category="grocery",
			description="Inactive shop.",
			address_line_1="Side St",
			city="Djibouti",
			country="Djibouti",
			status=ShopStatus.DRAFT,
			is_active=False,
		)

		# Published, active deal (should be discoverable)
		self.published_active_deal = Deal.objects.create(
			shop=self.active_shop,
			title="Popular Discount",
			description="Best deal in town",
			deal_type=DealType.PERCENTAGE,
			status=DealStatus.PUBLISHED,
			starts_at=now - timedelta(days=1),
			ends_at=now + timedelta(days=7),
			max_redemptions=100,
		)

		# Published but future deal (should not be discoverable until starts_at)
		self.future_deal = Deal.objects.create(
			shop=self.active_shop,
			title="Future Special",
			description="Coming soon",
			deal_type=DealType.AMOUNT,
			status=DealStatus.PUBLISHED,
			starts_at=now + timedelta(days=5),
			ends_at=now + timedelta(days=10),
			max_redemptions=50,
		)

		# Published but expired deal (should not be discoverable)
		self.expired_deal = Deal.objects.create(
			shop=self.active_shop,
			title="Expired Sale",
			description="Old deal",
			deal_type=DealType.STAMP,
			status=DealStatus.PUBLISHED,
			starts_at=now - timedelta(days=10),
			ends_at=now - timedelta(days=2),
			max_redemptions=200,
		)

		# Draft deal (should not be discoverable)
		self.draft_deal = Deal.objects.create(
			shop=self.active_shop,
			title="Draft Offer",
			description="Not ready yet",
			deal_type=DealType.PERCENTAGE,
			status=DealStatus.DRAFT,
			starts_at=now + timedelta(days=1),
			ends_at=now + timedelta(days=5),
			max_redemptions=75,
		)

		# Archived deal (should not be discoverable)
		self.archived_deal = Deal.objects.create(
			shop=self.active_shop,
			title="Archived Deal",
			description="Removed",
			deal_type=DealType.AMOUNT,
			status=DealStatus.ARCHIVED,
			starts_at=now - timedelta(days=5),
			ends_at=now - timedelta(days=1),
			max_redemptions=150,
		)

		# Published deal in inactive shop (should not be discoverable)
		self.deal_in_inactive_shop = Deal.objects.create(
			shop=self.inactive_shop,
			title="Inactive Shop Deal",
			description="Shouldn't show",
			deal_type=DealType.PERCENTAGE,
			status=DealStatus.PUBLISHED,
			starts_at=now - timedelta(days=1),
			ends_at=now + timedelta(days=7),
			max_redemptions=100,
		)

		# Another published deal for pagination and search testing
		self.another_deal = Deal.objects.create(
			shop=self.active_shop,
			title="Special Weekend Offer",
			description="Limited time promotion",
			deal_type=DealType.STAMP,
			status=DealStatus.PUBLISHED,
			starts_at=now - timedelta(hours=1),
			ends_at=now + timedelta(days=3),
			max_redemptions=999,
		)

	def test_public_list_returns_only_published_active_deals(self):
		"""Verify only published deals from active shops are returned"""
		response = self.client.get(reverse("deal-list"))
		self.assertEqual(response.status_code, 200)

		# Response is a list (pagination_class = None)
		results = response.data
		deal_ids = {deal["id"] for deal in results}

		# Should include: published_active_deal, another_deal
		self.assertIn(self.published_active_deal.id, deal_ids)
		self.assertIn(self.another_deal.id, deal_ids)

		# Should exclude: future_deal, expired_deal, draft_deal, archived_deal, deal_in_inactive_shop
		self.assertNotIn(self.future_deal.id, deal_ids)
		self.assertNotIn(self.expired_deal.id, deal_ids)
		self.assertNotIn(self.draft_deal.id, deal_ids)
		self.assertNotIn(self.archived_deal.id, deal_ids)
		self.assertNotIn(self.deal_in_inactive_shop.id, deal_ids)

	def test_public_list_requires_no_authentication(self):
		"""Verify public list endpoint works without authentication"""
		response = self.client.get(reverse("deal-list"))
		self.assertEqual(response.status_code, 200)

		# Verify we get results (response is a list)
		self.assertGreater(len(response.data), 0)

	def test_public_list_filters_by_search_query(self):
		"""Verify search query filters deals by title/description"""
		# Search for "Popular" should find published_active_deal
		response = self.client.get(reverse("deal-list"), {"q": "Popular"})
		self.assertEqual(response.status_code, 200)
		results = response.data
		deal_ids = {deal["id"] for deal in results}
		self.assertIn(self.published_active_deal.id, deal_ids)

		# Search for "Weekend" should find another_deal
		response = self.client.get(reverse("deal-list"), {"q": "Weekend"})
		self.assertEqual(response.status_code, 200)
		results = response.data
		deal_ids = {deal["id"] for deal in results}
		self.assertIn(self.another_deal.id, deal_ids)

		# Search for "nonexistent" should return no results
		response = self.client.get(reverse("deal-list"), {"q": "nonexistent"})
		self.assertEqual(response.status_code, 200)
		results = response.data
		self.assertEqual(len(results), 0)

	def test_public_list_filters_by_category(self):
		"""Verify category filter works for active deals"""
		# Filter by retail should include our active deals
		response = self.client.get(reverse("deal-list"), {"category": "retail"})
		self.assertEqual(response.status_code, 200)
		results = response.data
		deal_ids = {deal["id"] for deal in results}
		self.assertIn(self.published_active_deal.id, deal_ids)
		self.assertIn(self.another_deal.id, deal_ids)

		# Filter by grocery should not include our retail deals
		response = self.client.get(reverse("deal-list"), {"category": "grocery"})
		self.assertEqual(response.status_code, 200)
		results = response.data
		deal_ids = {deal["id"] for deal in results}
		self.assertNotIn(self.published_active_deal.id, deal_ids)

	def test_public_detail_returns_published_active_deal(self):
		"""Verify GET /deals/{id}/ returns published deal from active shop"""
		response = self.client.get(
			reverse("deal-detail", kwargs={"id": self.published_active_deal.id})
		)
		self.assertEqual(response.status_code, 200)
		self.assertEqual(response.data["id"], self.published_active_deal.id)
		self.assertEqual(response.data["title"], "Popular Discount")
		self.assertEqual(response.data["status"], DealStatus.PUBLISHED)

	def test_public_detail_blocks_draft_deal(self):
		"""Verify draft deals are not accessible via detail endpoint"""
		response = self.client.get(
			reverse("deal-detail", kwargs={"id": self.draft_deal.id})
		)
		self.assertEqual(response.status_code, 404)

	def test_public_detail_blocks_archived_deal(self):
		"""Verify archived deals are not accessible via detail endpoint"""
		response = self.client.get(
			reverse("deal-detail", kwargs={"id": self.archived_deal.id})
		)
		self.assertEqual(response.status_code, 404)

	def test_public_detail_blocks_deal_from_inactive_shop(self):
		"""Verify deals from inactive shops are not accessible"""
		response = self.client.get(
			reverse("deal-detail", kwargs={"id": self.deal_in_inactive_shop.id})
		)
		self.assertEqual(response.status_code, 404)

	def test_public_detail_blocks_expired_deal(self):
		"""Verify expired deals are not accessible"""
		response = self.client.get(
			reverse("deal-detail", kwargs={"id": self.expired_deal.id})
		)
		self.assertEqual(response.status_code, 404)

	def test_public_detail_blocks_future_deal(self):
		"""Verify deals that haven't started yet are not accessible"""
		response = self.client.get(
			reverse("deal-detail", kwargs={"id": self.future_deal.id})
		)
		self.assertEqual(response.status_code, 404)

	def test_public_detail_includes_analytics_counters(self):
		"""Verify detail response includes analytics counters"""
		response = self.client.get(
			reverse("deal-detail", kwargs={"id": self.published_active_deal.id})
		)
		self.assertEqual(response.status_code, 200)
		self.assertIn("view_count", response.data)
		self.assertIn("share_count", response.data)
		self.assertIn("enrollment_count", response.data)
		self.assertIn("redemption_count", response.data)

	def test_public_list_returns_complete_deal_list(self):
		"""Verify list endpoint returns complete list of published deals"""
		response = self.client.get(reverse("deal-list"))
		self.assertEqual(response.status_code, 200)
		# Response is a list (pagination_class = None)
		self.assertIsInstance(response.data, list)
		# Verify we got at least our two active deals
		self.assertGreaterEqual(len(response.data), 2)
