# Django Authentication API - Testing Guide

## Quick Start

### 1. Start the Django Server

```bash
cd backend

# Option 1: Use SQLite (default for local development)
python manage.py migrate
python manage.py runserver

# Option 2: Use PostgreSQL
# Set environment variables in .env file first
LOCAL_USE_SQLITE=false python manage.py runserver
```

The API will be available at: `http://127.0.0.1:8000/api/`

---

## API Endpoints

All endpoints are prefixed with `/api/auth/`

| Method | Endpoint | Auth Required | Description |
|--------|----------|---------------|-------------|
| POST | `/api/auth/register/` | No | Register new user |
| POST | `/api/auth/token/` | No | Login (get JWT tokens) |
| POST | `/api/auth/token/refresh/` | No | Refresh access token |
| GET | `/api/auth/me/` | Yes | Get current user profile |
| PUT | `/api/auth/me/` | Yes | Update user profile |
| POST | `/api/auth/me/password/` | Yes | Change password |
| DELETE | `/api/auth/me/` | Yes | Delete account (soft delete) |

---

## cURL Test Commands

### 1. Register a New User

```bash
curl -X POST http://127.0.0.1:8000/api/auth/register/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPassword123",
    "name": "John Doe",
    "phone_number": "+253 99 88 77 66"
  }'
```

**Expected Response (201 Created):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "test@example.com",
  "name": "John Doe",
  "phone_number": "+253 99 88 77 66",
  "qr_code_id": "550e8400-e29b-41d4-a716-446655440000",
  "created_at": "2026-03-10T10:30:00.000000Z",
  "last_login": null,
  "total_stamps": 0,
  "total_rewards_redeemed": 0,
  "total_offers_joined": 0
}
```

---

### 2. Login (Get JWT Tokens)

```bash
curl -X POST http://127.0.0.1:8000/api/auth/token/ \
  -H "Content-Type: application/json" \
  -d '{
    "email": "test@example.com",
    "password": "TestPassword123"
  }'
```

**Expected Response (200 OK):**
```json
{
  "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Save the access token for authenticated requests:**
```bash
# For bash/Linux/Mac:
export TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

# For PowerShell (Windows):
$TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
```

---

### 3. Get Current User Profile

```bash
# Bash/Linux/Mac:
curl -X GET http://127.0.0.1:8000/api/auth/me/ \
  -H "Authorization: Bearer $TOKEN"

# PowerShell (Windows):
curl -X GET http://127.0.0.1:8000/api/auth/me/ `
  -H "Authorization: Bearer $TOKEN"
```

**Expected Response (200 OK):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "test@example.com",
  "name": "John Doe",
  "phone_number": "+253 99 88 77 66",
  "qr_code_id": "550e8400-e29b-41d4-a716-446655440000",
  "created_at": "2026-03-10T10:30:00.000000Z",
  "last_login": "2026-03-10T10:35:00.000000Z",
  "total_stamps": 0,
  "total_rewards_redeemed": 0,
  "total_offers_joined": 0
}
```

---

### 4. Update User Profile

```bash
# Bash/Linux/Mac:
curl -X PUT http://127.0.0.1:8000/api/auth/me/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Jane Smith",
    "phone_number": "+253 11 22 33 44"
  }'

# PowerShell (Windows):
curl -X PUT http://127.0.0.1:8000/api/auth/me/ `
  -H "Authorization: Bearer $TOKEN" `
  -H "Content-Type: application/json" `
  -d '{\"name\": \"Jane Smith\", \"phone_number\": \"+253 11 22 33 44\"}'
```

**Expected Response (200 OK):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "email": "test@example.com",
  "name": "Jane Smith",
  "phone_number": "+253 11 22 33 44",
  "qr_code_id": "550e8400-e29b-41d4-a716-446655440000",
  "created_at": "2026-03-10T10:30:00.000000Z",
  "last_login": "2026-03-10T10:35:00.000000Z",
  "total_stamps": 0,
  "total_rewards_redeemed": 0,
  "total_offers_joined": 0
}
```

---

### 5. Change Password

```bash
# Bash/Linux/Mac:
curl -X POST http://127.0.0.1:8000/api/auth/me/password/ \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "old_password": "TestPassword123",
    "new_password": "NewSecurePassword456"
  }'

# PowerShell (Windows):
curl -X POST http://127.0.0.1:8000/api/auth/me/password/ `
  -H "Authorization: Bearer $TOKEN" `
  -H "Content-Type: application/json" `
  -d '{\"old_password\": \"TestPassword123\", \"new_password\": \"NewSecurePassword456\"}'
```

**Expected Response (200 OK):**
```json
{
  "message": "Password changed successfully."
}
```

**Note:** After changing the password, you'll need to login again to get a new token.

---

### 6. Refresh Access Token

```bash
# Save refresh token first:
export REFRESH_TOKEN="eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."

curl -X POST http://127.0.0.1:8000/api/auth/token/refresh/ \
  -H "Content-Type: application/json" \
  -d '{
    "refresh": "'$REFRESH_TOKEN'"
  }'
