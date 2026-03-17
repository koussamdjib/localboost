# MERCHANT MULTI-SHOP CRUD - DEPLOYMENT & V VALIDATION GUIDE

**Status:** Needs final deployment on VPS  
**Date:** March 11, 2026  
**Target:** Production VPS at sirius-djibouti.com

---

## DEPLOYMENT CHECKLIST

### Phase 1: Deploy Application Files

#### 1.1 Copy Backend Model & Migration
```bash
# On VPS (via SSH):
# Copy migration file
sudo cp /tmp/0003_shop_status_and_email.py \
  /srv/localboost/backend/apps/shops/migrations/
sudo chown localboost:localboost \
  /srv/localboost/backend/apps/shops/migrations/0003_shop_status_and_email.py

# Copy updated model
sudo cp /tmp/shops_models.py \
  /srv/localboost/backend/apps/shops/models.py
sudo chown localboost:localboost \
  /srv/localboost/backend/apps/shops/models.py
```

#### 1.2 Deploy Merchant App CRUD Files
```bash
# Files already copied to /tmp (from earlier):
# - merchants_serializers.py
# - merchants_permissions.py  
# - merchants_views.py
# - merchants_urls.py

# Deploy them:
sudo cp /tmp/merchants_serializers.py \
  /srv/localboost/backend/apps/merchants/serializers.py
sudo cp /tmp/merchants_permissions.py \
  /srv/localboost/backend/apps/merchants/permissions.py
sudo cp /tmp/merchants_views.py \
  /srv/localboost/backend/apps/merchants/views.py
sudo cp /tmp/merchants_urls.py \
  /srv/localboost/backend/apps/merchants/urls.py

# Fix permissions
sudo chown localboost:localboost \
  /srv/localboost/backend/apps/merchants/*.py
```

#### 1.3 Deploy Updated API URLs Configuration
```bash
# Copy new api_urls.py with merchant route
sudo cp /tmp/api_urls_new.py \
  /srv/localboost/backend/config/api_urls.py
sudo chown localboost:localboost \
  /srv/localboost/backend/config/api_urls.py
```

**Content should be:**
```python
from django.urls import include, path

urlpatterns = [
    path("health/", include("apps.common.urls")),
    path("auth/", include("apps.accounts.urls")),
    path("shops/", include("apps.shops.urls")),
    path("merchant/", include("apps.merchants.urls")),   # <-- NEW
]
```

### Phase 2: Run Migrations

```bash
# On VPS:
cd /srv/localboost/backend
source /etc/localboost/localboost-backend.env
source /srv/localboost/.venv/bin/activate

# Check migration status
python manage.py showmigrations shops
# Should show:
#  [X] 0001_initial
#  [X] 0002_shop_category_shop_cover_image_url_shop_logo_url_and_more
#  [X] 0003_shop_status_and_email

# If 0003 not applied:
python manage.py migrate shops
```

### Phase 3: Verify Schema

```bash
# Connect to PostgreSQL and verify:
psql -h 127.0.0.1 -U localboost -d localboost -c "
  SELECT column_name, data_type 
  FROM information_schema.columns 
  WHERE table_name='shops_shop' 
  AND column_name IN ('status', 'email')
  ORDER BY column_name;
"
# Should return:
#  email     | character varying
#  status    | character varying
```

### Phase 4: Restart Service

```bash
# Restart Django backend
sudo systemctl restart localboost-backend

# Verify it's running
sudo systemctl status localboost-backend

# Check logs (last 50 lines)
sudo journalctl -u localboost-backend -n 50
```

---

## VALIDATION TEST SEQUENCE

### Test 1: Django Health Check

```bash
cd /srv/localboost/backend
source /etc/localboost/localboost-backend.env
source /srv/localboost/.venv/bin/activate
python manage.py check
```

**Expected Output:** "System check identified no issues (0 silenced)."

---

### Test 2: Public Shops Endpoint (No Auth Required)

```bash
curl -X GET "https://sirius-djibouti.com/api/v1/shops/" \
  -H "Content-Type: application/json" \
  -k  # Skip SSL verification for testing
```

**Expected:**
- Status: 200
- Response includes list of shops with `status=active` and `is_active=true` only

---

### Test 3: Create Test Merchants & Authenticate

```bash
# Step 1: Create test merchants via Django shell
cd /srv/localboost/backend
source /etc/localboost/localboost-backend.env
source /srv/localboost/.venv/bin/activate
python manage.py shell <<'PYTHON_EOF'
from django.contrib.auth import get_user_model
from apps.accounts.models import UserRole
from apps.merchants.models import MerchantProfile

User = get_user_model()

# Delete old test data
User.objects.filter(email__startswith='test_deploy_').delete()

# Create merchant 1
user1 = User.objects.create_user(
    email='test_deploy_m1@test.com',
    password='DeployTest123!',
    role=UserRole.MERCHANT
)
m1 = MerchantProfile.objects.get_or_create(user=user1)[0]

# Create merchant 2 (for ownership boundary testing)
user2 = User.objects.create_user(
    email='test_deploy_m2@test.com',
    password='DeployTest123!',
    role=UserRole.MERCHANT
)
m2 = MerchantProfile.objects.get_or_create(user=user2)[0]

print(f"✓ Merchant 1: {user1.email}")
print(f"✓ Merchant 2: {user2.email}")
PYTHON_EOF
```

