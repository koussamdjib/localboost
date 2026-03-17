# 🔧 REBUILD MERCHANT APP - Fix Loyalty Program Error

## 🎯 Problem

Tu as une erreur "Erreur lors de la sauvegarde" quand tu essaies de créer/activer un programme de fidélité parce que:

1. ✅ Le backend endpoint existe: `POST /api/v1/merchant/shops/{shopId}/loyalty/`
2. ✅ Le code Flutter est correct
3. ❌ **L'app merchant utilise la mauvaise URL API** - elle essaie de se connecter à `https://sirius-djibouti.com/api/v1` (production) au lieu de ton serveur

**Solution:** Reconstruire l'app merchant avec la bonne URL API

---

## 🏗️ STEP 1: Determine Your Backend URL

### If you're using LOCAL development:
```bash
# Backend runs on your computer
http://localhost:8000/api/v1

# For Android emulator (special IP):
http://10.0.2.2:8000/api/v1

# For physical phone on same WiFi:
# Find your computer's IP:
ipconfig                    # Windows (look for IPv4: 192.168.x.x)
ifconfig | grep inet        # Mac/Linux

# Then use:
http://192.168.1.100:8000/api/v1  (replace 192.168.1.100 with your IP)
```

### If you're using PRODUCTION backend on VPS:
```bash
# Backend domain (must be HTTPS and working)
https://sirius-djibouti.com/api/v1

# Verify it's accessible:
curl https://sirius-djibouti.com/api/v1/health/
# Should return: {"status": "ok", "database": "ok", ...}
```

---

## 🔨 STEP 2: Build Merchant APK with Correct URL

### Navigate to merchant directory:
```bash
cd merchant
```

### Build with your API URL:

#### OPTION A: LocalHost (Development)
```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1 \
  --dart-define=USE_MOCK_DATA=false
```

#### OPTION B: WiFi IP (Physical Phone on Same Network)
```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=http://192.168.1.100:8000/api/v1 \
  --dart-define=USE_MOCK_DATA=false
```

#### OPTION C: Production URL (VPS)
```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=https://sirius-djibouti.com/api/v1 \
  --dart-define=USE_MOCK_DATA=false
```

**Build output:**
```
✓ Build complete!
  APK saved to: merchant/build/app/outputs/apk/release/app-release.apk
```

---

## 📥 STEP 3: Install New APK

```bash
# Uninstall old version
adb uninstall com.localboost.localboost_merchant

# Install new version
adb install merchant/build/app/outputs/apk/release/app-release.apk
```

---

## 🧪 STEP 4: Test Loyalty Program Creation

### 1. Launch app on phone
- Tap **Localboost Merchant** icon

### 2. Login as merchant
```
Email:    seed.merchant@localboost.com
Password: SeedMerchant!2026
```

### 3. Navigate to Loyalty Programs
- Tab "Fidélité"
- Tap "+" (Create)

### 4. Fill form
```
Titre:                    "Test Program"
Description:              "Test loyalty program"  
Nombre de timbres requis: 10
Description récompense:   "Free item"
```

### 5. Click "Activer" (Activate)

**Expected:**
- ✅ No error - message "Programme créé"
- ✅ Program appears in list

**If error still occurs:**
- Check backend logs: `python manage.py tail` (if running locally)
- Or VPS logs: `ssh user@vps_ip` → check Django logs
- See debugging tips below

---

## 🔍 VERIFY BACKEND IS REACHABLE

### From your phone or computer:

```bash
# Test if backend health endpoint works
curl https://sirius-djibouti.com/api/v1/health/

# Expected response (might be modified for your setup):
{
  "status": "ok",
  "database": "ok", 
  "cache": "ok"
}
```

### If timeout or connection refused:
- Backend is NOT running or NOT accessible at that URL
- Check backend is actually running: `python manage.py runserver 0.0.0.0:8000`
- Check URL is correct - VPS might need domain/cert configured

---

## 🐛 TROUBLESHOOTING - Still Getting Error?

### 1. Check Phone Network

```bash
# From phone (via adb shell):
adb shell ping -c 4 google.com

# Should see: 4 packets transmitted, 4 received (if WiFi works)
```

