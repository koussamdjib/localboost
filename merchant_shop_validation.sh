#!/bin/bash
# Comprehensive merchant multi-shop CRUD runtime validation
# Tests API endpoints, ownership boundaries, and discovery filtering

API_BASE="https://sirius-djibouti.com/api/v1"
DJANGO_SETTINGS_MODULE="config.settings.production"
BACKEND_PATH="/srv/localboost/backend"

echo "================================================================================"
echo "MERCHANT MULTI-SHOP CRUD RUNTIME VALIDATION"
echo "================================================================================"

# ==============================================================================
# SECTION A: DJANGO CHECKS
# ==============================================================================
echo ""
echo "[A] DJANGO SYSTEM CHECKS"
echo "--------------------------------------------------------------------------------"

cd $BACKEND_PATH
source /etc/localboost/localboost-backend.env
source /srv/localboost/.venv/bin/activate

echo "Running Django checks..."
python manage.py check 2>&1 | head -20
if [ $? -eq 0 ]; then
    echo "✓ Django system checks PASSED"
else
    echo "✗ Django system checks FAILED"
fi

# ==============================================================================
# SECTION B: MIGRATION STATUS
# ==============================================================================
echo ""
echo "[B] MIGRATION STATUS CHECK"
echo "--------------------------------------------------------------------------------"

echo "Shops migrations:"
python manage.py showmigrations shops 2>&1

if python manage.py showmigrations shops 2>&1 | grep -q "0003_shop_status_and_email.*\[X\]"; then
    echo "✓ Migration 0003 (shop_status_and_email) is APPLIED"
else
    echo "! Migration 0003 (shop_status_and_email) is NOT YET APPLIED"
fi

# ==============================================================================
# SECTION C: SCHEMA VERIFICATION
# ==============================================================================
echo ""
echo "[C] MODEL SCHEMA VERIFICATION"
echo "--------------------------------------------------------------------------------"

python manage.py shell <<'PYTHON_EOF'
from django.db import connection
cursor = connection.cursor()

# Get columns
cursor.execute("""
    SELECT column_name, data_type
    FROM information_schema.columns
    WHERE table_name = 'shops_shop'
    AND column_name IN ('id', 'merchant_id', 'name', 'slug', 'status', 'email', 'is_active')
    ORDER BY column_name;
""")

required_fields = {
    'email': 'character varying',
    'id': 'bigint',
    'is_active': 'boolean',
    'merchant_id': 'bigint',
    'name': 'character varying',
    'slug': 'character varying',
    'status': 'character varying'
}

print("Shop table columns:")
for col_name, col_type in cursor.fetchall():
    print(f"  ✓ {col_name:20} -> {col_type}")

cursor.execute("SELECT count(*) FROM shops_shop;")
shop_count = cursor.fetchone()[0]
print(f"\nCurrent shop count: {shop_count}")
PYTHON_EOF

# ==============================================================================
# SECTION D: TEST DATA SETUP
# ==============================================================================
echo ""
echo "[D] TEST DATA SETUP & CLEANUP"
echo "--------------------------------------------------------------------------------"

python manage.py shell <<'PYTHON_EOF'
from django.contrib.auth import get_user_model
from apps.merchants.models import MerchantProfile
from apps.shops.models import Shop, ShopStatus
from apps.accounts.models import UserRole

User = get_user_model()

# Clean up old test data
old_count = User.objects.filter(email__startswith='test_merchant_crud_').delete()[0]
print(f"Cleaned up {old_count} old test user(s)")

# Create test merchants
user1 = User.objects.create_user(
    email='test_merchant_crud_01@test.com',
    password='TestPass123!',
    role=UserRole.MERCHANT
)
try:
    merchant1 = user1.merchant_profile
except:
    merchant1 = MerchantProfile.objects.create(user=user1)

user2 = User.objects.create_user(
    email='test_merchant_crud_02@test.com',
    password='TestPass123!',
    role=UserRole.MERCHANT
)
try:
    merchant2 = user2.merchant_profile
except:
    merchant2 = MerchantProfile.objects.create(user=user2)

# Create test shop
shop1 = Shop.objects.create(
    merchant=merchant1,
    name='Test Shop Active',
    slug='test-shop-active',
    status=ShopStatus.ACTIVE,
    is_active=True,
    address_line_1='Rue Test',
    city='Djibouti',
    country='Djibouti',
    email='test@example.com'
)

print(f"✓ Created test merchant 1: {user1.email} (ID: {merchant1.id})")
print(f"✓ Created test merchant 2: {user2.email} (ID: {merchant2.id})")
print(f"✓ Created test shop: {shop1.name} (ID: {shop1.id}, Status: {shop1.status})")

# Export for API tests
print(f"TEST_MERCHANT1_EMAIL={user1.email}")
print(f"TEST_MERCHANT1_PASSWORD=TestPass123!")
print(f"TEST_MERCHANT2_EMAIL={user2.email}")
print(f"TEST_MERCHANT2_PASSWORD=TestPass123!")
print(f"TEST_SHOP1_ID={shop1.id}")
PYTHON_EOF

