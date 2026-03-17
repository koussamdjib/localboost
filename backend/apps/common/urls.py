from django.urls import path

from apps.common.views import CacheHealthCheckView, DatabaseHealthCheckView, HealthCheckView

urlpatterns = [
    path("", HealthCheckView.as_view(), name="health-check"),
    path("db/", DatabaseHealthCheckView.as_view(), name="health-db"),
    path("cache/", CacheHealthCheckView.as_view(), name="health-cache"),
]
