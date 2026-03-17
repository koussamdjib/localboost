from rest_framework import serializers
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.loyalty.models import LoyaltyProgram


class LoyaltyProgramSerializer(serializers.ModelSerializer):
    shop_id = serializers.IntegerField(source='shop.id', read_only=True)
    shop_name = serializers.CharField(source='shop.name', read_only=True)
    shop_logo = serializers.SerializerMethodField()
    shop_category = serializers.CharField(source='shop.category', read_only=True)

    class Meta:
        model = LoyaltyProgram
        fields = [
            'id', 'name', 'description', 'stamps_required',
            'reward_label', 'is_active', 'shop_id', 'shop_name',
            'shop_logo', 'shop_category', 'created_at', 'updated_at',
        ]

    def get_shop_logo(self, obj):
        return getattr(obj.shop, 'logo_url', None) or ''


class LoyaltyProgramListView(APIView):
    """List active loyalty programs, optionally filtered by shop or category."""
    permission_classes = [IsAuthenticated]

    def get(self, request):
        shop_id = request.query_params.get('shop_id')
        category = (request.query_params.get('category') or '').strip()
        qs = LoyaltyProgram.objects.filter(is_active=True).select_related('shop')
        if shop_id:
            qs = qs.filter(shop_id=shop_id)
        if category:
            qs = qs.filter(shop__category__icontains=category)
        qs = qs.order_by('shop__name', 'name')
        serializer = LoyaltyProgramSerializer(qs, many=True)
        return Response({'count': len(serializer.data), 'results': serializer.data})
