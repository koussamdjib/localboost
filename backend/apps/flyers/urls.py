from django.urls import path

from apps.flyers.views import FlyerListView

urlpatterns = [
    path("", FlyerListView.as_view(), name="flyer-list"),
]