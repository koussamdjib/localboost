from rest_framework import serializers
from django.utils import timezone

from apps.deals.models import Deal, DealStatus
from apps.loyalty.models import LoyaltyProgram
from apps.shops.models import Shop


class ShopDiscoverySerializer(serializers.ModelSerializer):
    address = serializers.SerializerMethodField()
    latitude = serializers.SerializerMethodField()
    longitude = serializers.SerializerMethodField()
    has_active_deals = serializers.SerializerMethodField()
    has_loyalty_programs = serializers.SerializerMethodField()
    loyalty_programs = serializers.SerializerMethodField()
    distance_km = serializers.SerializerMethodField()

    class Meta:
        model = Shop
        fields = [
            "id",
            "name",
            "slug",
            "description",
            "category",
            "logo_url",
            "cover_image_url",
            "phone_number",
            "address",
            "latitude",
            "longitude",
            "is_active",
            "has_active_deals",
            "has_loyalty_programs",
            "loyalty_programs",
            "distance_km",
        ]

    def to_representation(self, instance):
        data = super().to_representation(instance)
        if not self.context.get("include_distance", False):
            data.pop("distance_km", None)
        return data

    def get_address(self, obj):
        parts = [obj.address_line_1]
        if obj.address_line_2:
            parts.append(obj.address_line_2)
        parts.append(obj.city)
        parts.append(obj.country)
        return ", ".join(part for part in parts if part)

    def get_latitude(self, obj):
        if obj.latitude is None:
            return None
        return float(obj.latitude)

    def get_longitude(self, obj):
        if obj.longitude is None:
            return None
        return float(obj.longitude)

    def get_has_active_deals(self, obj):
        annotated = getattr(obj, "has_active_deals", None)
        if annotated is not None:
            return bool(annotated)

        now = timezone.now()
        return Deal.objects.filter(
            shop=obj,
            status=DealStatus.PUBLISHED,
            starts_at__lte=now,
            ends_at__gte=now,
        ).exists()

    def get_has_loyalty_programs(self, obj):
        annotated = getattr(obj, "has_loyalty_programs", None)
        if annotated is not None:
            return bool(annotated)

        return LoyaltyProgram.objects.filter(shop=obj, is_active=True).exists()

    def get_loyalty_programs(self, obj):
        # Use prefetched attribute set by the view queryset to avoid N+1.
        programs = getattr(obj, "active_loyalty_programs", None)
        if programs is None:
            programs = LoyaltyProgram.objects.filter(shop=obj, is_active=True).order_by("id")
        return [
            {
                "id": p.id,
                "name": p.name,
                "stamps_required": p.stamps_required,
                "reward_label": p.reward_label,
            }
            for p in programs
        ]

    def get_distance_km(self, obj):
        distance = getattr(obj, "distance_km", None)
        if distance is None:
            return None
        return round(float(distance), 3)
