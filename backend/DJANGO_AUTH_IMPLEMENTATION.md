# Django Backend - Auth Endpoints Implementation Example

This file provides reference implementations for the authentication endpoints required by the Flutter client.

## Prerequisites

```bash
# Install Django REST Framework (if not already installed)
pip install djangorestframework djangorestframework-simplejwt

# Update backend/requirements.txt
echo "djangorestframework>=3.14.0" >> requirements.txt
echo "djangorestframework-simplejwt>=5.3.0" >> requirements.txt
```

## 1. Serializers

Create `backend/apps/accounts/serializers.py`:

```python
from rest_framework import serializers
from django.contrib.auth import get_user_model
from apps.accounts.models import User

class UserSerializer(serializers.ModelSerializer):
    """Serializer for User model (read operations)"""
    
    total_stamps = serializers.SerializerMethodField()
    total_rewards_redeemed = serializers.SerializerMethodField()
    total_offers_joined = serializers.SerializerMethodField()
    qr_code_id = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = [
            'id',
            'email',
            'username',  # Map to 'name' in Flutter
            'phone_number',
            'qr_code_id',
            'created_at',
            'last_login',
            'total_stamps',
            'total_rewards_redeemed',
            'total_offers_joined',
        ]
        read_only_fields = [
            'id',
            'created_at',
            'qr_code_id',
            'total_stamps',
            'total_rewards_redeemed',
            'total_offers_joined',
        ]
    
    def get_qr_code_id(self, obj):
        """Generate QR code ID for user"""
        return f"LOCALBOOST-DJIBOUTI-USER-{str(obj.id).split('-')[-1][:8].upper()}"
    
    def get_total_stamps(self, obj):
        """Calculate total stamps from enrollments"""
        if hasattr(obj, 'customer_profile'):
            return obj.customer_profile.enrollments.aggregate(
                total=models.Sum('stamps_count')
            )['total'] or 0
        return 0
    
    def get_total_rewards_redeemed(self, obj):
        """Calculate total rewards redeemed"""
        # TODO: Implement based on your Transaction model
        return 0
    
    def get_total_offers_joined(self, obj):
        """Count active enrollments"""
        if hasattr(obj, 'customer_profile'):
            return obj.customer_profile.enrollments.filter(
                status='active'
            ).count()
        return 0
    
    def to_representation(self, instance):
        """Map Django field names to Flutter expectations"""
        ret = super().to_representation(instance)
        # Map 'username' to 'name' for Flutter
        ret['name'] = ret.pop('username', instance.username)
        return ret


class UserRegistrationSerializer(serializers.ModelSerializer):
    """Serializer for user registration"""
    
    password = serializers.CharField(
        write_only=True,
        min_length=8,
        style={'input_type': 'password'}
    )
    name = serializers.CharField(source='username')  # Map Flutter 'name' to Django 'username'
    
    class Meta:
        model = User
        fields = ['email', 'password', 'name', 'phone_number']
    
    def create(self, validated_data):
        """Create user with hashed password"""
        user = User.objects.create_user(
            email=validated_data['email'],
            username=validated_data['username'],
            password=validated_data['password'],
            phone_number=validated_data.get('phone_number', ''),
        )
        
        # Create associated customer profile (if using separate profile model)
        # from apps.customers.models import CustomerProfile
        # CustomerProfile.objects.create(user=user)
        
        return user


class UserUpdateSerializer(serializers.ModelSerializer):
    """Serializer for updating user profile"""
    
    name = serializers.CharField(source='username', required=False)
    
    class Meta:
        model = User
        fields = ['name', 'email', 'phone_number']
    
    def update(self, instance, validated_data):
        """Update user profile"""
        instance.username = validated_data.get('username', instance.username)
        instance.email = validated_data.get('email', instance.email)
        instance.phone_number = validated_data.get('phone_number', instance.phone_number)
        instance.save()
        return instance


class ChangePasswordSerializer(serializers.Serializer):
    """Serializer for password change"""
    
    old_password = serializers.CharField(required=True, write_only=True)
    new_password = serializers.CharField(
        required=True,
        write_only=True,
        min_length=8
    )
    
    def validate_old_password(self, value):
        """Validate old password is correct"""
        user = self.context['request'].user
        if not user.check_password(value):
            raise serializers.ValidationError("Incorrect old password")
        return value
    
    def validate_new_password(self, value):
        """Validate new password meets requirements"""
        # Add custom password validation here if needed
        return value
```

## 2. Views

Create/Update `backend/apps/accounts/views.py`:

```python
from rest_framework import generics, status
from rest_framework.permissions import IsAuthenticated, AllowAny
from rest_framework.response import Response
from rest_framework.views import APIView
from django.contrib.auth import get_user_model

from apps.accounts.serializers import (
    UserSerializer,
    UserRegistrationSerializer,
    UserUpdateSerializer,
    ChangePasswordSerializer,
)

User = get_user_model()


class UserRegistrationView(generics.CreateAPIView):
    """
    POST /api/auth/register/
    
    Register a new user and return user data.
    """
    queryset = User.objects.all()
    serializer_class = UserRegistrationSerializer
    permission_classes = [AllowAny]
    
    def create(self, request, *args, **kwargs):
        serializer = self.get_serializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        
        # Serialize user data with UserSerializer
        user_data = UserSerializer(user).data
        
        return Response(
            {
                'user': user_data,
                'message': 'User registered successfully'
            },
            status=status.HTTP_201_CREATED
        )


class CurrentUserView(APIView):
    """
    GET /api/auth/me/     - Get current user profile
    PUT /api/auth/me/     - Update current user profile
    DELETE /api/auth/me/  - Delete account
    """
    permission_classes = [IsAuthenticated]
    
    def get(self, request):
        """Get current user profile"""
        serializer = UserSerializer(request.user)
        return Response(serializer.data)
    
    def put(self, request):
        """Update current user profile"""
        serializer = UserUpdateSerializer(
            request.user,
            data=request.data,
            partial=True
        )
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        
        # Return full user data
        return Response({
            **UserSerializer(user).data,
            'message': 'Profile updated successfully'
        })
    
    def delete(self, request):
        """Delete current user account"""
        user = request.user
        user.is_active = False  # Soft delete
        user.save()
        
        # Or hard delete:
        # user.delete()
        
        return Response(
            {'message': 'Account deleted successfully'},
            status=status.HTTP_200_OK
        )


class ChangePasswordView(APIView):
    """
    POST /api/auth/me/password/
    
    Change user password.
    """
    permission_classes = [IsAuthenticated]
    
    def post(self, request):
        serializer = ChangePasswordSerializer(
            data=request.data,
            context={'request': request}
        )
        serializer.is_valid(raise_exception=True)
        
        # Update password
        user = request.user
        user.set_password(serializer.validated_data['new_password'])
        user.save()
        
        return Response({
            'message': 'Password changed successfully'
        })
```

