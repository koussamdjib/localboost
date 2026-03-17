#!/bin/bash
# Simplified merchant multi-shop CRUD validation via API testing

API_BASE="https://sirius-djibouti.com/api/v1"

echo "================================================================================"
echo "MERCHANT MULTI-SHOP CRUD RUNTIME VALIDATION"
echo "================================================================================"
echo ""

# ==============================================================================
# SECTION A: DJANGO CHECKS ON VPS
# ==============================================================================
echo "[A] DJANGO SYSTEM CHECKS"
echo "--------------------------------------------------------------------------------"

ssh -p 2222 ubuntu@sirius-djibouti.com <<'SSH_SECTION_A'
cd /srv/localboost/backend
source /etc/localboost/localboost-backend.env
source /srv/localboost/.venv/bin/activate
echo "Running django check..."
python manage.py check 2>&1 | head -5
if [ $? -eq 0 ]; then
    echo "✓ Django system checks PASSED"
fi
SSH_SECTION_A

# ==============================================================================
# SECTION B: MIGRATION STATUS
# ==============================================================================
echo ""
echo "[B] MIGRATION STATUS"
echo "--------------------------------------------------------------------------------"

ssh -p 2222 ubuntu@sirius-djibouti.com <<'SSH_SECTION_B'
cd /srv/localboost/backend
source /etc/localboost/localboost-backend.env
source /srv/localboost/.venv/bin/activate
python manage.py showmigrations shops 2>&1
SSH_SECTION_B

# ==============================================================================
# SECTION C: TEST SETUP & API TESTING
# ==============================================================================
echo ""
echo "[C] TEST MERCHANT SETUP"
echo "--------------------------------------------------------------------------------"

ssh -p 2222 ubuntu@sirius-djibouti.com <<'SSH_SECTION_C'
cd /srv/localboost/backend
source /etc/localboost/localboost-backend.env
source /srv/localboost/.venv/bin/activate
python manage.py shell <<'DJANGO_SETUP'
from django.contrib.auth import get_user_model
from apps.accounts.models import UserRole
from apps.merchants.models import MerchantProfile

User = get_user_model()

# Clean up old
User.objects.filter(email__startswith='valtest_').delete()

# Create test merchants
user1 = User.objects.create_user(
    email='valtest_m1@test.com',
    password='TestPass123!',
    role=UserRole.MERCHANT
)
merchant1 = MerchantProfile.objects.get_or_create(user=user1)[0]

user2 = User.objects.create_user(
    email='valtest_m2@test.com',
    password='TestPass123!',
    role=UserRole.MERCHANT
)
merchant2 = MerchantProfile.objects.get_or_create(user=user2)[0]

print(f"✓ Merchant 1: {user1.email}")
print(f"✓ Merchant 2: {user2.email}")
DJANGO_SETUP
SSH_SECTION_C

# ==============================================================================
# SECTION D: API TESTS
# ==============================================================================
echo ""
echo "[D] API ENDPOINT TESTS"
echo "--------------------------------------------------------------------------------"

# Get merchant tokens
echo "1. LOGIN & GET TOKENS"
TOKEN_RESPONSE=$(curl -s -X POST "$API_BASE/accounts/login/" \
  -H "Content-Type: application/json" \
  -d '{"email":"valtest_m1@test.com","password":"TestPass123!"}')

TOKEN1=$(echo "$TOKEN_RESPONSE" | grep -o '"access":"[^"]*' | cut -d'"' -f4)

if [ ! -z "$TOKEN1" ]; then
    echo "   ✓ Merchant 1 token obtained (${TOKEN1:0:20}...)"
else
    echo "   ✗ Failed to obtain token"
    echo "   Response: ${TOKEN_RESPONSE:0:100}"
fi

TOKEN_RESPONSE2=$(curl -s -X POST "$API_BASE/accounts/login/" \
  -H "Content-Type: application/json" \
  -d '{"email":"valtest_m2@test.com","password":"TestPass123!"}')

TOKEN2=$(echo "$TOKEN_RESPONSE2" | grep -o '"access":"[^"]*' | cut -d'"' -f4)

if [ ! -z "$TOKEN2" ]; then
    echo "   ✓ Merchant 2 token obtained (${TOKEN2:0:20}...)"
