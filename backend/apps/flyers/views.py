from django.db.models import Q
from django.utils import timezone
from rest_framework import generics, permissions
from rest_framework.pagination import LimitOffsetPagination

from apps.flyers.models import Flyer, FlyerStatus
from apps.flyers.serializers import FlyerSerializer
from apps.shops.models import ShopStatus


class DiscoveryPagination(LimitOffsetPagination):
    default_limit = 20
    max_limit = 100


class FlyerListView(generics.ListAPIView):
	"""
	GET /api/v1/flyers/

	Returns active published flyers for public discovery.
	Optional query params:
	- q
	- category
	- limit / offset (pagination)
	"""

	permission_classes = [permissions.AllowAny]
	serializer_class = FlyerSerializer
	pagination_class = DiscoveryPagination

	def get_queryset(self):
		now = timezone.now()
		queryset = Flyer.objects.select_related("shop", "shop__merchant").filter(
			shop__is_active=True,
			shop__status=ShopStatus.ACTIVE,
			status=FlyerStatus.PUBLISHED,
			is_active=True,
		)
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

		query = (self.request.query_params.get("search") or self.request.query_params.get("q") or "").strip()
		if query:
			queryset = queryset.filter(
				Q(title__icontains=query)
				| Q(description__icontains=query)
				| Q(shop__name__icontains=query)
			)

		category = (self.request.query_params.get("category") or "").strip()
		if category:
			queryset = queryset.filter(shop__category__icontains=category)

		return queryset.order_by("-published_at", "-created_at", "-id")
