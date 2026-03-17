# 🐛 DEBUGGING LOYALTY PROGRAM ERROR

## ❌ Error: "Erreur lors de la création du programme" / Network Failure

### Root Cause Analysis

Your merchant app receives an error when creating loyalty programs because:

**The endpoints ARE implemented on backend** ✅
- View: `MerchantShopLoyaltyListCreateView` ✅
- Route: `POST /api/v1/merchant/shops/{shop_id}/loyalty/` ✅  
- Permissions: `IsMerchantUser` + shop ownership check ✅

**But app can't reach them because:**
- App tries to connect to: `https://sirius-djibouti.com/api/v1` (PRODUCTION)
- Your development backend is probably on: `http://localhost:8000` or `http://YOUR_VPS_IP:8000`
- **Mismatch = Connection Error**

---

## 🔧 SOLUTION: 3 Options

### ✅ OPTION 1: Use Production Backend (RECOMMENDED if deployed)

**Requirements:**
- Backend deployed to `https://sirius-djibouti.com`
- SSL certificate installed
- Django `DEBUG = False`
- `ALLOWED_HOSTS` includes domain

**Verify it's working:**
```bash
# From your computer
curl -k https://sirius-djibouti.com/api/v1/health/

# Expected response:
# {"status": "ok", "database": "ok", "cache": "ok"}
```

If production URL works, just:
1. Use existing credentials in [TEST_CREDENTIALS.md](TEST_CREDENTIALS.md)
2. App will connect automatically
3. Test loyalty program creation

---

### ✅ OPTION 2: Test Locally (Development)

**For local development with Django runserver:**

#### Step 1: Start Backend
```bash
cd backend
python manage.py runserver 0.0.0.0:8000
```

#### Step 2: Build Merchant APK with LOCAL backend URL

```bash
cd merchant

# Build with localhost (Android emulator sees host as 10.0.2.2)
flutter build apk --release \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1 \
  --dart-define=USE_MOCK_DATA=false

# Install on emulator
adb install build/app/outputs/apk/release/app-release.apk
```

**For Physical Phone on same WiFi:**
```bash
# Get your computer's IP
ipconfig getifaddr en0    # Mac
hostname -I              # Linux  
ipconfig                 # Windows (look for IPv4 Address: 192.168.x.x)

# Build with your IP
flutter build apk --release \
  --dart-define=API_BASE_URL=http://192.168.1.100:8000/api/v1 \
  --dart-define=USE_MOCK_DATA=false

# Install
adb install build/app/outputs/apk/release/app-release.apk
```

---

### ✅ OPTION 3: Firebase App Distribution (Beta Testing)

**For production deployment to real devices:**

1. Upload APK to Firebase Console
2. Invite testers by email
3. Testers download from `https://firebase.google.com/testlab`
4. Uses production URL automatically
5. Keeps app updated automatically

---

## 🧪 DIAGNOSTIC CHECKLIST

### 1️⃣ Check Backend is Accessible

```bash
# For Production
curl -k https://sirius-djibouti.com/api/v1/health/
# Expected: 200 + {"status": "ok"}

# For Local Dev
curl http://localhost:8000/api/v1/health/
# Expected: 200 + {"status": "ok"}
```

### 2️⃣ Check Authentication Token

```bash
# Get token
curl -X POST http://localhost:8000/api/v1/auth/token/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "seed.merchant@localboost.com",
    "password": "SeedMerchant!2026"
  }'

# Expected response:
# {"access": "eyJ0eXAi...", "refresh": "eyJ0eXAi..."}
```

### 3️⃣ Test Loyalty Creation Endpoint Directly

```bash
# Create loyalty program
curl -X POST http://localhost:8000/api/v1/merchant/shops/1/loyalty/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -d '{
    "name": "Test Loyalty",
    "description": "Test program",
    "stamps_required": 10,
    "reward_label": "Test reward"
  }'

# Expected: 201 + {"id": 1, "name": "Test Loyalty", ...}

# If error 404: Endpoint not found (shouldn't happen - code exists)
# If error 401: Token expired or invalid
# If error 403: Permission denied (check user is merchant)
```

