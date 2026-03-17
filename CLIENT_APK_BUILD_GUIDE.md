# 📱 BUILD & INSTALL CLIENT APK - Step-by-Step

## 🎯 Goal
Build LocalBoost Client APK and install on Android phone for testing.

---

## ✅ PREREQUISITES

### 1️⃣ Check Flutter Installation
```bash
flutter doctor
```

**Expected output:**
```
✓ Flutter (Channel stable, x.x.x, on Windows)
✓ Android toolchain
✓ Chrome - develop for the web
[✓] No issues found!
```

**If errors:** Fix them with `flutter doctor --verbose` guidance

---

### 2️⃣ Check ADB (Android Debug Bridge)

```bash
adb --version
```

Expected: `Android Debug Bridge version X.X.X`

If not found:
```bash
# Add Android SDK to PATH
# Windows: set PATH=%PATH%;C:\Users\USERNAME\AppData\Local\Android\Sdk\platform-tools

# Then retry:
adb --version
```

---

### 3️⃣ Enable USB Debugging on Phone

On **Android Phone:**
1. Settings → About Phone
2. Tap "Build Number" 7 times
3. Go back → System → Developer Options
4. Enable "USB Debugging"
5. Connect via USB cable

**Verify connection:**
```bash
adb devices
```

Expected output:
```
List of attached devices
ABC123456789    device
```

---

## 🏗️ BUILD CLIENT APK

### Step 1: Navigate to Client Directory
```bash
cd client
```

### Step 2: Get Dependencies
```bash
flutter pub get
```

### Step 3: Build Release APK

```bash
# OPTION A: Production URL (recommended for final release)
flutter build apk --release

# OPTION B: Local development backend (60.0.2.2 for emulator)
flutter build apk --release \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1 \
  --dart-define=USE_MOCK_DATA=false

# OPTION C: Your computer's IP (for physical phone on same WiFi)
# First get your IP:
#   Windows: ipconfig (look for IPv4 Address like 192.168.1.100)
#   Mac: ifconfig | grep inet
#   Linux: hostname -I

flutter build apk --release \
  --dart-define=API_BASE_URL=http://192.168.1.100:8000/api/v1 \
  --dart-define=USE_MOCK_DATA=false
```

**Build output:**
```
✓ Build complete!
  APK saved to: client/build/app/outputs/apk/release/app-release.apk (66.2 MB)
```

**Build time:** ~3-5 minutes

---

## 📥 INSTALL APK ON PHONE

### Via USB (Recommended - Fastest)

```bash
# Install directly
adb install client/build/app/outputs/apk/release/app-release.apk
```

**Output:**
```
Performing Streamed Install
Success
```

**On phone:**
- App appears in app drawer
- Tap to launch

---

### Via File Transfer (Alternative)

```bash
# Copy APK to phone's Downloads folder
adb push client/build/app/outputs/apk/release/app-release.apk /sdcard/Download/

# Then on phone:
# 1. Open Files app
# 2. Navigate to Downloads
# 3. Tap app-release.apk
# 4. Install
# 5. Grant permissions
```

---

## 🚀 LAUNCH & TEST

### First Launch

1. **Phone screen:** Tap **Localboost Client** app icon
2. **Grant permissions:**
   - Location (optional, for shop discovery)
   - Camera (for QR codes/flyer scanning)
3. **Login screen appears** ✓

### Login with Test Credentials

**Customer account:**
```
Email:    customer_loyalty@localboost.test
Password: customer-password-123
```

**Expected:**
- Loads home screen
- Shows "My Cards" tab (loyalty programs)
- Shows "Deals" tab
- Shows "Flyers" tab
- Shows "Browse Shops" tab

---

## 🔍 VERIFY INSTALLATION

### Check App is Installed
```bash
adb shell pm list packages | grep localboost
```

Expected:
```
package:com.localboost.client
```

### See App Details
```bash
adb shell pm dump com.localboost.client | head -20
```

### Clear App Data (if needed)
```bash
adb shell pm clear com.localboost.client
```

This clears:
- Login cached token
- Stored data
- Cache
- Resets app to factory state

---

## 🧪 TESTING CHECKLIST

### Screen Navigation
- [ ] Home page loads
- [ ] Can tap "My Cards" → shows enrolled loyalty programs
- [ ] Can tap "Deals" → shows active deals
- [ ] Can tap "Flyers" → shows active flyers
- [ ] Can tap "Browse Shops" → shows merchant shops

