from django.urls import path

from apps.rewards.views import (
    RewardRequestApproveView,
    RewardRequestDetailView,
    RewardRequestFulfillView,
    RewardRequestListCreateView,
    RewardRequestRejectView,
)

urlpatterns = [
    path("requests/", RewardRequestListCreateView.as_view(), name="reward-request-list-create"),
    path("requests/<int:id>/", RewardRequestDetailView.as_view(), name="reward-request-detail"),
    path(
        "requests/<int:id>/approve/",
        RewardRequestApproveView.as_view(),
        name="reward-request-approve",
    ),
    path(
        "requests/<int:id>/reject/",
        RewardRequestRejectView.as_view(),
        name="reward-request-reject",
    ),
    path(
        "requests/<int:id>/fulfill/",
        RewardRequestFulfillView.as_view(),
        name="reward-request-fulfill",
    ),
]
