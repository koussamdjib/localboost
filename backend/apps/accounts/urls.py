from django.urls import path
from rest_framework.permissions import AllowAny
from rest_framework.throttling import AnonRateThrottle
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView

from apps.accounts.views import (
    ChangePasswordView,
    CurrentUserEmailUpdateView,
    CurrentUserView,
    UserRegistrationView,
)


class LoginRateThrottle(AnonRateThrottle):
    scope = "login"


class PublicTokenObtainPairView(TokenObtainPairView):
    permission_classes = [AllowAny]
    throttle_classes = [LoginRateThrottle]


class PublicTokenRefreshView(TokenRefreshView):
    permission_classes = [AllowAny]


urlpatterns = [
    # JWT Token endpoints (already implemented by SimpleJWT)
    path("token/", PublicTokenObtainPairView.as_view(), name="token-obtain-pair"),
    path("token/refresh/", PublicTokenRefreshView.as_view(), name="token-refresh"),
    # User registration
    path("register/", UserRegistrationView.as_view(), name="user-register"),
    # Current user endpoints
    path("me/", CurrentUserView.as_view(), name="current-user"),
    path("me/email/", CurrentUserEmailUpdateView.as_view(), name="current-user-email-update"),
    path("me/password/", ChangePasswordView.as_view(), name="change-password"),
]