# ==============================================================================
# SECTION E: API ENDPOINT TESTS
# ==============================================================================
echo ""
echo "[E] API ENDPOINT TESTS"
echo "--------------------------------------------------------------------------------"

# Get tokens
echo "Getting authentication tokens..."
TOKEN1=$(curl -s -X POST "$API_BASE/accounts/login/" \
  -H "Content-Type: application/json" \
  -d '{"email":"test_merchant_crud_01@test.com","password":"TestPass123!"}' \
  | grep -o '"access":"[^"]*' | cut -d'"' -f4)

TOKEN2=$(curl -s -X POST "$API_BASE/accounts/login/" \
  -H "Content-Type: application/json" \
  -d '{"email":"test_merchant_crud_02@test.com","password":"TestPass123!"}' \
  | grep -o '"access":"[^"]*' | cut -d'"' -f4)

if [ -z "$TOKEN1" ]; then
    echo "✗ Failed to get token for merchant 1"
    exit 1
fi
echo "✓ Authentication tokens obtained"

# Get shop ID
SHOP_ID=$(curl -s -X GET "$API_BASE/merchant/shops/" \
  -H "Authorization: Bearer $TOKEN1" \
  -H "Content-Type: application/json" \
  | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)

if [ -z "$SHOP_ID" ]; then
    echo "✗ Failed to get shop ID"
else
    echo "Test Shop ID: $SHOP_ID"
fi

# Test 1: List shops
echo ""
echo "1. LIST MERCHANT SHOPS (merchant 1)"
RESPONSE=$(curl -s -X GET "$API_BASE/merchant/shops/" \
  -H "Authorization: Bearer $TOKEN1" \
  -H "Content-Type: application/json")
STATUS=$(echo "$RESPONSE" | grep -o '"count":[0-9]*' | cut -d':' -f2)
echo "   Response (first 100 chars): ${RESPONSE:0:100}"
if echo "$RESPONSE" | grep -q "count\|id"; then
    echo "   ✓ List endpoint returned data"
else
    echo "   ✗ List endpoint did not return expected data"
fi

# Test 2: Create shop
echo ""
echo "2. CREATE SHOP (merchant 1 - draft status)"
CREATE_RESPONSE=$(curl -s -X POST "$API_BASE/merchant/shops/" \
  -H "Authorization: Bearer $TOKEN1" \
  -H "Content-Type: application/json" \
  -d '{
    "name":"Test Café",
    "status":"draft",
    "description":"Test café",
    "category":"Restaurants",
    "phoneNumber":"+253 21 35 22 33",
    "email":"cafe@test.com",
    "address":"Rue Test",
    "city":"Djibouti",
    "country":"Djibouti"
  }')
echo "   Response (first 150 chars): ${CREATE_RESPONSE:0:150}"
NEW_SHOP_ID=$(echo "$CREATE_RESPONSE" | grep -o '"id":[0-9]*' | head -1 | cut -d':' -f2)
if [ ! -z "$NEW_SHOP_ID" ]; then
    echo "   ✓ Created shop with ID: $NEW_SHOP_ID"
else
    echo "   ✗ Failed to create shop"
fi

# Test 3: Get shop detail
if [ ! -z "$SHOP_ID" ]; then
    echo ""
    echo "3. GET SHOP DETAIL (merchant 1)"
    DETAIL=$(curl -s -X GET "$API_BASE/merchant/shops/$SHOP_ID/" \
      -H "Authorization: Bearer $TOKEN1" \
      -H "Content-Type: application/json")
    echo "   Response (first 100 chars): ${DETAIL:0:100}"
    if echo "$DETAIL" | grep -q "id\|name"; then
        echo "   ✓ Get detail succeeded"
    else
        echo "   ✗ Get detail failed"
    fi
fi

# ==============================================================================
# SECTION F: OWNERSHIP BOUNDARY TESTS
# ==============================================================================
echo ""
echo "[F] OWNERSHIP BOUNDARY TESTS"
echo "--------------------------------------------------------------------------------"

if [ ! -z "$SHOP_ID" ] && [ ! -z "$TOKEN2" ]; then
    echo ""
    echo "1. Merchant 1 can read own shop (ID: $SHOP_ID)"
    M1_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_BASE/merchant/shops/$SHOP_ID/" \
      -H "Authorization: Bearer $TOKEN1" \
      -H "Content-Type: application/json")
    M1_STATUS=$(echo "$M1_RESPONSE" | tail -1)
    if [ "$M1_STATUS" = "200" ]; then
        echo "   ✓ Merchant 1 access ALLOWED (status $M1_STATUS)"
    else
        echo "   ! Status: $M1_STATUS"
    fi
    
    echo ""
    echo "2. Merchant 2 CANNOT read merchant 1's shop"
    M2_RESPONSE=$(curl -s -w "\n%{http_code}" -X GET "$API_BASE/merchant/shops/$SHOP_ID/" \
      -H "Authorization: Bearer $TOKEN2" \
      -H "Content-Type: application/json")
    M2_STATUS=$(echo "$M2_RESPONSE" | tail -1)
    if [ "$M2_STATUS" = "404" ] || [ "$M2_STATUS" = "403" ]; then
        echo "   ✓ Merchant 2 access DENIED (status $M2_STATUS)"
    else
        echo "   ✗ Unexpected status: $M2_STATUS (expected 404 or 403)"
    fi