### Authentication
- [ ] Login works with credentials
- [ ] Can see "Logout" button
- [ ] Logout clears session (can't access protected screens)
- [ ] Re-login works

### Data Display
- [ ] Loyalty programs show:
  - [ ] Program name
  - [ ] Stamps progress (e.g., "3 of 10 stamps")
  - [ ] Reward description
- [ ] Deals show:
  - [ ] Deal title
  - [ ] Discount value
  - [ ] Expiration date
- [ ] Flyers show:
  - [ ] Image/thumbnail
  - [ ] Title
  - [ ] Description

### API Integration
- [ ] If backend is running:
  - [ ] Can see real data from database
  - [ ] Data matches what's in Django admin
- [ ] If backend is down:
  - [ ] Gets error message (not app crash)
  - [ ] Can still see cached data if previously loaded

---

## 🔧 TROUBLESHOOTING

### ❌ "Failed to connect to adb"
```bash
# Restart ADB server
adb kill-server
adb start-server

# Retry:
adb devices
```

### ❌ ADB shows device as "offline"
```bash
# Unplug USB cable
# Wait 5 seconds
# Plug back in
# On phone grant USB permission dialog
```

### ❌ "No attached devices" after `adb devices`
```bash
# Check USB driver is installed (Windows)
# Or enable "File Transfer" mode on phone USB menu
# Or restart adb:
adb kill-server
adb start-server
```

### ❌ "INSTALL_FAILED_INVALID_APK"
```bash
# APK may be corrupted, rebuild:
cd client
flutter clean
flutter pub get
flutter build apk --release
```

### ❌ App crashes on launch
```bash
# See error in logcat:
adb logcat | grep flutter

# Look for stack traces
# Common: Network timeout if backend unreachable
```

### ❌ Can't login (401 error)
```bash
# 1. Verify backend API is up:
curl http://localhost:8000/api/v1/health/

# 2. Verify API URL in app matches:
adb logcat | grep "API_BASE_URL"

# 3. Check credentials exist:
# In Django admin, Users table should have test accounts
```

---

## 📊 BUILD VARIANTS EXPLAINED

### Default Build (Production)
```bash
flutter build apk --release
```
- Uses: `https://sirius-djibouti.com/api/v1`
- For: Final release to Play Store
- Status: ✓ Production-ready

### Development Build (Local Backend)
```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=http://10.0.2.2:8000/api/v1
```
- Uses: Your computer (Android emulator sees `10.0.2.2`)
- For: Testing against local Django
- Status: ✓ For development only

### WiFi Build (Physical Phone + Local Backend)
```bash
flutter build apk --release \
  --dart-define=API_BASE_URL=http://192.168.1.100:8000/api/v1
```
- Uses: Your computer on same WiFi
- For: Testing on real phone against local backend
- Status: ✓ For development only

---

## 📦 APK FILE DETAILS

**Location:** `client/build/app/outputs/apk/release/app-release.apk`

**Size:** ~66.2 MB

**Architecture:** ARM64-v8a (works on most modern Android phones)

**Android Version:**
- Minimum: API 31 (Android 12)
- Target: API 34 (Android 14)

**Signature:** Debug keystore (for development)
- Note: For Play Store release, must sign with release keystore

---

## 🔐 SIGNING FOR PRODUCTION

**Current State:** Debug-signed APK (development only)

**For Play Store Release:**
```bash
# Generate release keystore (one time)
keytool -genkey -v -keystore ~/release.keystore \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias localboost_release

# Build signed release APK
flutter build apk --release \
  --dart-define=PLAY_STORE=true

# Output will be signed with keystore
```

**⚠️ IMPORTANT:** Keep `release.keystore` safe - losing it means can't update app on Play Store!

---

## 📋 NEXT STEPS

After installing client:

1. **Test merchant side CRUD:** See [INSTALLATION_AND_TESTING_GUIDE.md](INSTALLATION_AND_TESTING_GUIDE.md)
2. **Debug loyalty error:** See [DEBUGGING_LOYALTY_ERROR.md](DEBUGGING_LOYALTY_ERROR.md)
3. **Verify backend is live:** `curl https://sirius-djibouti.com/api/v1/health/`

---

## 🆘 Need Help?

**Check logs:**
```bash
# Real-time logs from phone
adb logcat | grep -i error

# Save logs to file
adb logcat > logs.txt
```

**Test specific endpoint:**
```bash
# From terminal (requires backend running)
curl http://localhost:8000/api/v1/auth/token/ \
  -H "Content-Type: application/json" \
  -d '{"username":"customer_loyalty@localboost.test","password":"customer-password-123"}'
```

**See all commands used:**
```bash
history | grep flutter
history | grep adb
```

---

**Status:** Ready to build 🏗️  
**Last Updated:** March 13, 2026
