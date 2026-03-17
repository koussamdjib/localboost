# Merchant Mobile QA Guide - Multi-Shop Phase Sign-Off

**Objective:** Verify all merchant shop CRUD operations work correctly on Flutter app with production API integration.

**Run Date:** ________________  
**Tester:** ________________  
**Device/Emulator:** ________________  
**App Version:** ________________

---

## Pre-QA Setup

### Create Test Merchant Account
Use the included validator script or manually create:
- **Email:** `qa_merchant_[timestamp]@test.com` (must be unique per run)
- **Username:** `qa_merchant_[timestamp]` (must be unique per run)  
- **Password:** (same for both tests to simplify)

**Backend Command:**
```bash
python manage.py shell << EOF
from django.contrib.auth import get_user_model
from apps.merchants.models import MerchantProfile

User = get_user_model()
user = User.objects.create_user(
    username='qa_merchant_[timestamp]',
    email='qa_merchant_[timestamp]@test.com',
    password='test_password_123',
    role='merchant'
)
MerchantProfile.objects.create(user=user)
EOF
```

**API Endpoint (if creating via API):**
```
POST /api/v1/auth/register/
Content-Type: application/json

{
  "username": "qa_merchant_[timestamp]",
  "email": "qa_merchant_[timestamp]@test.com",
  "password": "test_password_123",
  "role": "merchant"
}
```

---

## QA Checklist (10 Points)

### ✅ 1. LOGIN TEST
**Objective:** Verify merchant login with production API works correctly.

**Steps:**
1. Open merchant app on device/emulator
2. Tap "Login" (if not already logged in)
3. Enter email: `qa_merchant_[timestamp]@test.com`
4. Enter password: `test_password_123`
5. Tap "Login"

**Expected Result:**
- ✓ No error toast/dialog
- ✓ Page navigates to Dashboard (Campaigns, Boutiques, Profile tabs visible)
- ✓ No 401/403 network errors in network inspector

**Evidence to Capture:**
- Screenshot of Dashboard post-login
- Network request/response from POST /api/v1/auth/token/
  - Expected: `status=200, access_token returned`
- Timestamp of login

**Status:** [ ] PASS [ ] FAIL  
**Notes:** ________________________________________

---

### ✅ 2. CREATE SHOP TEST
**Objective:** Verify creating a new shop persists to backend API.

**Steps:**
1. Tap "Boutiques" tab (MyShopsScreen)
2. Tap "+ Add Shop" button (or FAB)
3. Enter shop name: `QA_Test_Shop_[timestamp]`
4. Enter shop description: `QA test shop for validation`
5. (Optional) Add location/category if required by form
6. Tap "Save" or "Create"

**Expected Result:**
- ✓ Loading spinner appears briefly
- ✓ Shop appears in list immediately with status badge
- ✓ No error toast/dialog
- ✓ Shop ID visible (or available in network response)
- ✓ Shop status shows as "Draft" initially

**Evidence to Capture:**
- Screenshot of new shop in list with ID
- Network request/response from POST /api/v1/merchant/shops/
  - Expected: `status=201, shop_id=X, slug=qa_test_shop_[timestamp]`
- Timestamp of creation

**Stored for Later Tests:**  
- Shop ID: ______________________
- Shop Slug: ______________________

**Status:** [ ] PASS [ ] FAIL  
**Notes:** ________________________________________

---

### ✅ 3. LIST SHOPS TEST
**Objective:** Verify list view shows all merchant's shops.

**Steps:**
1. (Already on Boutiques/MyShopsScreen)
2. Count visible shops
3. Verify the shop created in test #2 is present
4. Pull-to-refresh (if available)
5. Verify list updates without errors

**Expected Result:**
- ✓ Shop from test #2 is visible in list
- ✓ List count ≥ 1
- ✓ Pull-to-refresh displays loading indicator
- ✓ No 404 or 500 errors
- ✓ Each shop displays: name, status badge, action buttons

