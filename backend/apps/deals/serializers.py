from rest_framework import serializers

from apps.deals.models import Deal, DealStatus, DealType


class MerchantDealSerializer(serializers.ModelSerializer):
    shop_id = serializers.IntegerField(read_only=True)
    image = serializers.ImageField(required=False, allow_null=True)
    enrollment_count = serializers.SerializerMethodField()
    redemption_count = serializers.SerializerMethodField()
    view_count = serializers.SerializerMethodField()
    share_count = serializers.SerializerMethodField()

    class Meta:
        model = Deal
        fields = [
            "id",
            "shop_id",
            "title",
            "description",
            "deal_type",
            "status",
            "image",
            "starts_at",
            "ends_at",
            "max_redemptions",
            "enrollment_count",
            "redemption_count",
            "view_count",
            "share_count",
            "created_at",
            "updated_at",
        ]
        read_only_fields = [
            "id",
            "shop_id",
            "created_at",
            "updated_at",
        ]
        extra_kwargs = {
            "status": {"required": False},
            "image": {"required": False},
            "max_redemptions": {"required": False, "allow_null": True},
        }

    def validate_deal_type(self, value):
        valid_values = {choice[0] for choice in DealType.choices}
        if value not in valid_values:
            raise serializers.ValidationError("Invalid deal type.")
        return value

    def validate_status(self, value):
        valid_values = {choice[0] for choice in DealStatus.choices}
        if value not in valid_values:
            raise serializers.ValidationError("Invalid deal status.")
        return value

    def validate_max_redemptions(self, value):
        if value is not None and value < 1:
            raise serializers.ValidationError("Max redemptions must be at least 1.")
        return value

    def validate(self, attrs):
        starts_at = attrs.get("starts_at")
        ends_at = attrs.get("ends_at")

        if self.instance is not None:
            if starts_at is None:
                starts_at = self.instance.starts_at
            if ends_at is None:
                ends_at = self.instance.ends_at

        if starts_at is not None and ends_at is not None and ends_at <= starts_at:
            raise serializers.ValidationError(
                {"ends_at": "End time must be after start time."}
            )

        return attrs

    def create(self, validated_data):
        validated_data.setdefault("status", DealStatus.DRAFT)
        return super().create(validated_data)

    def get_enrollment_count(self, obj):
        annotated_count = getattr(obj, "enrollment_count", None)
        if annotated_count is not None:
            return int(annotated_count)

        return obj.redemptions.values("enrollment_id").distinct().count()

    def get_redemption_count(self, obj):
        annotated_count = getattr(obj, "redemption_count", None)
        if annotated_count is not None:
            return int(annotated_count)

        return obj.redemptions.count()

    def get_view_count(self, obj):
        return int(getattr(obj, "view_count", 0) or 0)

    def get_share_count(self, obj):
        return int(getattr(obj, "share_count", 0) or 0)


class PublicDealSerializer(MerchantDealSerializer):
    """
    Serializer for public deal discovery endpoints.
    Extends MerchantDealSerializer with embedded shop info so clients
    can render deal cards without a separate shop API call.
    """
    shop_name = serializers.SerializerMethodField()
    shop_logo_url = serializers.SerializerMethodField()
    shop_category = serializers.SerializerMethodField()

    class Meta(MerchantDealSerializer.Meta):
        fields = MerchantDealSerializer.Meta.fields + [
            "shop_name",
            "shop_logo_url",
            "shop_category",
        ]

    def get_shop_name(self, obj):
        return obj.shop.name if obj.shop_id else ""

    def get_shop_logo_url(self, obj):
        return obj.shop.logo_url if obj.shop_id else ""

    def get_shop_category(self, obj):
        return obj.shop.category if obj.shop_id else ""