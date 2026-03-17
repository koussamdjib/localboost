from django.db.models import Count, F, Q
from django.utils import timezone
from rest_framework import generics, permissions, status
from rest_framework.pagination import LimitOffsetPagination
from rest_framework.response import Response

from apps.deals.models import Deal, DealStatus
from apps.deals.serializers import MerchantDealSerializer, PublicDealSerializer
from apps.shops.models import ShopStatus


class DiscoveryPagination(LimitOffsetPagination):
    default_limit = 20
    max_limit = 100


class DealListView(generics.ListAPIView):
	"""
	GET /api/v1/deals/

	Returns active published deals for public discovery.
	Optional query params:
	- q (search query)
	- category (shop category)
	- limit / offset (pagination)
	"""

	permission_classes = [permissions.AllowAny]
	serializer_class = PublicDealSerializer
	pagination_class = DiscoveryPagination

	def get_queryset(self):
		now = timezone.now()
		queryset = Deal.objects.select_related("shop", "shop__merchant").filter(
			shop__is_active=True,
			shop__status=ShopStatus.ACTIVE,
			status=DealStatus.PUBLISHED,
		)

		# Filter by active date range
		queryset = queryset.filter(
			Q(starts_at__isnull=True) | Q(starts_at__lte=now),
			Q(ends_at__isnull=True) | Q(ends_at__gte=now),
		)

		# Filter by specific shop
		shop_id = (self.request.query_params.get("shop_id") or "").strip()
		if shop_id:
			try:
				queryset = queryset.filter(shop_id=int(shop_id))
			except ValueError:
				pass

		# Search query — supports ?search=, ?q=
		query = (self.request.query_params.get("search") or self.request.query_params.get("q") or "").strip()
		if query:
			queryset = queryset.filter(
				Q(title__icontains=query)
				| Q(description__icontains=query)
				| Q(shop__name__icontains=query)
			)

		# Filter by shop category
		category = (self.request.query_params.get("category") or "").strip()
		if category:
			queryset = queryset.filter(shop__category__icontains=category)

		# Annotate enrollment/redemption counts to avoid per-object N+1 queries
		queryset = queryset.annotate(
			enrollment_count=Count("redemptions__enrollment_id", distinct=True),
			redemption_count=Count("redemptions", distinct=True),
		)

		return queryset.order_by("-starts_at", "-created_at", "-id")


class DealDetailView(generics.RetrieveAPIView):
	"""
	GET /api/v1/deals/{id}/

	Returns a single published deal detail for public discovery.
	"""

	permission_classes = [permissions.AllowAny]
	serializer_class = PublicDealSerializer
	lookup_field = "id"

	def get_queryset(self):
		now = timezone.now()
		return Deal.objects.select_related("shop", "shop__merchant").filter(
			shop__is_active=True,
			shop__status=ShopStatus.ACTIVE,
			status=DealStatus.PUBLISHED,
		).filter(
			Q(starts_at__isnull=True) | Q(starts_at__lte=now),
			Q(ends_at__isnull=True) | Q(ends_at__gte=now),
		)


class PublicDealViewTrackView(generics.GenericAPIView):
	"""
	POST /api/v1/deals/{id}/view/

	Increments view_count for a published deal.
	AllowAny — called by the client app when a user opens deal details.
	"""

	permission_classes = [permissions.AllowAny]
	lookup_field = "id"

	def get_queryset(self):
		now = timezone.now()
		return Deal.objects.filter(
			shop__is_active=True,
			shop__status=ShopStatus.ACTIVE,
			status=DealStatus.PUBLISHED,
		).filter(
			Q(starts_at__isnull=True) | Q(starts_at__lte=now),
			Q(ends_at__isnull=True) | Q(ends_at__gte=now),
		)

	def post(self, request, *args, **kwargs):
		deal = self.get_object()
		Deal.objects.filter(pk=deal.pk).update(view_count=F("view_count") + 1)
		return Response({"ok": True}, status=status.HTTP_200_OK)
