from django.urls import path

from apps.notifications.views import (
    NotificationDetailView,
    NotificationListView,
    NotificationMarkAllReadView,
)

urlpatterns = [
    path("", NotificationListView.as_view(), name="notification-list"),
    path("read-all/", NotificationMarkAllReadView.as_view(), name="notification-read-all"),
    path("<int:pk>/", NotificationDetailView.as_view(), name="notification-detail"),
]