**Evidence to Capture:**
- Screenshot of full shops list post-refresh
- Network request/response from GET /api/v1/merchant/shops/
  - Expected: `status=200, count≥1, includes QA_Test_Shop_[timestamp]`

**Status:** [ ] PASS [ ] FAIL  
**Notes:** ________________________________________

---

### ✅ 4. EDIT SHOP TEST
**Objective:** Verify editing shop details persists to backend API.

**Steps:**
1. Long-press or tap the shop created in test #2
2. Tap "Edit" action
3. Change shop name to: `QA_Test_Shop_EDITED_[timestamp]`
4. Tap "Save" or "Update"

**Expected Result:**
- ✓ Loading spinner appears brief
- ✓ Shop name updates in list
- ✓ No error toast/dialog
- ✓ Changes persist after app restart (optional deeper test)

**Evidence to Capture:**
- Screenshot of updated shop with new name
- Network request/response from PUT /api/v1/merchant/shops/{id}/
  - Expected: `status=200, name=QA_Test_Shop_EDITED_[timestamp]`
- Timestamp of edit

**Status:** [ ] PASS [ ] FAIL  
**Notes:** ________________________________________

---

### ✅ 5. PUBLISH/ACTIVATE SHOP TEST
**Objective:** Verify shop status transitions work (draft → active).

**Steps:**
1. Tap the edited shop from test #4
2. Look for a "Publish" or "Activate" button (or drag to activate, depending on UI)
3. Confirm/tap "Activate" or similar
4. Verify status badge changes to "Active"

**Expected Result:**
- ✓ Status badge changes from "Draft" to "Active"
- ✓ No error dialog
- ✓ Shop now visible in public discovery (if customer app available for cross-check)
- ✓ Backend status=active reflected

**Evidence to Capture:**
- Screenshot of shop card with "Active" badge
- Network request/response from PUT /api/v1/merchant/shops/{id}/
  - Expected: `status=200, status=active, is_active=true`

**Status:** [ ] PASS [ ] FAIL  
**Notes:** ________________________________________

---

### ✅ 6. ARCHIVE/DELETE SHOP TEST
**Objective:** Verify soft-delete (archive) removes shop from merchant view.

**Steps:**
1. Long-press or tap the active shop from test #5
2. Tap "Delete" or "Archive" action
3. Confirm deletion in dialog

**Expected Result:**
- ✓ Confirmation dialog appears
- ✓ Shop disappears from list after confirm
- ✓ No error toast/dialog
- ✓ Shop count decreases by 1
- ✓ Backend marks status=archived, is_active=false

**Evidence to Capture:**
- Screenshot of confirmation dialog
- Screenshot of shops list without archived shop
- Network request/response from DELETE /api/v1/merchant/shops/{id}/
  - Expected: `status=204` (no content returned)
- Verify shop no longer appears in backend query (optional): GET /api/v1/merchant/shops/ should not include archived shop
- Timestamp of archive

**Status:** [ ] PASS [ ] FAIL  
**Notes:** ________________________________________

---

### ✅ 7. EMPTY STATE TEST
**Objective:** Verify UI handles no shops gracefully.