## 3. URL Configuration

Update `backend/config/api_urls.py`:

```python
from django.urls import include, path
from apps.accounts.views import (
    UserRegistrationView,
    CurrentUserView,
    ChangePasswordView,
)

urlpatterns = [
    path("health/", include("apps.common.urls")),
    
    # JWT Token endpoints (already configured)
    path("auth/", include("apps.accounts.urls")),
    
    # New auth endpoints for Flutter
    path("auth/register/", UserRegistrationView.as_view(), name="user-register"),
    path("auth/me/", CurrentUserView.as_view(), name="current-user"),
    path("auth/me/password/", ChangePasswordView.as_view(), name="change-password"),
]
```

## 4. CORS Configuration

Update `backend/config/settings/base.py` (or `development.py`):

```python
INSTALLED_APPS = [
    # ...
    'corsheaders',
    # ...
]

MIDDLEWARE = [
    'corsheaders.middleware.CorsMiddleware',  # Add this BEFORE 'django.middleware.common.CommonMiddleware'
    'django.middleware.common.CommonMiddleware',
    # ...
]

# CORS settings for Flutter development
CORS_ALLOWED_ORIGINS = [
    "http://localhost:8080",
    "http://127.0.0.1:8080",
    # Add your Flutter app's origins
]

# For development only (remove in production):
CORS_ALLOW_ALL_ORIGINS = True
```

Install corsheaders:
```bash
pip install django-cors-headers
echo "django-cors-headers>=4.0.0" >> requirements.txt
```

## 5. Testing with curl

### Register a user:
```bash
curl -X POST http://localhost:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "testpass123",
    "name": "Test User",
    "phone_number": "+253 12 34 56 78"
  }'
```

### Login:
```bash
curl -X POST http://localhost:8000/api/auth/token/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "testpass123"
  }'
```

Response:
```json
{
  "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

### Get current user (requires token):
```bash
TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

curl -X GET http://localhost:8000/api/auth/me/ \
  -H "Authorization: Bearer $TOKEN"
```

### Update profile:
```bash
curl -X PUT http://localhost:8000/api/auth/me/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Updated Name",
    "phone_number": "+253 99 88 77 66"
  }'
```

### Change password:
```bash
curl -X POST http://localhost:8000/api/auth/me/password/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "old_password": "testpass123",
    "new_password": "newsecurepass456"
  }'
```

### Delete account:
```bash
curl -X DELETE http://localhost:8000/api/auth/me/ \
  -H "Authorization: Bearer $TOKEN"
```

## 6. Testing with Flutter

### Start Django:
```bash
cd backend
python manage.py runserver
```

### Run Flutter app in API mode:
```bash
cd client
flutter run --dart-define=USE_MOCK_DATA=false --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

### Expected Console Output (Django):
```
[10/Mar/2026 11:30:00] "POST /api/auth/register/ HTTP/1.1" 201 234
[10/Mar/2026 11:30:01] "POST /api/auth/token/ HTTP/1.1" 200 312
[10/Mar/2026 11:30:02] "GET /api/auth/me/ HTTP/1.1" 200 234
```

### Expected Console Output (Flutter with API_DEBUG=true):
```
🌐 API Request: POST http://10.0.2.2:8000/api/auth/register/
📤 Request Data: {email: test@example.com, password: ***, name: Test}
✅ API Response: 201 http://10.0.2.2:8000/api/auth/register/
📥 Response Data: {user: {...}, message: User registered successfully}
```

## 7. Common Issues & Solutions

### Issue: CORS errors
**Solution**: Ensure `django-cors-headers` is installed and configured correctly.

### Issue: 401 Unauthorized
**Solution**: 
- Check JWT token is valid
- Verify `Authorization: Bearer <token>` header is present
- Check token hasn't expired

### Issue: User model doesn't have required fields
**Solution**: 
- Add missing fields to User model in migration
- Or compute them dynamically in serializer (like `total_stamps`)

### Issue: Flutter can't connect to localhost
**Solution**:
- Android Emulator: Use `http://10.0.2.2:8000`
- iOS Simulator: Use `http://localhost:8000`
- Physical Device: Use your computer's IP (e.g., `http://192.168.1.100:8000`)

## 8. Next Steps

After auth endpoints are working:
1. ✅ Test registration, login, profile update flows
2. ✅ Implement frontend validation
3. 📊 Move to Phase 2: Shop endpoints
4. 📊 Move to Phase 3: Merchant dashboard endpoints
5. 📊 Continue with Deals, Flyers, Loyalty, Enrollments

---

**Reference**: See `docs/BACKEND_INTEGRATION_STATUS.md` for complete API specifications.
