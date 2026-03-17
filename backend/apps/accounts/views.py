from rest_framework import generics, status
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView

from apps.accounts.serializers import (
    ChangePasswordSerializer,
    UserEmailUpdateSerializer,
    UserRegistrationSerializer,
    UserSerializer,
    UserUpdateSerializer,
)


class UserRegistrationView(generics.CreateAPIView):
    """
    POST /api/auth/register/
    
    Register a new user account.
    Creates user and customer profile automatically.
    
    Request body:
    {
        "email": "user@example.com",
        "password": "securepassword123",
        "name": "John Doe",  // optional
        "phone_number": "+253 99 88 77 66"  // optional
    }
    
    Response:
    {
        "id": "uuid",
        "email": "user@example.com",
        "name": "John Doe",
        "phone_number": "+253 99 88 77 66",
        "qr_code_id": "uuid",
        "created_at": "2026-03-10T...",
        "last_login": null,
        "total_stamps": 0,
        "total_rewards_redeemed": 0,
        "total_offers_joined": 0
    }
    """

    permission_classes = [AllowAny]
    serializer_class = UserRegistrationSerializer

    def create(self, request, *args, **kwargs):
        """Create user and return full user data."""
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()

        # Return full user data using UserSerializer
        user_serializer = UserSerializer(user)
        headers = self.get_success_headers(user_serializer.data)
        return Response(
            user_serializer.data,
            status=status.HTTP_201_CREATED,
            headers=headers,
        )


class CurrentUserView(APIView):
    """
    GET /api/auth/me/
    Retrieve current authenticated user profile.
    
    PUT /api/auth/me/
    Update current user profile (name, phone_number).
    
    DELETE /api/auth/me/
    Delete current user account.
    """

    permission_classes = [IsAuthenticated]

    def get(self, request):
        """
        Get current user profile.
        
        Response:
        {
            "id": "uuid",
            "email": "user@example.com",
            "name": "John Doe",
            "phone_number": "+253 99 88 77 66",
            "qr_code_id": "uuid",
            "created_at": "2026-03-10T...",
            "last_login": "2026-03-10T...",
            "total_stamps": 5,
            "total_rewards_redeemed": 2,
            "total_offers_joined": 3
        }
        """
        serializer = UserSerializer(request.user)
        return Response(serializer.data)

    def put(self, request):
        """
        Update user profile.
        
        Request body:
        {
            "name": "Updated Name",
            "phone_number": "+253 11 22 33 44"
        }
        
        Response: Updated user data (same as GET)
        """
        serializer = UserUpdateSerializer(
            request.user,
            data=request.data,
            partial=True,
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()

        # Return full user data
        user_serializer = UserSerializer(request.user)
        return Response(user_serializer.data)

    def delete(self, request):
        """
        Delete user account.
        
        Response: 204 No Content
        """
        user = request.user
        user.is_active = False
        user.save(update_fields=["is_active"])
        # Could also use: user.delete() for hard delete
        return Response(status=status.HTTP_204_NO_CONTENT)


class CurrentUserEmailUpdateView(APIView):
    """
    POST /api/auth/me/email/

    Update current user's email with password confirmation.
    """

    permission_classes = [IsAuthenticated]

    def post(self, request):
        serializer = UserEmailUpdateSerializer(
            data=request.data,
            context={"request": request},
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()

        user_serializer = UserSerializer(request.user)
        return Response(
            {
                "message": "Email updated successfully.",
                "user": user_serializer.data,
            },
            status=status.HTTP_200_OK,
        )


class ChangePasswordView(APIView):
    """
    POST /api/auth/me/password/
    
    Change user password.
    Requires old password for verification.
    
    Request body:
    {
        "old_password": "current_password",
        "new_password": "new_secure_password"
    }
    
    Response:
    {
        "message": "Password changed successfully."
    }
    """

    permission_classes = [IsAuthenticated]

    def post(self, request):
        """Change user password."""
        serializer = ChangePasswordSerializer(
            data=request.data,
            context={"request": request},
        )
        serializer.is_valid(raise_exception=True)
        serializer.save()

        return Response(
            {"message": "Password changed successfully."},
            status=status.HTTP_200_OK,
        )
