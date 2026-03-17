from django.urls import path

from apps.merchants.analytics_views import CustomerAnalyticsView
from apps.merchants.views import (
    MerchantDealDetailView,
    MerchantDealShareTrackView,
    MerchantDealViewTrackView,
    MerchantFlyerDetailView,
    MerchantShopDealListCreateView,
    MerchantShopDetailView,
    MerchantShopFlyerListCreateView,
    MerchantShopListCreateView,
    MerchantLoyaltyDetailView,
    MerchantShopLoyaltyListCreateView,
)

urlpatterns = [
    path("shops/", MerchantShopListCreateView.as_view(), name="merchant-shop-list-create"),
    path("shops/<int:id>/", MerchantShopDetailView.as_view(), name="merchant-shop-detail"),
    path(
        "shops/<int:shop_id>/deals/",
        MerchantShopDealListCreateView.as_view(),
        name="merchant-shop-deal-list-create",
    ),
    path(
        "shops/<int:shop_id>/flyers/",
        MerchantShopFlyerListCreateView.as_view(),
        name="merchant-shop-flyer-list-create",
    ),
    path(
        "shops/<int:shop_id>/loyalty/",
        MerchantShopLoyaltyListCreateView.as_view(),
        name="merchant-shop-loyalty-list-create",
    ),
    path("deals/<int:id>/", MerchantDealDetailView.as_view(), name="merchant-deal-detail"),
    path("flyers/<int:id>/", MerchantFlyerDetailView.as_view(), name="merchant-flyer-detail"),
    path("loyalty/<int:id>/", MerchantLoyaltyDetailView.as_view(), name="merchant-loyalty-detail"),
    path("deals/<int:id>/view/", MerchantDealViewTrackView.as_view(), name="merchant-deal-view-track"),
    path("deals/<int:id>/share/", MerchantDealShareTrackView.as_view(), name="merchant-deal-share-track"),
    path("analytics/customers/", CustomerAnalyticsView.as_view(), name="merchant-analytics-customers"),
]
