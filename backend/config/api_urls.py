from django.urls import include, path

urlpatterns = [
    path("health/", include("apps.common.urls")),
    path("auth/", include("apps.accounts.urls")),
    path("deals/", include("apps.deals.urls")),
    path("flyers/", include("apps.flyers.urls")),
    path("shops/", include("apps.shops.urls")),
    path("merchant/", include("apps.merchants.urls")),
    path("enrollments/", include("apps.enrollments.urls")),
    path("rewards/", include("apps.rewards.urls")),
    path("transactions/", include("apps.transactions.urls")),
    path("notifications/", include("apps.notifications.urls")),
    path("customers/", include("apps.customers.urls")),
    path("loyalty/", include("apps.loyalty.urls")),
]
