from django.db.models import Count, F
from rest_framework import generics, status
from rest_framework.exceptions import PermissionDenied
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response

from apps.deals.models import Deal, DealStatus
from apps.deals.serializers import MerchantDealSerializer
from apps.flyers.models import Flyer
from apps.flyers.serializers import FlyerSerializer
from apps.merchants.models import MerchantProfile, MerchantStatus
from apps.merchants.permissions import (
	IsMerchantDealOwner,
	IsMerchantFlyerOwner,
	IsMerchantLoyaltyProgramOwner,
	IsMerchantShopOwner,
	IsMerchantUser,
)
from apps.loyalty.models import LoyaltyProgram
from apps.loyalty.serializers import LoyaltyProgramSerializer
from apps.merchants.serializers import MerchantShopSerializer
from apps.shops.models import Shop, ShopStatus


class MerchantShopBaseMixin:
	serializer_class = MerchantShopSerializer

	def get_merchant_profile(self):
		user = self.request.user
		try:
			merchant_profile = user.merchant_profile
		except MerchantProfile.DoesNotExist as exc:
			raise PermissionDenied("Merchant profile is required.") from exc

		if merchant_profile.status == MerchantStatus.SUSPENDED:
			raise PermissionDenied("Suspended merchants cannot manage shops.")

		return merchant_profile

	def get_queryset(self):
		merchant_profile = self.get_merchant_profile()
		return Shop.objects.filter(merchant=merchant_profile).order_by("-updated_at", "-id")


class MerchantShopListCreateView(MerchantShopBaseMixin, generics.ListCreateAPIView):
	"""
	POST /api/v1/merchant/shops/
	GET /api/v1/merchant/shops/
	"""

	permission_classes = [IsAuthenticated, IsMerchantUser]

	def perform_create(self, serializer):
		serializer.save(merchant=self.get_merchant_profile())


class MerchantShopDetailView(MerchantShopBaseMixin, generics.RetrieveUpdateDestroyAPIView):
	"""
	GET /api/v1/merchant/shops/{id}/
	PUT /api/v1/merchant/shops/{id}/
	DELETE /api/v1/merchant/shops/{id}/
	"""

	permission_classes = [IsAuthenticated, IsMerchantUser, IsMerchantShopOwner]
	lookup_field = "id"

	def destroy(self, request, *args, **kwargs):
		shop = self.get_object()

		if shop.status != ShopStatus.ARCHIVED or shop.is_active:
			shop.status = ShopStatus.ARCHIVED
			shop.is_active = False
			shop.save(update_fields=["status", "is_active", "updated_at"])

		return Response(status=status.HTTP_204_NO_CONTENT)


class MerchantDealBaseMixin(MerchantShopBaseMixin):
	serializer_class = MerchantDealSerializer

	def get_queryset(self):
		merchant_profile = self.get_merchant_profile()
		queryset = (
			Deal.objects.select_related("shop", "shop__merchant")
			.annotate(
				enrollment_count=Count("redemptions__enrollment", distinct=True),
				redemption_count=Count("redemptions", distinct=True),
			)
			.filter(
				shop__merchant=merchant_profile,
			)
		)

		shop_id = self.kwargs.get("shop_id")
		if shop_id is not None:
			queryset = queryset.filter(shop_id=shop_id)

		return queryset.order_by("-updated_at", "-id")

	def get_shop(self):
		if not hasattr(self, "_shop"):
			merchant_profile = self.get_merchant_profile()
			self._shop = generics.get_object_or_404(
				Shop.objects.filter(merchant=merchant_profile),
				id=self.kwargs["shop_id"],
			)

		return self._shop


class MerchantShopDealListCreateView(MerchantDealBaseMixin, generics.ListCreateAPIView):
	"""
	POST /api/v1/merchant/shops/{shop_id}/deals/
	GET /api/v1/merchant/shops/{shop_id}/deals/
	"""

	permission_classes = [IsAuthenticated, IsMerchantUser]

	def get_queryset(self):
		self.get_shop()
		return super().get_queryset()

	def perform_create(self, serializer):
		serializer.save(shop=self.get_shop())


class MerchantDealDetailView(MerchantDealBaseMixin, generics.RetrieveUpdateDestroyAPIView):
	"""
	GET /api/v1/merchant/deals/{id}/
	PUT /api/v1/merchant/deals/{id}/
	PATCH /api/v1/merchant/deals/{id}/
	DELETE /api/v1/merchant/deals/{id}/
	"""

	permission_classes = [IsAuthenticated, IsMerchantUser, IsMerchantDealOwner]
	lookup_field = "id"

	def destroy(self, request, *args, **kwargs):
		deal = self.get_object()

		if deal.status != DealStatus.ARCHIVED:
			deal.status = DealStatus.ARCHIVED
			deal.save(update_fields=["status", "updated_at"])

		return Response(status=status.HTTP_204_NO_CONTENT)


