from django.urls import path

from apps.deals.views import DealDetailView, DealListView, PublicDealViewTrackView

urlpatterns = [
    path("", DealListView.as_view(), name="deal-list"),
    path("<int:id>/", DealDetailView.as_view(), name="deal-detail"),
    path("<int:id>/view/", PublicDealViewTrackView.as_view(), name="deal-view-track"),
]