fi

# List shops
echo ""
echo "2. LIST MERCHANT SHOPS (merchant 1)"
LIST_RESPONSE=$(curl -s -X GET "$API_BASE/merchant/shops/" \
  -H "Authorization: Bearer $TOKEN1" \
  2>&1)

if echo "$LIST_RESPONSE" | grep -q "count\|detail\|error"; then
    STATUS=$(curl -s -w "%{http_code}" -o /dev/null -X GET "$API_BASE/merchant/shops/" \
      -H "Authorization: Bearer $TOKEN1")
    echo "   Status: $STATUS"
    echo "   Response (first 80 chars): ${LIST_RESPONSE:0:80}"
    if [ "$STATUS" = "200" ]; then
        echo "   ✓ List endpoint working"
    fi
else
    echo "   Response: $LIST_RESPONSE"
fi

# Create shop
echo ""
echo "3. CREATE SHOP (merchant 1)"
CREATE_RESPONSE=$(curl -s -w "\nHTTP_STATUS:%{http_code}" -X POST "$API_BASE/merchant/shops/" \
  -H "Authorization: Bearer $TOKEN1" \
  -H "Content-Type: application/json" \
  -d '{
    "name":"Validation Test Shop",
    "status":"draft",
    "description":"Test shop for validation",
    "category":"Shops",
    "phoneNumber":"+253 21 35 22 33",
    "email":"test@shop.com",
    "address":"Rue du Test",
    "city":"Djibouti",
    "country":"Djibouti"
  }')

HTTP_STATUS=$(echo "$CREATE_RESPONSE" | grep "HTTP_STATUS:" | cut -d':' -f2)
SHOP_DATA=$(echo "$CREATE_RESPONSE" | sed '$d')

echo "   Status: $HTTP_STATUS"
if [ "$HTTP_STATUS" = "201" ]; then
    echo "   ✓ Shop created successfully"
    SHOP_ID=$(echo "$SHOP_DATA" | grep -o '"id":[0-9]*' | cut -d':' -f2 | head -1)
    if [ ! -z "$SHOP_ID" ]; then
        echo "   Shop ID: $SHOP_ID"
    fi
else
    echo "   Response: ${SHOP_DATA:0:150}"
fi

# Get shop detail (if we have an ID)
if [ ! -z "$SHOP_ID" ]; then
    echo ""
    echo "4. GET SHOP DETAIL (merchant 1, shop ID: $SHOP_ID)"
    DETAIL_STATUS=$(curl -s -w "%{http_code}" -o /dev/null -X GET "$API_BASE/merchant/shops/$SHOP_ID/" \
      -H "Authorization: Bearer $TOKEN1")
    echo "   Status: $DETAIL_STATUS"
    if [ "$DETAIL_STATUS" = "200" ]; then
        echo "   ✓ Get detail successful"
    fi
    
    # Ownership test
    echo ""
    echo "5. OWNERSHIP TEST - Merchant 2 try to access Merchant 1 shop"
    M2_STATUS=$(curl -s -w "%{http_code}" -o /dev/null -X GET "$API_BASE/merchant/shops/$SHOP_ID/" \
      -H "Authorization: Bearer $TOKEN2")
    echo "   Status: $M2_STATUS"
    if [ "$M2_STATUS" = "404" ] || [ "$M2_STATUS" = "403" ]; then
        echo "   ✓ Access properly denied (expected 404/403, got $M2_STATUS)"
    else
        echo "   ✗ Unexpected status (expected 403/404, got $M2_STATUS)"
    fi
fi

# ==============================================================================
# SECTION E: PUBLIC DISCOVERY FILTERING
# ==============================================================================
echo ""
echo "[E] PUBLIC DISCOVERY FILTERING"
echo "--------------------------------------------------------------------------------"

echo "1. GET /api/v1/shops/ (public, no auth)"
DISCOVER_STATUS=$(curl -s -w "%{http_code}" -o /tmp/discover_response.json -X GET "$API_BASE/shops/")
echo "   Status: $DISCOVER_STATUS"
if [ "$DISCOVER_STATUS" = "200" ]; then
    echo "   ✓ Public discovery endpoint working"
    SHOP_COUNT=$(grep -o '"count":[0-9]*' /tmp/discover_response.json | cut -d':' -f2 | head -1)
    if [ ! -z "$SHOP_COUNT" ]; then
        echo "   Found $SHOP_COUNT shops in discovery"
    fi
