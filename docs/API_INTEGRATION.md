# LocalBoost API Infrastructure

## Overview

The LocalBoost API infrastructure provides a robust, type-safe HTTP client for connecting Flutter apps to the Django backend. It supports:

- **Dual-mode operation**: Mock data (development) or real API (production)
- **Automatic JWT authentication**: Token injection and refresh
- **Error handling**: Domain-specific exceptions with user-friendly messages
- **Request interceptors**: Logging, retry logic, and auth management
- **Type-safe responses**: Generic response wrappers for all data types

---

## Architecture

```
shared/lib/services/api/
├── api_config.dart           # Configuration and feature flags
├── api_client.dart           # Base HTTP client (Dio-based)
├── api_exception.dart        # Domain exceptions
├── api_response.dart         # Response wrappers
└── endpoints/
    ├── auth_endpoints.dart   # Authentication endpoints
    ├── shop_endpoints.dart   # Shop endpoints (TODO)
    ├── deal_endpoints.dart   # Deal endpoints (TODO)
    └── ...                   # Other endpoint groups
```

---

## Quick Start

### 1. Switch Between Mock and API Mode

By default, the app uses **mock data** (no backend required). To enable API mode:

**Option A: Environment variable (recommended)**
```bash
# Run with API mode enabled
flutter run --dart-define=USE_MOCK_DATA=false --dart-define=API_BASE_URL=http://10.0.2.2:8000/api
```

**Option B: Modify `api_config.dart`** (not recommended for production)
```dart
static const bool useMockData = false; // Change to false
static const String baseUrl = 'http://10.0.2.2:8000/api'; // Your backend URL
```

### 2. Use the API Client

The `AuthService` already demonstrates dual-mode operation:

```dart
// In your service
import 'package:localboost_shared/services/api/api_config.dart';
import 'package:localboost_shared/services/api/endpoints/auth_endpoints.dart';

Future<AuthResult> login({required String email, required String password}) {
  if (ApiConfig.useMockData) {
    // Mock implementation (current behavior)
    return _mockLogin(email, password);
  } else {
    // API implementation (new)
    return _apiLogin(email, password);
  }
}
```

### 3. Handle API Exceptions

```dart
try {
  final authEndpoints = AuthEndpoints();
  final loginResponse = await authEndpoints.login(
    email: 'user@example.com',
    password: 'password123',
  );
  
  // Success!
  print('Access Token: ${loginResponse.accessToken}');
} on AuthException catch (e) {
  // 401/403 errors
  print('Auth failed: ${e.message}');
} on NetworkException catch (e) {
  // Connection timeout, no internet
  print('Network error: ${e.message}');
} on ValidationException catch (e) {
  // 422 errors with field-level validation
  print('Validation failed: ${e.allFieldErrors}');
} on ApiException catch (e) {
  // Catch-all for other API errors
  print('API error: ${e.message}');
}
```

---

## Configuration

### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `API_BASE_URL` | `http://10.0.2.2:8000/api` | Backend API base URL |
| `USE_MOCK_DATA` | `true` | Enable/disable mock mode |
| `API_DEBUG` | `true` | Enable request/response logging |

**Android Emulator**: Use `http://10.0.2.2:8000` to access `localhost` on your dev machine.  
**iOS Simulator**: Use `http://localhost:8000` directly.  
**Physical Device**: Use your computer's IP address (e.g., `http://192.168.1.100:8000`).

### Timeout Settings

Edit [api_config.dart](lib/services/api/api_config.dart):

```dart
static const Duration timeout = Duration(seconds: 30);        // Request timeout
static const Duration connectTimeout = Duration(seconds: 15); // Connection timeout
static const Duration receiveTimeout = Duration(seconds: 30); // Response timeout
```

---

## Authentication Flow

### 1. Register

```dart
final authEndpoints = AuthEndpoints();
final response = await authEndpoints.register(
  email: 'user@example.com',
  password: 'securepassword',
  name: 'John Doe',
  phoneNumber: '+253 12 34 56 78', // Optional
);

final user = response.data; // User object
```

### 2. Login

```dart
final loginResponse = await authEndpoints.login(
  email: 'user@example.com',
  password: 'securepassword',
);

// Token is automatically stored in ApiClient
final accessToken = loginResponse.accessToken;
final refreshToken = loginResponse.refreshToken;
```

### 3. Get Current User

```dart
// Requires valid access token (auto-injected)
final response = await authEndpoints.getCurrentUser();
final user = response.data;
```

### 4. Logout

```dart
await authEndpoints.logout(); // Clears local token
```

---

## Creating New Endpoints

### Step 1: Create Endpoint Class

Create `lib/services/api/endpoints/shop_endpoints.dart`:

```dart
import 'package:localboost_shared/models/shop.dart';
import 'package:localboost_shared/services/api/api_client.dart';
import 'package:localboost_shared/services/api/api_response.dart';

class ShopEndpoints {
  final ApiClient _client = ApiClient.instance;

  /// GET /shops/
  Future<PaginatedResponse<Shop>> listShops({
    int page = 1,
    int limit = 20,
    String? category,
    double? latitude,
    double? longitude,
    double? radius,
  }) async {
    final response = await _client.get(
      '/shops/',
      queryParameters: {
        'page': page,
        'limit': limit,
        if (category != null) 'category': category,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (radius != null) 'radius': radius,
      },
    );

    return PaginatedResponse.fromJson(
      response.data,
      (data) => (data as List).map((e) => Shop.fromJson(e)).toList(),
    );
  }

  /// GET /shops/{id}/
  Future<ApiResponse<Shop>> getShop(String shopId) async {
    final response = await _client.get('/shops/$shopId/');
    return ApiResponse(
      data: Shop.fromJson(response.data),
      statusCode: response.statusCode ?? 200,
    );
  }
}
```

