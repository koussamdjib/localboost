from rest_framework import serializers

from apps.flyers.models import Flyer, FlyerFormat, FlyerStatus


class FlyerSerializer(serializers.ModelSerializer):
    shop_id = serializers.IntegerField(read_only=True)
    store_name = serializers.CharField(source="shop.name", read_only=True)
    store_logo_url = serializers.CharField(source="shop.logo_url", read_only=True)
    category = serializers.CharField(source="shop.category", read_only=True)
    latitude = serializers.SerializerMethodField()
    longitude = serializers.SerializerMethodField()
    file_type = serializers.ChoiceField(source="file_format", choices=FlyerFormat.choices)
    valid_until = serializers.SerializerMethodField()
    file_url = serializers.URLField(required=False, allow_blank=True)

    class Meta:
        model = Flyer
        fields = [
            "id",
            "shop_id",
            "store_name",
            "store_logo_url",
            "category",
            "title",
            "description",
            "file_type",
            "file",
            "file_url",
            "thumbnail_url",
            "status",
            "published_at",
            "starts_at",
            "ends_at",
            "valid_until",
            "view_count",
            "share_count",
            "latitude",
            "longitude",
            "created_at",
            "updated_at",
        ]
        read_only_fields = [
            "id",
            "shop_id",
            "store_name",
            "store_logo_url",
            "category",
            "published_at",
            "valid_until",
            "view_count",
            "share_count",
            "latitude",
            "longitude",
            "created_at",
            "updated_at",
        ]
        extra_kwargs = {
            "description": {"required": False, "allow_blank": True},
            "file": {"required": False, "allow_null": True},
            "file_url": {"required": False, "allow_blank": True},
            "thumbnail_url": {"required": False, "allow_blank": True},
            "status": {"required": False},
            "starts_at": {"required": False, "allow_null": True},
            "ends_at": {"required": False, "allow_null": True},
        }

    def validate_file_type(self, value):
        valid_values = {choice[0] for choice in FlyerFormat.choices}
        if value not in valid_values:
            raise serializers.ValidationError("Invalid flyer file type.")
        return value

    def validate_status(self, value):
        valid_values = {choice[0] for choice in FlyerStatus.choices}
        if value not in valid_values:
            raise serializers.ValidationError("Invalid flyer status.")
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
        validated_data.setdefault("status", FlyerStatus.DRAFT)
        return super().create(validated_data)

    def to_representation(self, instance):
        representation = super().to_representation(instance)

        if instance.file:
            file_url = instance.file.url
            request = self.context.get("request")
            if request is not None:
                file_url = request.build_absolute_uri(file_url)
            representation["file_url"] = file_url
        elif not representation.get("file_url"):
            representation["file_url"] = ""

        return representation

    def get_latitude(self, obj):
        if obj.shop.latitude is None:
            return 0.0
        return float(obj.shop.latitude)

    def get_longitude(self, obj):
        if obj.shop.longitude is None:
            return 0.0
        return float(obj.shop.longitude)

    def get_valid_until(self, obj):
        if obj.ends_at is None:
            return "Validité non précisée"

        local_end = obj.ends_at
        return f"Valable jusqu'au {local_end.day:02d}/{local_end.month:02d}/{local_end.year:04d}"