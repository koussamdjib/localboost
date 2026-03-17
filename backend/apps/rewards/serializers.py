from rest_framework import serializers

from apps.rewards.models import RedemptionStatus, RewardRedemption


class RewardRequestCreateSerializer(serializers.Serializer):
    enrollment_id = serializers.IntegerField(min_value=1)


class RewardRedemptionSerializer(serializers.ModelSerializer):
    enrollment_id = serializers.IntegerField(read_only=True)
    shop_id = serializers.SerializerMethodField()
    shop_name = serializers.SerializerMethodField()
    customer_user_id = serializers.SerializerMethodField()
    approved_by_user_id = serializers.SerializerMethodField()
    requested_at = serializers.DateTimeField(source="created_at", read_only=True)

    class Meta:
        model = RewardRedemption
        fields = [
            "id",
            "enrollment_id",
            "shop_id",
            "shop_name",
            "customer_user_id",
            "reward_label",
            "status",
            "approved_by_user_id",
            "requested_at",
            "redeemed_at",
            "updated_at",
        ]
        read_only_fields = fields

    def get_shop_id(self, obj):
        return int(obj.enrollment.loyalty_program.shop_id)

    def get_shop_name(self, obj):
        return obj.enrollment.loyalty_program.shop.name

    def get_customer_user_id(self, obj):
        return str(obj.enrollment.customer.user_id)

    def get_approved_by_user_id(self, obj):
        if obj.approved_by_id is None:
            return None
        return str(obj.approved_by_id)

    def validate_status(self, value):
        valid_values = {choice[0] for choice in RedemptionStatus.choices}
        if value not in valid_values:
            raise serializers.ValidationError("Invalid redemption status.")
        return value