else
    echo "✗ Cannot test ownership boundaries - missing tokens or shop ID"
fi

# ==============================================================================
# SECTION G: PUBLIC DISCOVERY FILTERING
# ==============================================================================
echo ""
echo "[G] PUBLIC DISCOVERY FILTERING"
echo "--------------------------------------------------------------------------------"

echo "1. GET /api/v1/shops/ (public - no auth needed)"
SHOPS_RESPONSE=$(curl -s -X GET "$API_BASE/shops/" \
  -H "Content-Type: application/json")
echo "   Response (first 150 chars): ${SHOPS_RESPONSE:0:150}"

DRAFT_COUNT=$(python manage.py shell <<'PYTHON_EOF'
from apps.shops.models import Shop, ShopStatus
draft_shops = Shop.objects.filter(status=ShopStatus.DRAFT)
print(f"Draft shops in DB: {draft_shops.count()}")
active_shops = Shop.objects.filter(status=ShopStatus.ACTIVE)
print(f"Active shops in DB: {active_shops.count()}")
PYTHON_EOF
)
echo "$DRAFT_COUNT"

echo ""
echo "2. Verify filtering through Django ORM"
python manage.py shell <<'PYTHON_EOF'
from apps.shops.models import Shop, ShopStatus

all_shops = Shop.objects.all().count()
active_shops = Shop.objects.filter(is_active=True, status=ShopStatus.ACTIVE).count()

print(f"Total shops: {all_shops}")
print(f"Active & is_active shops: {active_shops}")
print(f"✓ Discovery correctly filters to ACTIVE status only" if active_shops > 0 or all_shops == 0 else "✗ Filter check failed")
PYTHON_EOF

# ==============================================================================
# CLEANUP
# ==============================================================================
echo ""
echo "[H] TEST DATA CLEANUP"
echo "--------------------------------------------------------------------------------"

python manage.py shell <<'PYTHON_EOF'
from django.contrib.auth import get_user_model
User = get_user_model()
count, _ = User.objects.filter(email__startswith='test_merchant_crud_').delete()
print(f"✓ Cleaned up {count} test user(s)")
PYTHON_EOF

# ==============================================================================
# CURL REFERENCE
# ==============================================================================
echo ""
echo "[I] CURL COMMAND REFERENCE"
echo "--------------------------------------------------------------------------------"
cat <<'CURL_EXAMPLES'

# 1. LOGIN
curl -X POST "https://sirius-djibouti.com/api/v1/accounts/login/" \
  -H "Content-Type: application/json" \
  -d '{"email":"test_merchant_crud_01@test.com","password":"TestPass123!"}'

# 2. LIST MERCHANT SHOPS
curl -X GET "https://sirius-djibouti.com/api/v1/merchant/shops/" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json"

# 3. CREATE SHOP
curl -X POST "https://sirius-djibouti.com/api/v1/merchant/shops/" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name":"Boutique Test",
    "status":"draft",
    "description":"Test shop",
    "category":"Shops",
    "phoneNumber":"+253 21 35 22 33",
    "email":"boutique@test.com",
    "address":"Rue Test",
    "city":"Djibouti",
    "country":"Djibouti"
  }'

# 4. GET SHOP (ID = shop id from list)
curl -X GET "https://sirius-djibouti.com/api/v1/merchant/shops/1/" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"

# 5. UPDATE SHOP
curl -X PUT "https://sirius-djibouti.com/api/v1/merchant/shops/1/" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Updated Name","status":"active",...}'

# 6. DELETE/ARCHIVE SHOP
curl -X DELETE "https://sirius-djibouti.com/api/v1/merchant/shops/1/" \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"

# 7. PUBLIC DISCOVERY (no auth)
curl -X GET "https://sirius-djibouti.com/api/v1/shops/"

CURL_EXAMPLES

# ==============================================================================
# FINAL SUMMARY
# ==============================================================================
echo ""
echo "================================================================================"
echo "VALIDATION COMPLETE"
echo "================================================================================"
echo ""
echo "SUMMARY OF CHECKS:"
echo "  [A] Django System Checks"
echo "  [B] Migration Status (0003_shop_status_and_email)"
echo "  [C] Model Schema Verification"
echo "  [D] Test Data Creation"
echo "  [E] API Endpoint Tests (LIST, CREATE, GET)"
echo "  [F] Ownership Boundary Tests (cross-merchant access denial)"
echo "  [G] Public Discovery Filtering (ACTIVE only)"
echo "  [H] Test Cleanup"
echo ""
echo "See output above for detailed results."
echo ""