```bash
# Step 2: Login to get JWT token
curl -X POST "https://sirius-djibouti.com/api/v1/accounts/login/" \
  -H "Content-Type: application/json" \
  -k \
  -d '{
    "email": "test_deploy_m1@test.com",
    "password": "DeployTest123!"
  }'
```

**Expected Response (200):**
```json
{
  "access": "eyJ0eXAiOiJKV1QiLCJhbGc...",
  "refresh": "eyJ0eXAiOiJKV1QiLCJhbGc..."
}
```

**Save:** `export TOKEN="<access_value>"`

---

### Test 4: List Merchant Shops (Empty)

```bash
curl -X GET "https://sirius-djibouti.com/api/v1/merchant/shops/" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -k
```

**Expected (200):**
```json
[]
```

---

### Test 5: Create Merchant Shop (Draft)

```bash
curl -X POST "https://sirius-djibouti.com/api/v1/merchant/shops/" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -k \
  -d '{
    "name": "Coffee Corner",
    "status": "draft",
    "description": "Premium coffee",
    "category": "Restaurants & Cafés",
    "phoneNumber": "+253 21 35 22 33",
    "email": "coffee@corner.dj",
    "address": "Rue du Marché",
    "city": "Djibouti",
    "country": "Djibouti"
  }'
```

**Expected (201):**
```json
{
  "id": 1,
  "name": "Coffee Corner",
  "slug": "coffee-corner",
  "status": "draft",
  "is_active": false,
  "merchant_profile": 1,
  ...
}
```

**Critical Check:** `is_active` should be `false` (only `active` status sets it to `true`)

---

### Test 6: Create Merchant Shop (Active)

```bash
curl -X POST "https://sirius-djibouti.com/api/v1/merchant/shops/" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -k \
  -d '{
    "name": "Boutique Élégance",
    "status": "active",
    "description": "Fashion & accessories",
    "category": "Shops",
    "phoneNumber": "+253 21 35 22 44",
    "email": "boutique@elegance.dj",
    "address": "Rue Principale",
    "city": "Djibouti",
    "country": "Djibouti"
  }'
```

**Expected (201):** Shop with `status=active` and `is_active=true`

---

### Test 7: Get Shop Detail

```bash
SHOP_ID=2  # From above response
curl -X GET "https://sirius-djibouti.com/api/v1/merchant/shops/$SHOP_ID/" \
  -H "Authorization: Bearer $TOKEN" \
  -k
```

**Expected (200):** Complete shop details

---

### Test 8: Update Shop (Change Status)

```bash
SHOP_ID=2
curl -X PUT "https://sirius-djibouti.com/api/v1/merchant/shops/$SHOP_ID/" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -k \
  -d '{
    "name": "Boutique Élégance",
    "status": "suspended",
    "description": "Fashion & accessories (temporarily closed)",
    "category": "Shops",
    "phoneNumber": "+253 21 35 22 44",
    "email": "boutique@elegance.dj",
    "address": "Rue Principale",
    "city": "Djibouti",
    "country": "Djibouti"
  }'
```

**Expected (200):** Updated shop with `status=suspended` and `is_active=false`

---

### Test 9: Delete/Archive Shop

```bash
SHOP_ID=2
curl -X DELETE "https://sirius-djibouti.com/api/v1/merchant/shops/$SHOP_ID/" \
  -H "Authorization: Bearer $TOKEN" \
  -k
```

**Expected:** Status 204 (No Content)

**Verify it's archived:**
```bash
curl -X GET "https://sirius-djibouti.com/api/v1/merchant/shops/$SHOP_ID/" \
  -H "Authorization: Bearer $TOKEN" \
  -k
```

Should return shop with `status=archived` and `is_active=false`

---

### Test 10: Ownership Boundary (Critical Security Test)

```bash
# Step 1: Get Merchant 2's token
TOKEN2=$(curl -s -X POST "https://sirius-djibouti.com/api/v1/accounts/login/" \
  -H "Content-Type: application/json" \
  -k \
  -d '{
    "email": "test_deploy_m2@test.com",
    "password": "DeployTest123!"
  }' | grep -o '"access":"[^"]*' | cut -d'"' -f4)

# Step 2: Try to access Merchant 1's shop
SHOP_ID=1
curl -X GET "https://sirius-djibouti.com/api/v1/merchant/shops/$SHOP_ID/" \
  -H "Authorization: Bearer $TOKEN2" \
  -k -w "\nHTTP_STATUS:%{http_code}\n"
```