```

**Expected Response (200 OK):**
```json
{
  "access": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refresh": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

---

### 7. Delete Account (Soft Delete)

```bash
# Bash/Linux/Mac:
curl -X DELETE http://127.0.0.1:8000/api/auth/me/ \
  -H "Authorization: Bearer $TOKEN"

# PowerShell (Windows):
curl -X DELETE http://127.0.0.1:8000/api/auth/me/ `
  -H "Authorization: Bearer $TOKEN"
```

**Expected Response (204 No Content):**
```
(empty response body)
```

**Note:** This performs a soft delete (sets `is_active=False`). User cannot login but data is preserved.

---

## Error Responses

### 400 Bad Request - Validation Error
```json
{
  "email": ["A user with this email already exists."],
  "password": [
    "This password is too short. It must contain at least 8 characters.",
    "This password is too common."
  ]
}
```

### 401 Unauthorized - Invalid Credentials
```json
{
  "detail": "No active account found with the given credentials"
}
```

### 401 Unauthorized - Missing/Invalid Token
```json
{
  "detail": "Given token not valid for any token type",
  "code": "token_not_valid",
  "messages": [
    {
      "token_class": "AccessToken",
      "token_type": "access",
      "message": "Token is invalid or expired"
    }
  ]
}
```

---

## Testing with Postman

### 1. Import Collection

Create a new Postman collection with these requests:

**Base URL:** `http://127.0.0.1:8000/api/auth`

### 2. Environment Variables

Create an environment with:
- `base_url`: `http://127.0.0.1:8000/api`
- `access_token`: (will be set automatically)
- `refresh_token`: (will be set automatically)

### 3. Auto-save Tokens

In the **Login** request, add this to the **Tests** tab:

```javascript
if (pm.response.code === 200) {
    const jsonData = pm.response.json();
    pm.environment.set("access_token", jsonData.access);
    pm.environment.set("refresh_token", jsonData.refresh);
}
```

### 4. Use Token in Requests

For authenticated endpoints, add this header:
```
Authorization: Bearer {{access_token}}
```

---

## Testing with Flutter Apps

### 1. Update API Configuration

In the Flutter app, run with API mode enabled:

```bash
cd client
flutter run \
  --dart-define=USE_MOCK_DATA=false \
  --dart-define=API_BASE_URL=http://127.0.0.1:8000/api \
  --dart-define=API_DEBUG=true
```

**Platform-specific URLs:**
- **Android Emulator:** `http://10.0.2.2:8000/api`
- **iOS Simulator:** `http://localhost:8000/api`
- **Physical Device:** `http://YOUR_COMPUTER_IP:8000/api`

### 2. Enable CORS (Already Configured)

CORS is configured in `backend/config/settings/local.py` to allow all origins in development.

### 3. Test Registration Flow

1. Open Flutter app
2. Navigate to registration screen
3. Fill in user details
4. Submit form
5. Check Django console for API request
6. Verify user is created in database

### 4. Test Login Flow

1. Try logging in with created credentials
2. Verify JWT token is received and stored
3. Check that profile screen loads user data
4. Verify computed fields (stamps, rewards, offers) display correctly

---

## Database Verification

### Check Created Users

```bash
cd backend
python manage.py shell
```

```python
from apps.accounts.models import User
from apps.customers.models import CustomerProfile

# List all users
User.objects.all()

# Get specific user
user = User.objects.get(email="test@example.com")
print(f"User: {user.email}")
print(f"ID: {user.id}")
print(f"Phone: {user.phone_number}")
print(f"Created: {user.created_at}")

# Check customer profile
profile = user.customer_profile
print(f"Profile: {profile}")
```

### Reset Test Data

```bash
# Delete all users
python manage.py shell -c "from apps.accounts.models import User; User.objects.filter(is_superuser=False).delete()"

# Or reset entire database (SQLite only)
rm db.sqlite3
python manage.py migrate
python manage.py createsuperuser
```

---

## Common Issues & Solutions

### Issue: CORS errors from Flutter

**Solution:** Verify CORS is enabled in `local.py`:
```python
CORS_ALLOW_ALL_ORIGINS = True
```

### Issue: "No active account found"

**Solution:** 
- Check email and password are correct
- Verify user exists: `User.objects.filter(email="test@example.com").exists()`
- Check user is active: `user.is_active`

### Issue: Token expired

**Solution:** Use the refresh endpoint to get a new access token:
```bash
curl -X POST http://127.0.0.1:8000/api/auth/token/refresh/ \
  -H "Content-Type: application/json" \
  -d '{"refresh": "YOUR_REFRESH_TOKEN"}'
```

### Issue: Android emulator cannot connect

**Solution:** Use `10.0.2.2` instead of `localhost` or `127.0.0.1`:
```
http://10.0.2.2:8000/api
```

---

## Production Checklist

Before deploying to production:

- [ ] Change `DEBUG = False` in production settings
- [ ] Set strong `SECRET_KEY` in environment variables
- [ ] Configure specific `CORS_ALLOWED_ORIGINS` (don't use `CORS_ALLOW_ALL_ORIGINS`)
- [ ] Use PostgreSQL (not SQLite)
- [ ] Enable HTTPS/TLS
- [ ] Set proper `ALLOWED_HOSTS`
- [ ] Configure JWT token lifetimes appropriately
- [ ] Set up token blacklisting for logout
- [ ] Enable rate limiting
- [ ] Set up proper logging and monitoring

---

## Next Steps

After authentication is working:

1. **Phase 2:** Shop Discovery API
   - Create `apps.shops` endpoints
   - Implement shop list/search/detail views
   - Add geolocation filtering

2. **Phase 3:** Merchant Dashboard
   - Implement merchant-specific endpoints
   - Add shop management CRUD
   - Integrate with authentication

3. **Phase 4:** Deals, Flyers, Loyalty Programs
   - Implement remaining business logic endpoints
   - Add stamp/redemption workflows
   - Integrate QR code scanning

---

**API Status:** ✅ **Authentication Complete**  
**Documentation Updated:** March 10, 2026  
**Ready for Integration Testing**