class MerchantDealMetricIncrementView(MerchantDealBaseMixin, generics.GenericAPIView):
	permission_classes = [IsAuthenticated, IsMerchantUser, IsMerchantDealOwner]
	lookup_field = "id"
	metric_field = ""

	def post(self, request, *args, **kwargs):
		deal = self.get_object()
		Deal.objects.filter(pk=deal.pk).update(**{self.metric_field: F(self.metric_field) + 1})
		refreshed_deal = self.get_queryset().get(pk=deal.pk)
		serializer = self.get_serializer(refreshed_deal)
		return Response(serializer.data, status=status.HTTP_200_OK)


class MerchantDealViewTrackView(MerchantDealMetricIncrementView):
	"""
	POST /api/v1/merchant/deals/{id}/view/
	"""

	metric_field = "view_count"


class MerchantDealShareTrackView(MerchantDealMetricIncrementView):
	"""
	POST /api/v1/merchant/deals/{id}/share/
	"""

	metric_field = "share_count"


class MerchantLoyaltyBaseMixin(MerchantShopBaseMixin):
	serializer_class = LoyaltyProgramSerializer

	def get_queryset(self):
		merchant_profile = self.get_merchant_profile()
		queryset = LoyaltyProgram.objects.select_related(
			"shop", "shop__merchant"
		).filter(
			shop__merchant=merchant_profile,
		)

		shop_id = self.kwargs.get("shop_id")
		if shop_id is not None:
			queryset = queryset.filter(shop_id=shop_id)

		return queryset.order_by("-updated_at", "-id")

	def get_shop(self):
		if not hasattr(self, "_shop"):
			merchant_profile = self.get_merchant_profile()
			self._shop = generics.get_object_or_404(
				Shop.objects.filter(merchant=merchant_profile),
				id=self.kwargs["shop_id"],
			)

		return self._shop


class MerchantShopLoyaltyListCreateView(MerchantLoyaltyBaseMixin, generics.ListCreateAPIView):
	"""
	POST /api/v1/merchant/shops/{shop_id}/loyalty/
	GET /api/v1/merchant/shops/{shop_id}/loyalty/
	"""

	permission_classes = [IsAuthenticated, IsMerchantUser]

	def get_queryset(self):
		self.get_shop()
		return super().get_queryset()

	def perform_create(self, serializer):
		serializer.save(shop=self.get_shop())


class MerchantLoyaltyDetailView(MerchantLoyaltyBaseMixin, generics.RetrieveUpdateDestroyAPIView):
	"""
	GET /api/v1/merchant/loyalty/{id}/
	PUT /api/v1/merchant/loyalty/{id}/
	PATCH /api/v1/merchant/loyalty/{id}/
	DELETE /api/v1/merchant/loyalty/{id}/
	"""

	permission_classes = [IsAuthenticated, IsMerchantUser, IsMerchantLoyaltyProgramOwner]
	lookup_field = "id"


class MerchantFlyerBaseMixin(MerchantShopBaseMixin):
	serializer_class = FlyerSerializer

	def get_queryset(self):
		merchant_profile = self.get_merchant_profile()
		queryset = Flyer.objects.select_related("shop", "shop__merchant").filter(
			shop__merchant=merchant_profile,
		)

		shop_id = self.kwargs.get("shop_id")
		if shop_id is not None:
			queryset = queryset.filter(shop_id=shop_id)

		return queryset.order_by("-updated_at", "-id")

	def get_shop(self):
		if not hasattr(self, "_shop"):
			merchant_profile = self.get_merchant_profile()
			self._shop = generics.get_object_or_404(
				Shop.objects.filter(merchant=merchant_profile),
				id=self.kwargs["shop_id"],
			)

		return self._shop


class MerchantShopFlyerListCreateView(MerchantFlyerBaseMixin, generics.ListCreateAPIView):
	"""
	POST /api/v1/merchant/shops/{shop_id}/flyers/
	GET /api/v1/merchant/shops/{shop_id}/flyers/
	"""

	permission_classes = [IsAuthenticated, IsMerchantUser]

	def get_queryset(self):
		self.get_shop()
		return super().get_queryset()

	def perform_create(self, serializer):
		serializer.save(shop=self.get_shop())


class MerchantFlyerDetailView(MerchantFlyerBaseMixin, generics.RetrieveUpdateDestroyAPIView):
	"""
	GET /api/v1/merchant/flyers/{id}/
	PUT /api/v1/merchant/flyers/{id}/
	PATCH /api/v1/merchant/flyers/{id}/
	DELETE /api/v1/merchant/flyers/{id}/
	"""

	permission_classes = [IsAuthenticated, IsMerchantUser, IsMerchantFlyerOwner]
	lookup_field = "id"
