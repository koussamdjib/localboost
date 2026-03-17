import math

from django.db.models import Exists, OuterRef, Prefetch
from django.utils import timezone
from rest_framework import generics, permissions
from rest_framework.exceptions import ValidationError
from rest_framework.pagination import LimitOffsetPagination
from rest_framework.response import Response

from apps.deals.models import Deal, DealStatus
from apps.loyalty.models import LoyaltyProgram
from apps.shops.models import Shop, ShopStatus
from apps.shops.serializers import ShopDiscoverySerializer
from apps.shops.services import haversine_distance_km


class DiscoveryPagination(LimitOffsetPagination):
    default_limit = 20
    max_limit = 100


class ShopDiscoveryBaseMixin:
	permission_classes = [permissions.AllowAny]
	serializer_class = ShopDiscoverySerializer
	pagination_class = DiscoveryPagination

	def get_base_queryset(self):
		now = timezone.now()
		active_deals = Deal.objects.filter(
			shop_id=OuterRef("pk"),
			status=DealStatus.PUBLISHED,
			starts_at__lte=now,
			ends_at__gte=now,
		)
		active_loyalty_programs = LoyaltyProgram.objects.filter(
			shop_id=OuterRef("pk"),
			is_active=True,
		)

		return (
			Shop.objects.filter(
				is_active=True,
				status=ShopStatus.ACTIVE,
			)
			.select_related("merchant")
			.prefetch_related(
				Prefetch(
					"loyalty_programs",
					queryset=LoyaltyProgram.objects.filter(is_active=True).order_by("id"),
					to_attr="active_loyalty_programs",
				)
			)
			.annotate(
				has_active_deals=Exists(active_deals),
				has_loyalty_programs=Exists(active_loyalty_programs),
			)
		)

	def get_serializer_context(self):
		context = super().get_serializer_context()
		context["include_distance"] = getattr(self, "_include_distance", False)
		return context

	def _parse_float_param(self, name, *, required=False):
		raw_value = self.request.query_params.get(name)

		if raw_value in (None, ""):
			if required:
				raise ValidationError({name: f"Query parameter '{name}' is required."})
			return None

		try:
			return float(raw_value)
		except ValueError as exc:
			raise ValidationError({name: f"Query parameter '{name}' must be a number."}) from exc

	def _get_location_search_params(self):
		latitude = self._parse_float_param("latitude")
		longitude = self._parse_float_param("longitude")

		radius_km = self.request.query_params.get("radius")
		if radius_km in (None, ""):
			radius_km = self.request.query_params.get("radius_km")

		if radius_km in (None, ""):
			radius = None
		else:
			try:
				radius = float(radius_km)
			except ValueError as exc:
				raise ValidationError({"radius": "Query parameter 'radius' must be a number."}) from exc

			if radius <= 0:
				raise ValidationError({"radius": "Query parameter 'radius' must be greater than 0."})

		if (latitude is None) != (longitude is None):
			raise ValidationError(
				{
					"location": (
						"Both 'latitude' and 'longitude' are required when searching by location."
					)
				}
			)

		return latitude, longitude, radius

	def _apply_text_filters(self, queryset):
		name_query = (
			self.request.query_params.get("search")
			or self.request.query_params.get("q")
			or self.request.query_params.get("name")
		)
		category_query = self.request.query_params.get("category")

		if name_query:
			queryset = queryset.filter(name__icontains=name_query.strip())

		if category_query:
			queryset = queryset.filter(category__icontains=category_query.strip())

		return queryset

	def _bbox_filter(self, queryset, latitude, longitude, radius_km):
		"""
		Cheap SQL bounding-box pre-filter before the Python haversine loop.
		Cuts the number of rows fetched from DB when a radius is given.
		1 degree ≈ 111 km; longitude delta shrinks near poles.
		"""
		if radius_km is None:
			return queryset
		lat_delta = radius_km / 111.0
		lng_delta = radius_km / max(0.01, 111.0 * abs(math.cos(math.radians(latitude))))
		return queryset.filter(
			latitude__range=(latitude - lat_delta, latitude + lat_delta),
			longitude__range=(longitude - lng_delta, longitude + lng_delta),
		)

	def _attach_distance_and_filter(self, shops, latitude, longitude, radius_km):
		nearby_shops = []
		for shop in shops:
			if shop.latitude is None or shop.longitude is None:
				continue

			distance = haversine_distance_km(
				latitude,
				longitude,
				float(shop.latitude),
				float(shop.longitude),
			)
			shop.distance_km = distance

			if radius_km is None or distance <= radius_km:
				nearby_shops.append(shop)

		nearby_shops.sort(key=lambda item: item.distance_km)
		return nearby_shops