### 4️⃣ Check App Logs

On phone with merchant app:

1. **Android Studio LogCat:**
   - Connect phone via USB
   - Open Android Studio → Logcat
   - Filter: `localboost_merchant`
   - Look for error messages

2. **Or use Terminal:**
```bash
adb logcat | grep localboost_merchant
```

**Look for patterns:**
```
E/flutter: Network error: Connection refused
E/flutter: DioException: 404 Not Found
E/flutter: SocketException: Connection timed out
```

---

## 🔐 Permission Checks

If you get **"Permission refusée"** when creating program:

1. **Verify merchant login:**
   ```
   ✅ Should see "Merchant Dashboard" title (not "Customer Home")
   ✅ Should see "Ma Boutique" tab
   ❌ If see "Customer" tabs = logged in as CUSTOMER not MERCHANT
   ```

2. **Verify merchant profile:**
   ```dart
   POST /api/v1/auth/token/
   {
     "username": "seed.merchant@localboost.com",
     "password": "SeedMerchant!2026"
   }
   
   Then:
   GET /api/v1/merchant/shops/
   -H "Authorization: Bearer {token}"
   
   Should return: Shops owned by this merchant
   ```

3. **Verify shop exists:**
   ```
   GET /api/v1/merchant/shops/
   
   Response must include at least 1 shop with:
   - "status": "active"
   - "is_active": true
   ```

---

## 📱 Complete Testing Flow

### Step 1: Verify Backend Health
```bash
curl http://localhost:8000/api/v1/health/
# 200 response = backend good ✓
```

### Step 2: Get Auth Token  
```bash
curl -X POST http://localhost:8000/api/v1/auth/token/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "seed.merchant@localboost.com",
    "password": "SeedMerchant!2026"
  }'
# Save the "access" token
```

### Step 3: Create Test Loyalty Program
```bash
SHOP_ID=1
TOKEN="your_access_token"

curl -X POST http://localhost:8000/api/v1/merchant/shops/$SHOP_ID/loyalty/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Test Loyalty",
    "description": "Test program",
    "stamps_required": 10,
    "reward_label": "Test reward"
  }'
```

**If 201:** Endpoint works! ✓ Check app network config

**If 404:** Endpoint missing (shouldn't happen)

**If 401:** Token issue

**If 403:** Permission denied

---

## 📋 Next Steps Based on Error

| Error Message | Cause | Fix |
|---|---|---|
| **Network timeout** | Backend unreachable | Verify backend URL in ApiConfig |
| **Connection refused** | Wrong IP/port | Check `API_BASE_URL` environment variable |
| **401 Unauthorized** | Invalid token | Logout/login again |
| **403 Forbidden** | Not a merchant user | Login as `seed.merchant@localboost.com` |
| **404 Not Found** | Endpoint missing | **Shouldn't happen** - endpoints exist |
| **400 Bad Request** | Validation failed | Check `stamps_required >= 1` |

---

## 🚀 QUICK FIX CHECKLIST

- [ ] Backend is running: `curl http://localhost:8000/api/v1/health/`
- [ ] Merchant token is valid: `curl auth/token/ POST`
- [ ] Shop exists: `curl merchant/shops/ GET`
- [ ] API_BASE_URL matches backend location
- [ ] USE_MOCK_DATA=false in build command
- [ ] Logged in as MERCHANT (not customer)
- [ ] Timestamps_required field ≥ 1

---

## 📞 Support Commands

**See all test accounts:**
```bash
cat TEST_CREDENTIALS.md
```

**See API endpoints:**
```bash
cat backend/apps/merchants/urls.py
```

**See view implementation:**
```bash
grep -A 20 "class MerchantShopLoyaltyListCreateView" backend/apps/merchants/views.py
```

**See serializer validation:**
```bash
grep -A 10 "def validate_stamps_required" backend/apps/loyalty/serializers.py
```

---

**Status:** Ready to debug 🔧  
**Last Updated:** March 13, 2026
