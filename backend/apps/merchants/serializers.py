from django.utils.text import slugify
from rest_framework import serializers

from apps.shops.models import Shop, ShopStatus


class MerchantShopSerializer(serializers.ModelSerializer):
    merchant_profile = serializers.IntegerField(source="merchant_id", read_only=True)
    address = serializers.CharField(source="address_line_1")
    logo = serializers.URLField(source="logo_url", allow_blank=True, required=False)
    cover_image = serializers.URLField(
        source="cover_image_url", allow_blank=True, required=False
    )

    class Meta:
        model = Shop
        fields = [
            "id",
            "merchant_profile",
            "name",
            "slug",
            "description",
            "category",
            "phone_number",
            "email",
            "business_hours",
            "address",
            "address_line_2",
            "city",
            "country",
            "latitude",
            "longitude",
            "logo",
            "cover_image",
            "status",
            "is_active",
            "created_at",
            "updated_at",
        ]
        read_only_fields = [
            "id",
            "merchant_profile",
            "is_active",
            "created_at",
            "updated_at",
        ]
        extra_kwargs = {
            "slug": {"required": False, "allow_blank": True},
            "description": {"required": False, "allow_blank": True},
            "category": {"required": False, "allow_blank": True},
            "phone_number": {"required": False, "allow_blank": True},
            "email": {"required": False, "allow_blank": True},
            "business_hours": {"required": False},
            "address_line_2": {"required": False, "allow_blank": True},
            "city": {"required": False, "allow_blank": True},
            "country": {"required": False, "allow_blank": True},
            "latitude": {"required": False, "allow_null": True},
            "longitude": {"required": False, "allow_null": True},
            "status": {"required": False},
        }

    def validate_status(self, value):
        valid_values = {choice[0] for choice in ShopStatus.choices}
        if value not in valid_values:
            raise serializers.ValidationError("Invalid shop status.")
        return value

    def validate_slug(self, value):
        if not value:
            return value

        normalized_slug = slugify(value)
        if not normalized_slug:
            raise serializers.ValidationError("Slug must contain letters or numbers.")

        queryset = Shop.objects.filter(slug=normalized_slug)
        if self.instance is not None:
            queryset = queryset.exclude(pk=self.instance.pk)
        if queryset.exists():
            raise serializers.ValidationError("A shop with this slug already exists.")

        return normalized_slug

    def _ensure_unique_slug(self, base_text):
        base_slug = slugify(base_text) or "shop"
        slug = base_slug
        counter = 2

        while Shop.objects.filter(slug=slug).exists():
            slug = f"{base_slug}-{counter}"
            counter += 1

        return slug

    def _apply_location_defaults(self, attrs):
        if self.instance is None:
            attrs.setdefault("city", "Djibouti")
            attrs.setdefault("country", "Djibouti")

    def _sync_public_active_flag(self, attrs):
        status_value = attrs.get("status")
        if status_value is not None:
            attrs["is_active"] = status_value == ShopStatus.ACTIVE

    def create(self, validated_data):
        self._apply_location_defaults(validated_data)

        if not validated_data.get("slug"):
            validated_data["slug"] = self._ensure_unique_slug(validated_data.get("name", "shop"))

        validated_data.setdefault("status", ShopStatus.DRAFT)
        self._sync_public_active_flag(validated_data)

        return super().create(validated_data)

    def update(self, instance, validated_data):
        if "slug" in validated_data and not validated_data["slug"]:
            validated_data.pop("slug")

        self._sync_public_active_flag(validated_data)

        return super().update(instance, validated_data)