class ShopListView(ShopDiscoveryBaseMixin, generics.ListAPIView):
	"""
	GET /api/v1/shops/

	Returns active shops for discovery list and map screens.
	Optional query params:
	- latitude
	- longitude
	- radius or radius_km
	"""

	def get_queryset(self):
		return self.get_base_queryset().order_by("name")

	def list(self, request, *args, **kwargs):
		latitude, longitude, radius_km = self._get_location_search_params()

		queryset = self.filter_queryset(self.get_queryset())
		self._include_distance = False

		if latitude is not None and longitude is not None:
			queryset = self._bbox_filter(queryset, latitude, longitude, radius_km)
			shops = list(queryset)
			shops = self._attach_distance_and_filter(shops, latitude, longitude, radius_km)
			self._include_distance = True
		else:
			shops = list(queryset)

		page = self.paginate_queryset(shops)
		if page is not None:
			serializer = self.get_serializer(page, many=True)
			return self.get_paginated_response(serializer.data)

		serializer = self.get_serializer(shops, many=True)
		return Response(serializer.data)


class ShopSearchView(ShopDiscoveryBaseMixin, generics.ListAPIView):
	"""
	GET /api/v1/shops/search/

	Search supports:
	- name (or q)
	- category
	- latitude + longitude + optional radius
	"""

	def get_queryset(self):
		queryset = self.get_base_queryset()
		queryset = self._apply_text_filters(queryset)
		return queryset.order_by("name")

	def list(self, request, *args, **kwargs):
		latitude, longitude, radius_km = self._get_location_search_params()

		queryset = self.filter_queryset(self.get_queryset())
		self._include_distance = False

		if latitude is not None and longitude is not None:
			queryset = self._bbox_filter(queryset, latitude, longitude, radius_km)
			shops = list(queryset)
			shops = self._attach_distance_and_filter(shops, latitude, longitude, radius_km)
			self._include_distance = True
		else:
			shops = list(queryset)

		page = self.paginate_queryset(shops)
		if page is not None:
			serializer = self.get_serializer(page, many=True)
			return self.get_paginated_response(serializer.data)

		serializer = self.get_serializer(shops, many=True)
		return Response(serializer.data)


class ShopDetailView(ShopDiscoveryBaseMixin, generics.RetrieveAPIView):
	"""
	GET /api/v1/shops/{id}/

	Returns detailed active shop payload.
	Optional query params:
	- latitude
	- longitude
	"""

	lookup_field = "id"

	def get_queryset(self):
		return self.get_base_queryset()

	def retrieve(self, request, *args, **kwargs):
		latitude, longitude, _radius_km = self._get_location_search_params()

		shop = self.get_object()
		self._include_distance = False

		if (
			latitude is not None
			and longitude is not None
			and shop.latitude is not None
			and shop.longitude is not None
		):
			shop.distance_km = haversine_distance_km(
				latitude,
				longitude,
				float(shop.latitude),
				float(shop.longitude),
			)
			self._include_distance = True

		serializer = self.get_serializer(shop)
		return Response(serializer.data)
