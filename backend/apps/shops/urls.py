from django.urls import path

from apps.shops.views import ShopDetailView, ShopListView, ShopSearchView

urlpatterns = [
    path("", ShopListView.as_view(), name="shop-list"),
    path("search/", ShopSearchView.as_view(), name="shop-search"),
    path("<int:id>/", ShopDetailView.as_view(), name="shop-detail"),
]