**Steps:**
1. If shop count > 0: Archive/delete all remaining shops (repeat test #6)
2. Verify empty state UI is shown
3. Look for messaging like "No shops yet" or "Create your first shop"

**Expected Result:**
- ✓ Empty state illustration or message displayed
- ✓ No crash or loading spinner stuck
- ✓ "Add Shop" button remains clickable
- ✓ GET /api/v1/merchant/shops/ returns count=0

**Evidence to Capture:**
- Screenshot of empty state UI
- Network response from GET /api/v1/merchant/shops/
  - Expected: `status=200, count=0, results=[]`

**Status:** [ ] PASS [ ] FAIL  
**Notes:** ________________________________________

---

### ✅ 8. MULTI-SHOP CONTEXT TEST
**Objective:** Verify app correctly switches between multiple shops and loads context.

**Steps:**
1. Create a second shop: `QA_Test_Shop_2_[timestamp]`
2. Tap "Campaigns" tab (should load deals/flyers/loyalty for Shop 1 or first active shop)
3. Select/switch to Shop 2 from a dropdown or shop picker
4. Verify Campaigns tab reloads with Shop 2's context

**Expected Result:**
- ✓ Second shop created successfully (status=201, new ID)
- ✓ Campaigns initially load with Shop 1 context
- ✓ Shop switch dropdown/picker visible and functional
- ✓ Selecting Shop 2 reloads deals/flyers without errors
- ✓ Backend requests include correct shop_id in path

**Evidence to Capture:**
- Screenshot of multiple shops in list with IDs
- Screenshot of Campaigns view switching to Shop 2
- Network requests showing:
  - POST /api/v1/merchant/shops/ → `status=201, id=X`
  - GET /api/v1/merchant/shops/X/deals/ (Shop 1 context)
  - GET /api/v1/merchant/shops/Y/deals/ (Shop 2 context)
- Timestamp of context switch

**Stored for Later Tests:**  
- Shop 2 ID: ______________________

**Status:** [ ] PASS [ ] FAIL  
**Notes:** ________________________________________

---

### ✅ 9. LOGOUT TEST
**Objective:** Verify logout clears session and returns to login screen.

**Steps:**
1. Tap "Profile" tab
2. Tap "Logout" button
3. Verify login screen appears

**Expected Result:**
- ✓ Profile screen disappears
- ✓ Login screen is displayed (email/password fields visible)
- ✓ Previously stored auth token cleared from device storage
- ✓ Tapping "Campaigns" or any protected tab before re-login shows login screen

**Evidence to Capture:**
- Screenshot of login screen post-logout
- Device storage check (SharedPreferences or Keychain) shows auth_token cleared
- Network requests after logout do NOT include Authorization header

**Status:** [ ] PASS [ ] FAIL  
**Notes:** ________________________________________

---

### ✅ 10. WRONG-ACCOUNT OWNERSHIP PROTECTION TEST
**Objective:** Verify merchant cannot access shops owned by other merchants.

**Prerequisite:**  
- Have two test merchant accounts created:
  - Merchant 1: `qa_merchant_account1_[timestamp]@test.com`
  - Merchant 2: `qa_merchant_account2_[timestamp]@test.com`
- Merchant 1 owns a shop (e.g., from earlier tests)

**Steps:**
1. Log in as Merchant 1
2. Navigate to Campaigns (should show Merchant 1's shops)
3. Log out
4. Log in as Merchant 2
5. Attempt to navigate to Campaigns
6. Verify Merchant 2's shops (if any) are shown, NOT Merchant 1's
7. (Advanced) Use network inspection to manually call GET /api/v1/merchant/shops/{merchant1_shop_id}/ while logged in as Merchant 2

**Expected Result:**
- ✓ Merchant 1 login shows Merchant 1's shops only
- ✓ Merchant 2 login shows Merchant 2's shops (empty or their own)
- ✓ No cross-account leak in UI
- ✓ Manual API call to other merchant's shop returns 404 or permission error

**Evidence to Capture:**
- Screenshot of Merchant 1 Campaigns view (Merchant 1's shops)
- Screenshot of Merchant 2 Campaigns view (empty or Merchant 2's shops only, not Merchant 1's)
- Network response for manual ownership check:
  - GET /api/v1/merchant/shops/merchant1_shop_id/ as Merchant 2
  - Expected: `status=404, detail="Not found"` (or 403 Forbidden)

**Merchant 1 Details:**  
- Username: ______________________  
- Shop ID: ______________________

**Merchant 2 Details:**  
- Username: ______________________

**Status:** [ ] PASS [ ] FAIL  
**Notes:** ________________________________________

---

## Optional: Bonus Tests (Sign-Off Enhancement)

### 🔍 11. PUBLIC VISIBILITY TEST (Requires Customer App)
**Objective:** Verify active merchant shops are visible in customer app discovery.

**Steps:**
1. Activate a merchant shop to status=active (test #5)
2. Open customer app (or use public API directly)
3. Call GET /api/v1/shops/
4. Search for the shop by name or browse list
5. Verify it appears in results

**Expected Result:**
- ✓ Shop appears in customer discovery list
- ✓ Shop details show correct name, description, location
- ✓ Shop does NOT appear if status is draft/suspended/archived

**Evidence to Capture:**
- Screenshot of customer app showing merchant shop in discovery
- Network response from GET /api/v1/shops/
  - Expected: `status=200, results includes qa_test_shop_edited_[timestamp]`

**Status:** [ ] PASS [ ] FAIL  
**Notes:** ________________________________________

---

## Summary

| Test # | Test Name | Status | Issue |
|--------|-----------|--------|-------|
| 1 | Login | [ ] PASS / [ ] FAIL | |
| 2 | Create Shop | [ ] PASS / [ ] FAIL | |
| 3 | List Shops | [ ] PASS / [ ] FAIL | |
| 4 | Edit Shop | [ ] PASS / [ ] FAIL | |
| 5 | Publish Shop | [ ] PASS / [ ] FAIL | |
| 6 | Archive Shop | [ ] PASS / [ ] FAIL | |
| 7 | Empty State | [ ] PASS / [ ] FAIL | |
| 8 | Multi-Shop Context | [ ] PASS / [ ] FAIL | |
| 9 | Logout | [ ] PASS / [ ] FAIL | |
| 10 | Ownership Protection | [ ] PASS / [ ] FAIL | |

**Total PASS:** ____/10  
**Total FAIL:** ____/10  

**Overall QA Status:** [ ] ✅ APPROVED (10/10 PASS) [ ] ⚠️ CONDITIONAL (9/10 PASS) [ ] ❌ BLOCKED (≤8/10 PASS)

---

## Sign-Off

**Tester Name:** ________________________  
**Tester Email:** ________________________  
**QA Date:** ________________________  
**Environment:** Production VPS (https://sirius-djibouti.com/api/v1)  
**Approval:** ✓ Ready for Release / ✗ Hold for Fixes

---

## Appendix: Network Inspection Tips

### iOS (Xcode Console / Network Link Conditioner)
```
In Xcode: Product → Scheme → Edit Scheme → Diagnostics
Enable Network Link Conditioner for throttling
Check console logs for network requests
```

### Android (Android Studio / Charles Proxy)
```
In Android Studio: Tools → Device Explorer → Open device explorer
Or use Chrome DevTools to inspect WebView
Or use Charles Proxy to intercept Dio requests
```

### API Endpoint Reference
```
Production Base URL: https://sirius-djibouti.com/api/v1

Auth:
POST /api/v1/auth/token/
  Request: { "username": "...", "password": "..." }
  Response: { "access": "token...", "refresh": "token..." }

Merchant Shops:
POST /api/v1/merchant/shops/
  Request: { "name": "...", "description": "...", ... }
  Response: { "id": X, "status": "draft", "slug": "...", ... }

GET /api/v1/merchant/shops/
  Response: { "count": N, "results": [...] }

GET /api/v1/merchant/shops/{id}/
  Response: { "id": X, "name": "...", ... }

PUT /api/v1/merchant/shops/{id}/
  Request: { "name": "...", "status": "...", ... }
  Response: { "id": X, "updates_reflect: true, ... }

DELETE /api/v1/merchant/shops/{id}/
  Response: (204 No Content)

Public Shops (No Auth):
GET /api/v1/shops/
GET /api/v1/shops/search/
GET /api/v1/shops/{id}/
```