else
    echo "   ✗ Status: $DISCOVER_STATUS"
fi

echo ""
echo "2. GET /api/v1/shops/search/ (public search)"
SEARCH_STATUS=$(curl -s -w "%{http_code}" -o /tmp/search_response.json -X GET "$API_BASE/shops/search/?q=test")
echo "   Status: $SEARCH_STATUS"
if [ "$SEARCH_STATUS" = "200" ]; then
    echo "   ✓ Public search endpoint working"
fi

# ==============================================================================
# SECTION F: CLEANUP
# ==============================================================================
echo ""
echo "[F] CLEANUP TEST DATA"
echo "--------------------------------------------------------------------------------"

ssh -p 2222 ubuntu@sirius-djibouti.com <<'SSH_CLEANUP'
cd /srv/localboost/backend
source /etc/localboost/localboost-backend.env
source /srv/localboost/.venv/bin/activate
python manage.py shell <<'DJANGO_CLEANUP'
from django.contrib.auth import get_user_model
User = get_user_model()
count, _ = User.objects.filter(email__startswith='valtest_').delete()
print(f"✓ Cleaned up {count} test users and associated shops")
DJANGO_CLEANUP
SSH_CLEANUP

# ==============================================================================
# CURL REFERENCE
# ==============================================================================
echo ""
echo "[G] CURL COMMAND REFERENCE FOR MANUAL TESTING"
echo "--------------------------------------------------------------------------------"
echo ""
cat <<'CURL_REF'
# 1. GET TOKEN
curl -X POST "https://sirius-djibouti.com/api/v1/accounts/login/" \
  -H "Content-Type: application/json" \
  -d '{"email":"valtest_m1@test.com","password":"TestPass123!"}'
# Copy the "access" token value

# 2. LIST MERCHANT SHOPS
curl -X GET "https://sirius-djibouti.com/api/v1/merchant/shops/" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json"

# 3. CREATE MERCHANT SHOP
curl -X POST "https://sirius-djibouti.com/api/v1/merchant/shops/" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "name":"My Shop",
    "status":"draft",
    "category":"Shops",
    "phoneNumber":"+253 21 35 22 33",
    "address":"Rue Test",
    "city":"Djibouti",
    "country":"Djibouti"
  }'

# 4. GET SHOP DETAIL
curl -X GET "https://sirius-djibouti.com/api/v1/merchant/shops/1/" \
  -H "Authorization: Bearer YOUR_TOKEN"

# 5. UPDATE SHOP
curl -X PUT "https://sirius-djibouti.com/api/v1/merchant/shops/1/" \
  -H "Authorization: Bearer YOUR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"name":"Updated Shop","status":"active",...all fields...}'

# 6. DELETE/ARCHIVE SHOP
curl -X DELETE "https://sirius-djibouti.com/api/v1/merchant/shops/1/" \
  -H "Authorization: Bearer YOUR_TOKEN"

# 7. PUBLIC SHOPS (no auth needed)
curl -X GET "https://sirius-djibouti.com/api/v1/shops/"

# 8. PUBLIC SEARCH (no auth needed)
curl -X GET "https://sirius-djibouti.com/api/v1/shops/search/?q=coffee"
CURL_REF

# ==============================================================================
# FINAL SUMMARY
# ==============================================================================
echo ""
echo "================================================================================"
echo "RUNTIME VALIDATION SUMMARY"
echo "================================================================================"
echo ""
echo "Validation Checklist:"
echo "  ☐ [A] Django system checks PASS"
echo "  ☐ [B] Migration 0003 applied"
echo "  ☐ [C] Test merchants created"
echo "  ☐ [D] API endpoints working"
echo "  ☐ [E] Public discovery filtering active"
echo "  ☐ [F] Cleanup completed"
echo ""
echo "See output above for results on each check."
echo ""
echo "NEXT STEPS:"
echo "  1. Verify all ✓ checks in output above"
echo "  2. Test with curl commands above"
echo "  3. Deploy Flutter app build"
echo "  4. Test on merchant device"
echo ""
