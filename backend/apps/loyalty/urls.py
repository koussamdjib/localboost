from django.urls import path

from apps.loyalty.views import LoyaltyProgramListView

urlpatterns = [
    path("", LoyaltyProgramListView.as_view(), name="loyalty-program-list"),
]
