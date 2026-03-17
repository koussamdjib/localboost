from rest_framework.permissions import BasePermission

from apps.accounts.models import UserRole


class IsMerchantUser(BasePermission):
    message = "Merchant access is required."

    def has_permission(self, request, view):
        user = request.user
        return bool(
            user
            and user.is_authenticated
            and user.role == UserRole.MERCHANT
        )


class IsMerchantShopOwner(BasePermission):
    message = "You can only manage your own shops."

    def has_object_permission(self, request, view, obj):
        user = request.user
        return bool(
            user
            and user.is_authenticated
            and obj.merchant.user_id == user.id
        )


class IsMerchantDealOwner(BasePermission):
    message = "You can only manage your own deals."

    def has_object_permission(self, request, view, obj):
        user = request.user
        return bool(
            user
            and user.is_authenticated
            and obj.shop.merchant.user_id == user.id
        )

class IsMerchantLoyaltyProgramOwner(BasePermission):
    message = "You can only manage your own loyalty programs."

    def has_object_permission(self, request, view, obj):
        user = request.user
        return bool(
            user
            and user.is_authenticated
            and obj.shop.merchant.user_id == user.id
        )


class IsMerchantFlyerOwner(BasePermission):
    message = "You can only manage your own flyers."

    def has_object_permission(self, request, view, obj):
        user = request.user
        return bool(
            user
            and user.is_authenticated
            and obj.shop.merchant.user_id == user.id
        )