### 2. Check App Logs

```bash
# See what error app is getting
adb logcat | grep -i "loyalty\|error\|flutter"

# Look for patterns like:
# E/flutter: DioException: Connection refused
# E/flutter: 401 Unauthorized  
# E/flutter: SocketException: Network unreachable
```

### 3. Test API Manually

```bash
# Get auth token
curl -X POST https://sirius-djibouti.com/api/v1/auth/token/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "seed.merchant@localboost.com",
    "password": "SeedMerchant!2026"
  }'

# Capture the "access" token from response
TOKEN="your_access_token_here"

# Test creating loyalty program
curl -X POST https://sirius-djibouti.com/api/v1/merchant/shops/1/loyalty/ \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "name": "Test",
    "description": "Test program",
    "stamps_required": 10,
    "reward_label": "Test reward"
  }'

# If 201: API works, check app config
# If 401: Token expired, login again
# If 403: Not a merchant
# If 404: Endpoint doesn't exist (shouldn't happen)
```

### 4. Verify Merchant Account

```bash
# Make sure you're logged in as merge (not customer)
# Check app dashboard - should say "Merchant Dashboard"
# Should see "Ma Boutique" tab

# From terminal, verify user role:
curl -X POST https://sirius-djibouti.com/api/v1/auth/token/ \
  -H "Content-Type: application/json" \
  -d '{
    "username": "seed.merchant@localboost.com",
    "password": "SeedMerchant!2026"
  }' | grep access

# Then:
curl https://sirius-djibouti.com/api/v1/merchant/shops/ \
  -H "Authorization: Bearer $TOKEN"

# Should return array of shops (not "Permission denied")
```

---

## 🚀 QUICK CHECKLIST

- [ ] Backend endpoint is working: `curl /api/v1/health/`
- [ ] Token is valid: `curl /api/v1/auth/token/` returns access token
- [ ] Merchant has shop: `curl /api/v1/merchant/shops/` shows shops
- [ ] API_BASE_URL matches your backend location
- [ ] Merchant app rebuilt with correct `--dart-define`
- [ ] Old APK uninstalled before installing new one
- [ ] Logged in as `seed.merchant@localboost.com` (not customer)
- [ ] "Nombre de timbres" field ≥ 1

---

## 📋 Build Commands Reference

```bash
# Clean previous build
flutter clean

# Get dependencies
flutter pub get

# Build for development (local backend)
flutter build apk --release \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1 \
  --dart-define=USE_MOCK_DATA=false

# Build for production (VPS)
flutter build apk --release \
  --dart-define=API_BASE_URL=https://sirius-djibouti.com/api/v1 \
  --dart-define=USE_MOCK_DATA=false

# Build with verbose output (if error occurs)
flutter build apk --release -v

# Uninstall and reinstall
adb uninstall com.localboost.localboost_merchant
adb install build/app/outputs/apk/release/app-release.apk
```

---

## 🎯 After Rebuild

1. ✅ App launches with new API URL
2. ✅ Login with test merchant credentials
3. ✅ Navigate to Loyalty Programs tab
4. ✅ Create new program with form
5. ✅ Click "Activer" button
6. ✅ Program saves and appears in list

**If still error:**
- Check backend logs for actual error response
- Verify all required fields sent: `name`, `description`, `stamps_required`, `reward_label`
- Make sure shop exists and is active

---

## 📞 Need More Help?

**Check these files:**
- Debugging guide: [DEBUGGING_LOYALTY_ERROR.md](DEBUGGING_LOYALTY_ERROR.md)
- Installation guide: [INSTALLATION_AND_TESTING_GUIDE.md](INSTALLATION_AND_TESTING_GUIDE.md)
- Test credentials: [TEST_CREDENTIALS.md](TEST_CREDENTIALS.md)

**See actual API code:**
```bash
# Backend view implementation
cat backend/apps/merchants/views.py | grep -A 20 "MerchantShopLoyaltyListCreateView"

# Flutter service
cat merchant/lib/services/merchant_loyalty_service.dart
```

---

**Status:** Ready to rebuild 🏗️  
**Last Updated:** March 13, 2026