### Step 2: Update Service to Use Endpoint

Modify `search_service.dart`:

```dart
import 'package:localboost_shared/services/api/api_config.dart';
import 'package:localboost_shared/services/api/endpoints/shop_endpoints.dart';

static List<Shop> searchShops({required SearchFilter filter, LatLng? userLocation}) {
  if (ApiConfig.useMockData) {
    // Existing mock implementation
    return _searchShopsImpl(filter: filter, userLocation: userLocation);
  } else {
    // New API implementation
    return _searchShopsApi(filter: filter, userLocation: userLocation);
  }
}

static Future<List<Shop>> _searchShopsApi({
  required SearchFilter filter,
  LatLng? userLocation,
}) async {
  final shopEndpoints = ShopEndpoints();
  final response = await shopEndpoints.listShops(
    category: filter.category?.name,
    latitude: userLocation?.latitude,
    longitude: userLocation?.longitude,
    radius: filter.radius,
  );
  
  return response.data;
}
```

---

## Error Handling Best Practices

### User-Friendly Messages

```dart
String _formatApiError(ApiException error) {
  if (error is NetworkException) {
    return 'Problème de connexion. Vérifiez votre connexion internet.';
  } else if (error is AuthException) {
    return 'Email ou mot de passe incorrect.';
  } else if (error is ValidationException) {
    return error.allFieldErrors; // Shows field-specific errors
  } else if (error is ServerException) {
    return 'Erreur du serveur. Veuillez réessayer plus tard.';
  } else {
    return error.message;
  }
}
```

### Field-Level Validation Errors

For forms, extract individual field errors:

```dart
catch (e) {
  if (e is ValidationException) {
    final emailError = e.getFieldError('email');
    final passwordError = e.getFieldError('password');
    
    // Update form field error states
    setState(() {
      _emailError = emailError;
      _passwordError = passwordError;
    });
  }
}
```

---

## Interceptors

### Auth Interceptor

Automatically injects `Authorization: Bearer <token>` header on all requests. If a request returns 401, the token is automatically cleared.

### Logging Interceptor

When `API_DEBUG=true`, logs all requests and responses:

```
🌐 API Request: POST http://10.0.2.2:8000/api/auth/token/
📤 Request Data: {email: user@example.com, password: ***}
✅ API Response: 200 http://10.0.2.2:8000/api/auth/token/
📥 Response Data: {access: eyJ..., refresh: eyJ...}
```

### Retry Interceptor

Automatically retries failed requests (up to 3 times) for:
- Network timeouts
- 5xx server errors
- 429 (Too Many Requests)

---

## File Upload Example

```dart
import 'package:dio/dio.dart';

Future<void> uploadFlyerPdf(String flyerId, File pdfFile) async {
  final apiClient = ApiClient.instance;
  
  final formData = FormData.fromMap({
    'title': 'My Flyer',
    'file': await MultipartFile.fromFile(
      pdfFile.path,
      filename: 'flyer.pdf',
    ),
  });

  await apiClient.upload(
    '/flyers/',
    data: formData,
    onSendProgress: (sent, total) {
      print('Upload progress: ${(sent / total * 100).toStringAsFixed(0)}%');
    },
  );
}
```

---

## Testing

### Unit Tests (Mock API)

```dart
test('login with valid credentials', () async {
  // Uses mock mode by default
  final authService = AuthService();
  final result = await authService.login(
    email: 'test@example.com',
    password: 'password',
  );
  
  expect(result.success, true);
  expect(result.user, isNotNull);
});
```

### Integration Tests (Real API)

```bash
# Start Django backend on localhost:8000
flutter test --dart-define=USE_MOCK_DATA=false --dart-define=API_BASE_URL=http://localhost:8000/api
```

---

## Migration Checklist

- [x] ✅ API infrastructure created
- [x] ✅ Dio package added
- [x] ✅ Auth endpoints implemented
- [x] ✅ AuthService dual-mode support
- [ ] ⏳ Shop endpoints (Phase 2)
- [ ] ⏳ Deal endpoints (Phase 4)
- [ ] ⏳ Flyer endpoints (Phase 5)
- [ ] ⏳ Loyalty endpoints (Phase 6)
- [ ] ⏳ Enrollment endpoints (Phase 7)
- [ ] ⏳ Django backend endpoints implementation

---

## Next Steps

1. **Backend Development**: Implement Django REST endpoints matching the Flutter signatures
2. **Shop Endpoints**: Create `shop_endpoints.dart` and update `SearchService`
3. **Testing**: Test auth flow with real backend
4. **Documentation**: Document each endpoint as it's implemented

---

## Support

For issues or questions:
- Check Django logs: `python manage.py runserver`
- Enable API debug logging: `--dart-define=API_DEBUG=true`
- Review exception details: All exceptions include `statusCode` and `data` fields