**Expected Result:**
- HTTP Status: 404 or 403
- Response: `{"detail":"Not found."}` or `{"detail":"...permission denied..."}`

**✓ If this test returns 404/403 with no shop data, ownership protection is working correctly!**

---

### Test 11: Public Discovery Only Shows Active Shops

```bash
# Merchant 1: Create a draft and an active shop
# Then check public /api/v1/shops/

curl -X GET "https://sirius-djibouti.com/api/v1/shops/" \
  -H "Content-Type: application/json" \
  -k
```

**Verify:** Only shops with `status=active` and `is_active=true` appear in response

---

## TROUBLESHOOTING

### Issue: /api/v1/merchant/shops/ returns 404

**Cause:** Merchant route not registered in api_urls.py

**Fix:**
```bash
# Check file:
sudo cat /srv/localboost/backend/config/api_urls.py

# Should contain: path("merchant/", include("apps.merchants.urls"))

# If missing, deploy new version and restart:
sudo systemctl restart localboost-backend
```

### Issue: Shop model doesn't have ShopStatus

**Cause:** shops/models.py not updated

**Fix:**
```bash
# Verify model has:
sudo grep -n "class ShopStatus" /srv/localboost/backend/apps/shops/models.py

# If not found, redeploy:
sudo systemctl restart localboost-backend
```

### Issue: Migration 0003 says "No migrations to apply"

**Cause:** Migration file not in migrations directory

**Fix:**
```bash
# Check migrations present:
ls -la /srv/localboost/backend/apps/shops/migrations/000*.py

# Should include: 0003_shop_status_and_email.py

# If missing, copy it first, then:
python manage.py migrate
```

### Issue: is_active not syncing to status

**Cause:** Serializer not calling sync method

**Fix:**
```bash
# Check serializer has _sync_is_active:
sudo grep -A 10 "_sync_is_active" \
  /srv/localboost/backend/apps/merchants/serializers.py
```

---

## SUCCESS CRITERIA - MARK ALL ✓ WHEN COMPLETE

- [ ] **A. Migration 0003 Applied**
  ```bash
  python manage.py showmigrations shops | grep "0003.*\[X\]"
  ```

- [ ] **B. Django Checks Pass**
  ```bash
  python manage.py check
  ```

- [ ] **C. Public Shops Endpoint Works**
  ```bash
  curl -k https://sirius-djibouti.com/api/v1/shops/
  # Status: 200
  ```

- [ ] **D. Login Creates Token**
  ```bash
  # Status: 200
  # Response contains "access" field
  ```

- [ ] **E. POST /merchant/shops/ Returns 201**
  ```bash
  # Status: 201
  # Response includes id, slug, status, is_active
  ```

- [ ] **F. GET /merchant/shops/ Lists Shops**
  ```bash
  # Status: 200
  # Returns list of merchant's shops
  ```

- [ ] **G. GET /merchant/shops/{id}/ Returns Detail**
  ```bash
  # Status: 200
  ```

- [ ] **H. PUT /merchant/shops/{id}/ Updates Shop**
  ```bash
  # Status: 200
  # Changes reflected
  ```

- [ ] **I. DELETE /merchant/shops/{id}/ Archives Shop**
  ```bash
  # Status: 204
  # Shop now has status=archived, is_active=false
  ```

- [ ] **J. Ownership Boundary Enforced**
  ```bash
  # Merchant 2 accessing Merchant 1's shop: Status 404/403
  ```

- [ ] **K. Public Discovery Filters to Active Only**
  ```bash
  # /api/v1/shops/ only returns shops with status=active
  ```

---

## NEXT STEPS AFTER VALIDATION

1. **Flutter Merchant App**
   - Build APK: `flutter build apk --release`
   - Install on merchant device
   - Test MyShopsScreen, CreateShopScreen, EditShopScreen
   - Verify shop selection updates dashboard context

2. **Customer App**
   - No changes needed
   - Public discovery already filters to active shops
   - Existing shop list endpoints work as before

3. **Production Monitoring**
   - Monitor VPS error logs after deployment
   - Watch for migration issues
   - Verify JWT tokens valid for new endpoints
   - Monitor performance (query counts for shop lists)

4. **Next Feature**
   - **Deals Management** (merchant creates deals for shops)
   - **Flyers Management** (merchant uploads flyers for shops)
   - Both will scope to current `selectedShop` from ShopProvider

---

## DOCUMENTATION LINKS

- **Backend Implementation:** [/backend/apps/merchants/](./backend/apps/merchants/)
- **Flutter Implementation:** [/merchant/lib/screens/shops/](./merchant/lib/screens/shops/)
- **API Docs:** See MERCHANT_SHOP_VALIDATION_MANUAL.md
- **Validation Tests:** See above

---

**Created:** March 11, 2026 09:55 UTC  
**Status:** Deployment phase - needs manual execution on VPS due to network/terminal constraints
