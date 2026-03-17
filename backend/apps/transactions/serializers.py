from rest_framework import serializers

from apps.transactions.models import StampTransaction


class TransactionHistoryItemSerializer(serializers.Serializer):
    id = serializers.CharField()
    user_id = serializers.CharField()
    shop_id = serializers.CharField()
    shop_name = serializers.CharField()
    shop_logo_url = serializers.CharField(allow_blank=True)
    type = serializers.ChoiceField(
        choices=[
            "stampCollected",
            "rewardRedeemed",
            "enrolled",
            "unenrolled",
        ]
    )
    timestamp = serializers.DateTimeField()
    stamps_added = serializers.IntegerField(required=False, allow_null=True)
    reward_value = serializers.CharField(required=False, allow_null=True, allow_blank=True)
    merchant_note = serializers.CharField(required=False, allow_null=True, allow_blank=True)
    location = serializers.CharField(required=False, allow_null=True, allow_blank=True)


class StampHistoryItemSerializer(serializers.ModelSerializer):
    collected_at = serializers.DateTimeField(source="created_at", read_only=True)
    merchant_note = serializers.SerializerMethodField()
    location = serializers.SerializerMethodField()
    stamps_added = serializers.IntegerField(source="quantity", read_only=True)

    class Meta:
        model = StampTransaction
        fields = [
            "id",
            "collected_at",
            "merchant_note",
            "location",
            "stamps_added",
        ]

    def get_merchant_note(self, obj):
        note = (obj.notes or "").strip()
        if note:
            return note

        quantity = int(obj.quantity or 1)
        return "1 timbre ajouté" if quantity == 1 else f"{quantity} timbres ajoutés"

    def get_location(self, obj):
        shop = obj.enrollment.loyalty_program.shop
        parts = [shop.city, shop.country]
        label = ", ".join([part for part in parts if part])
        return label or None
