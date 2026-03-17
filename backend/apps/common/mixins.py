"""Shared Django mixins for API views."""
from rest_framework.exceptions import PermissionDenied

from apps.customers.models import CustomerProfile
from apps.merchants.models import MerchantProfile


class ProfileAccessMixin:
    """Provides common profile accessor methods for API views."""

    def _customer_profile_for_user(self, user):
        """Get customer profile for authenticated user."""
        try:
            return user.customer_profile
        except CustomerProfile.DoesNotExist as exc:
            raise PermissionDenied("Customer profile is required.") from exc

    def _merchant_profile_for_user(self, user):
        """Get merchant profile for authenticated user."""
        try:
            return user.merchant_profile
        except MerchantProfile.DoesNotExist as exc:
            raise PermissionDenied("Merchant profile is required.") from exc
