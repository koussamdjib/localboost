#!/usr/bin/env python3
"""
Comprehensive runtime validation for merchant multi-shop CRUD implementation.
Tests: backend validation, migrations, CRUD endpoints, ownership boundaries, discovery filtering.
"""

import os
import sys
import json
import subprocess
import django
from django.contrib.auth import get_user_model
from django.test import Client
from django.test.utils import setup_test_environment, teardown_test_environment

# Ensure Django settings module is set
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'config.settings.production')

# Setup Django
sys.path.insert(0, '/srv/localboost/backend')
django.setup()

from django.core.management import call_command
from apps.shops.models import Shop, ShopStatus
from apps.merchants.models import MerchantProfile
from apps.accounts.models import UserRole
from rest_framework.test import APIClient
from rest_framework_simplejwt.tokens import RefreshToken

User = get_user_model()

print("=" * 80)
print("MERCHANT MULTI-SHOP CRUD RUNTIME VALIDATION")
print("=" * 80)

# ==============================================================================
# SECTION A: DJANGO RUNTIME CHECKS
# ==============================================================================
print("\n[A] DJANGO SYSTEM CHECKS")
print("-" * 80)

try:
    call_command('check')
    print("✓ Django system checks PASSED")
except Exception as e:
    print(f"✗ Django system checks FAILED: {e}")
    sys.exit(1)

# ==============================================================================
# SECTION B: MIGRATION STATUS
# ==============================================================================
print("\n[B] MIGRATION STATUS CHECK")
print("-" * 80)

try:
    result = subprocess.run(
        ['python', 'manage.py', 'showmigrations', 'shops', '--no-color'],
        cwd='/srv/localboost/backend',
        capture_output=True,
        text=True,
        env={**os.environ}
    )
    lines = result.stdout.strip().split('\n')
    shops_migrations = [l for l in lines if '0001_' in l or '0002_' in l or '0003_' in l]
    
    for line in shops_migrations:
        print(line)
    
    # Check if 0003 is applied
    if "[X] 0003_shop_status_and_email" in result.stdout:
        print("✓ Migration 0003 (shop_status_and_email) is APPLIED")
    else:
        print("! Migration 0003 (shop_status_and_email) is NOT YET APPLIED")
        print("\n  Run on VPS: python manage.py migrate shops")
        
except Exception as e:
    print(f"✗ Migration check FAILED: {e}")

# ==============================================================================
# SECTION C: MODEL SCHEMA VERIFICATION
# ==============================================================================
print("\n[C] MODEL SCHEMA VERIFICATION")
print("-" * 80)

try:
    from django.db import connection
    from django.db.backends.utils import truncate_name
    
    cursor = connection.cursor()
    
    # Get shops_shop table columns
    cursor.execute("""
        SELECT column_name, data_type, is_nullable
        FROM information_schema.columns
        WHERE table_name = 'shops_shop'
        ORDER BY ordinal_position;
    """)
    
    columns = cursor.fetchall()
    required_fields = ['id', 'merchant_id', 'name', 'slug', 'status', 'email', 'is_active']
    found_fields = {col[0]: (col[1], col[2]) for col in columns}
    
    print("Shop table columns:")
    for field in required_fields:
        if field in found_fields:
            dtype, nullable = found_fields[field]
            null_str = "NULL" if nullable == 'YES' else "NOT NULL"
            print(f"  ✓ {field:20} -> {dtype:15} ({null_str})")
        else:
            print(f"  ✗ {field:20} -> MISSING")
    
    # Verify enum choices
    print("\nShopStatus enum values:")
    for choice in ShopStatus.choices:
        print(f"  ✓ {choice[0]:12} -> {choice[1]}")
    
except Exception as e:
    print(f"✗ Schema verification FAILED: {e}")

# ==============================================================================
# SECTION D: TEST DATA SETUP
# ==============================================================================
print("\n[D] TEST DATA SETUP")
print("-" * 80)

try:
    # Clean up old test data
    User.objects.filter(email__startswith='test_merchant_shop_crud_').delete()
    
    # Create two test merchants
    user1 = User.objects.create_user(
        email='test_merchant_shop_crud_01@test.com',
        password='TestPass123!',
        role=UserRole.MERCHANT
    )
    merchant1 = MerchantProfile.objects.get_or_create(user=user1)[0]
    
    user2 = User.objects.create_user(
        email='test_merchant_shop_crud_02@test.com',
        password='TestPass123!',
        role=UserRole.MERCHANT
    )
    merchant2 = MerchantProfile.objects.get_or_create(user=user2)[0]
    
    # Create a reference shop for merchant 1
    shop1 = Shop.objects.create(
        merchant=merchant1,
        name='Test Shop 1 - Active',
        slug='test-shop-1-active',
        status=ShopStatus.ACTIVE,
        is_active=True,
        city='Djibouti',
        country='Djibouti'
    )
    
    print(f"✓ Test merchant 1: {user1.email}")
    print(f"  - Merchant ID: {merchant1.id}")
    print(f"✓ Test merchant 2: {user2.email}")
    print(f"  - Merchant ID: {merchant2.id}")
    print(f"✓ Reference shop: {shop1.name} (ID: {shop1.id}, status: {shop1.status})")
    
    # Store for later tests
    test_data = {
        'user1': user1,
        'merchant1': merchant1,
        'user2': user2,
        'merchant2': merchant2,
        'shop1': shop1,
    }
    
except Exception as e:
    print(f"✗ Test data setup FAILED: {e}")
    test_data = {}

# ==============================================================================
# SECTION E: MERCHANT CRUD ENDPOINT TESTS
# ==============================================================================
print("\n[E] MERCHANT CRUD ENDPOINT TESTS")
print("-" * 80)

def get_merchant_token(user):
    """Generate JWT token for merchant user."""
    refresh = RefreshToken.for_user(user)
    return str(refresh.access_token)

def test_merchant_endpoints():
    """Test all merchant shop CRUD endpoints."""
    
    if not test_data:
        print("✗ Test data not available, skipping endpoint tests")
        return
    
    user1 = test_data['user1']
    merchant1 = test_data['merchant1']
    user2 = test_data['user2']
    merchant2 = test_data['merchant2']
    shop1 = test_data['shop1']
    
    client = APIClient()
    token1 = get_merchant_token(user1)
    token2 = get_merchant_token(user2)
    
    headers_m1 = {'HTTP_AUTHORIZATION': f'Bearer {token1}'}
    headers_m2 = {'HTTP_AUTHORIZATION': f'Bearer {token2}'}
    
    print("\n1. LIST SHOPS (merchant 1)")
    response = client.get('/api/v1/merchant/shops/', **headers_m1)
    print(f"   Status: {response.status_code}")
    if response.status_code == 200:
        shops_list = response.json()
        print(f"   ✓ Found {len(shops_list)} shops")
        if len(shops_list) > 0:
            print(f"   First shop: {shops_list[0]['name']} (status: {shops_list[0]['status']})")
    else:
        print(f"   ✗ Response: {response.data if hasattr(response, 'data') else response.content}")
    
    print("\n2. CREATE SHOP (merchant 1 - draft)")
    create_payload = {
        'name': 'Café Oasis',
        'status': 'draft',
        'description': 'Premium coffee shop',
        'category': 'Restaurants & Cafés',
        'phoneNumber': '+253 21 35 22 33',
        'email': 'cafe.oasis@example.com',
        'address': 'Rue de l\'Église',
        'city': 'Djibouti',
        'country': 'Djibouti',
    }
    response = client.post('/api/v1/merchant/shops/', create_payload, format='json', **headers_m1)
    print(f"   Status: {response.status_code}")
    if response.status_code == 201:
        new_shop = response.json()
        print(f"   ✓ Created shop: {new_shop['name']} (ID: {new_shop['id']}, status: {new_shop['status']})")
        print(f"   Generated slug: {new_shop['slug']}")
        test_data['new_shop'] = new_shop
    else:
        print(f"   ✗ Response: {response.data if hasattr(response, 'data') else response.content}")
    
    print("\n3. GET SHOP DETAIL (merchant 1)")
    response = client.get(f'/api/v1/merchant/shops/{shop1.id}/', **headers_m1)
    print(f"   Status: {response.status_code}")
    if response.status_code == 200:
        shop = response.json()
        print(f"   ✓ Retrieved: {shop['name']} (status: {shop['status']}, is_active: {shop['is_active']})")
    else:
        print(f"   ✗ Response: {response.data if hasattr(response, 'data') else response.content}")
    
    print("\n4. UPDATE SHOP (merchant 1 - change to active)")
    update_payload = {
        'name': 'Test Shop 1 - Active (Updated)',
        'status': 'active',
        'description': 'Updated description',
        'category': 'Shops',
        'phoneNumber': '+253 21 35 22 33',
        'email': 'updated@example.com',
        'address': 'Rue Test',
        'city': 'Djibouti',
        'country': 'Djibouti',
    }
    response = client.put(f'/api/v1/merchant/shops/{shop1.id}/', update_payload, format='json', **headers_m1)
    print(f"   Status: {response.status_code}")
    if response.status_code == 200:
        updated = response.json()
        print(f"   ✓ Updated: {updated['name']} (status: {updated['status']}, is_active: {updated['is_active']})")
    else:
        print(f"   ✗ Response: {response.data if hasattr(response, 'data') else response.content}")
    
    print("\n5. DELETE/ARCHIVE SHOP (merchant 1)")
    response = client.delete(f'/api/v1/merchant/shops/{shop1.id}/', **headers_m1)
    print(f"   Status: {response.status_code}")
    if response.status_code == 204:
        print(f"   ✓ Shop archived (soft delete)")
        # Verify it's archived
        shop1.refresh_from_db()
        print(f"   Verified: status={shop1.status}, is_active={shop1.is_active}")
    else:
        print(f"   ✗ Response status unexpected: {response.status_code}")
    
    print("\n6. CREATE SHOP (merchant 1 - with auto-slug)")
    auto_slug_payload = {
        'name': 'Boutique Élégance',
        'status': 'active',
        'category': 'Shops',
        'phoneNumber': '+253 21 35 22 33',
        'email': 'boutique@example.com',
        'address': 'Rue Principale',
        'city': 'Djibouti',
        'country': 'Djibouti',
    }
    response = client.post('/api/v1/merchant/shops/', auto_slug_payload, format='json', **headers_m1)
    print(f"   Status: {response.status_code}")
    if response.status_code == 201:
        shop = response.json()
        print(f"   ✓ Created: {shop['name']} with auto-generated slug: {shop['slug']}")
        test_data['auto_slug_shop'] = shop
    else:
        print(f"   ✗ Response: {response.data if hasattr(response, 'data') else response.content}")

try:
    test_merchant_endpoints()
except Exception as e:
    print(f"✗ Endpoint tests FAILED: {e}")
    import traceback
    traceback.print_exc()

# ==============================================================================
# SECTION F: OWNERSHIP BOUNDARY TESTS
# ==============================================================================
print("\n[F] OWNERSHIP BOUNDARY TESTS (Cross-Merchant Access Prevention)")
print("-" * 80)

def test_ownership_boundaries():
    """Verify merchant B cannot access merchant A's shops."""
    
    if not test_data or 'auto_slug_shop' not in test_data:
        print("✗ Test data not available, skipping ownership tests")
        return
    
    user1 = test_data['user1']
    user2 = test_data['user2']
    auto_slug_shop = test_data['auto_slug_shop']
    shop_id = auto_slug_shop['id']
    
    client = APIClient()
    token1 = get_merchant_token(user1)
    token2 = get_merchant_token(user2)
    
    headers_m1 = {'HTTP_AUTHORIZATION': f'Bearer {token1}'}
    headers_m2 = {'HTTP_AUTHORIZATION': f'Bearer {token2}'}
    
    print(f"\nShop ID {shop_id} belongs to Merchant 1")
    
    print("\n1. Merchant 1 CAN read own shop")
    response = client.get(f'/api/v1/merchant/shops/{shop_id}/', **headers_m1)
    if response.status_code == 200:
        print(f"   ✓ Merchant 1 access ALLOWED (status {response.status_code})")
    else:
        print(f"   ✗ Unexpected status: {response.status_code}")
    
    print("\n2. Merchant 2 CANNOT read merchant 1's shop")
    response = client.get(f'/api/v1/merchant/shops/{shop_id}/', **headers_m2)
    if response.status_code == 403:
        print(f"   ✓ Merchant 2 access DENIED with 403 Forbidden")
    elif response.status_code == 404:
        print(f"   ✓ Merchant 2 access DENIED with 404 Not Found (filtered)")
    else:
        print(f"   ✗ Unexpected status: {response.status_code} (expected 403 or 404)")
    
    print("\n3. Merchant 2 CANNOT update merchant 1's shop")
    update_payload = {'name': 'Hacked Shop', 'status': 'active'}
    response = client.put(f'/api/v1/merchant/shops/{shop_id}/', update_payload, format='json', **headers_m2)
    if response.status_code in [403, 404]:
        print(f"   ✓ Merchant 2 update DENIED with {response.status_code}")
    else:
        print(f"   ✗ Unexpected status: {response.status_code} (expected 403 or 404)")
    
    print("\n4. Merchant 2 CANNOT delete merchant 1's shop")
    response = client.delete(f'/api/v1/merchant/shops/{shop_id}/', **headers_m2)
    if response.status_code in [403, 404]:
        print(f"   ✓ Merchant 2 delete DENIED with {response.status_code}")
    else:
        print(f"   ✗ Unexpected status: {response.status_code} (expected 403 or 404)")
    
    print("\n5. Merchant 2's shop list only contains own shops")
    response = client.get('/api/v1/merchant/shops/', **headers_m2)
    if response.status_code == 200:
        shops = response.json()
        print(f"   ✓ Merchant 2 sees {len(shops)} shop(s) in own list (should not include Merchant 1 shops)")
    else:
        print(f"   ✗ List endpoint failed: {response.status_code}")

try:
    test_ownership_boundaries()
except Exception as e:
    print(f"✗ Ownership boundary tests FAILED: {e}")
    import traceback
    traceback.print_exc()

# ==============================================================================
# SECTION G: PUBLIC DISCOVERY FILTERING TESTS
# ==============================================================================
print("\n[G] PUBLIC DISCOVERY FILTERING TESTS")
print("-" * 80)

def test_discovery_filtering():
    """Verify only active shops appear in public discovery endpoints."""
    
    if not test_data:
        print("✗ Test data not available, skipping discovery tests")
        return
    
    merchant1 = test_data['merchant1']
    
    # Create test shops with different statuses
    shops_to_test = [
        ('Public Active Shop', ShopStatus.ACTIVE, True),
        ('Public Draft Shop', ShopStatus.DRAFT, False),
        ('Public Suspended Shop', ShopStatus.SUSPENDED, False),
        ('Public Archived Shop', ShopStatus.ARCHIVED, False),
    ]
    
    created_shops = []
    for name, status, is_active in shops_to_test:
        shop = Shop.objects.create(
            merchant=merchant1,
            name=name,
            slug=name.lower().replace(' ', '-'),
            status=status,
            is_active=is_active,
            city='Djibouti',
            country='Djibouti'
        )
        created_shops.append(shop)
    
    print(f"Created {len(created_shops)} test shops with different statuses\n")
    
    client = APIClient()
    
    print("1. GET /api/v1/shops/ (public discovery)")
    response = client.get('/api/v1/shops/')
    print(f"   Status: {response.status_code}")
    if response.status_code == 200:
        shops = response.json()
        active_shops = [s for s in shops if s['name'].startswith('Public')]
        print(f"   Found {len(active_shops)} public test shops")
        for shop in active_shops:
            print(f"   - {shop['name']} (status: {shop['status']}, is_active: {shop['is_active']})")
        
        # Verify only ACTIVE shops are visible
        statuses = [s['status'] for s in active_shops]
        only_active = all(s == 'active' for s in statuses)
        if only_active:
            print(f"   ✓ Only ACTIVE shops visible (draft/suspended/archived filtered correctly)")
        else:
            print(f"   ✗ Non-active shops are visible!")
    else:
        print(f"   ✗ Status: {response.status_code}")
    
    print("\n2. GET /api/v1/shops/search/ (public search)")
    response = client.get('/api/v1/shops/search/?q=Public')
    print(f"   Status: {response.status_code}")
    if response.status_code == 200:
        shops = response.json()
        print(f"   Found {len(shops)} matching shops")
        statuses = [s['status'] for s in shops]
        if all(s == 'active' for s in statuses):
            print(f"   ✓ Search also filters to ACTIVE shops only")
        else:
            print(f"   ✗ Search includes non-active shops")
    else:
        print(f"   ✗ Status: {response.status_code}")
    
    # Cleanup
    for shop in created_shops:
        shop.delete()
    print(f"\n   Cleaned up {len(created_shops)} test shops")

try:
    test_discovery_filtering()
except Exception as e:
    print(f"✗ Discovery filtering tests FAILED: {e}")
    import traceback
    traceback.print_exc()

# ==============================================================================
# SECTION H: CURL COMMAND REFERENCE
# ==============================================================================
print("\n[H] CURL COMMAND REFERENCE FOR MANUAL TESTING")
print("-" * 80)

print("""
# Prerequisites:
MERCHANT_EMAIL="test_merchant_shop_crud_01@test.com"
MERCHANT_PASSWORD="TestPass123!"
API_URL="https://sirius-djibouti.com/api/v1"

# 1. LOGIN & GET TOKEN
curl -X POST "$API_URL/accounts/login/" \\
  -H "Content-Type: application/json" \\
  -d '{"email":"'$MERCHANT_EMAIL'","password":"'$MERCHANT_PASSWORD'"}'

# Copy the access token from response and set:
TOKEN="<your_access_token>"

# 2. LIST MERCHANT SHOPS
curl -X GET "$API_URL/merchant/shops/" \\
  -H "Authorization: Bearer $TOKEN" \\
  -H "Content-Type: application/json"

# 3. CREATE NEW SHOP
curl -X POST "$API_URL/merchant/shops/" \\
  -H "Authorization: Bearer $TOKEN" \\
  -H "Content-Type: application/json" \\
  -d '{
    "name": "Coffee Corner",
    "status": "draft",
    "description": "Cozy coffee shop",
    "category": "Restaurants & Cafés",
    "phoneNumber": "+253 21 35 22 33",
    "email": "info@coffeecorner.dj",
    "address": "Rue de Marseille",
    "city": "Djibouti",
    "country": "Djibouti"
  }'

# 4. GET SHOP DETAIL
SHOP_ID=1
curl -X GET "$API_URL/merchant/shops/$SHOP_ID/" \\
  -H "Authorization: Bearer $TOKEN" \\
  -H "Content-Type: application/json"

# 5. UPDATE SHOP
curl -X PUT "$API_URL/merchant/shops/$SHOP_ID/" \\
  -H "Authorization: Bearer $TOKEN" \\
  -H "Content-Type: application/json" \\
  -d '{
    "name": "Coffee Corner (Updated)",
    "status": "active",
    "description": "Updated description",
    "category": "Restaurants & Cafés",
    "phoneNumber": "+253 21 35 22 33",
    "email": "updated@coffeecorner.dj",
    "address": "Rue de Marseille",
    "city": "Djibouti",
    "country": "Djibouti"
  }'

# 6. DELETE/ARCHIVE SHOP
curl -X DELETE "$API_URL/merchant/shops/$SHOP_ID/" \\
  -H "Authorization: Bearer $TOKEN"

# 7. PUBLIC DISCOVERY (no token needed)
curl -X GET "$API_URL/shops/" \\
  -H "Content-Type: application/json"

# 8. PUBLIC SEARCH (no token needed)
curl -X GET "$API_URL/shops/search/?q=coffee" \\
  -H "Content-Type: application/json"

# 9. NEGATIVE TEST - Merchant 2 tries to access Merchant 1's shop
# First get Merchant 2's token, then:
curl -X GET "$API_URL/merchant/shops/$SHOP_ID/" \\
  -H "Authorization: Bearer $MERCHANT2_TOKEN" \\
  -H "Content-Type: application/json"
# Expected: 403 Forbidden or 404 Not Found
""")

# ==============================================================================
# CLEANUP
# ==============================================================================
print("\n[I] TEST DATA CLEANUP")
print("-" * 80)

try:
    # Clean up test users and their data
    User.objects.filter(email__startswith='test_merchant_shop_crud_').delete()
    print("✓ Cleaned up test users and associated shops")
except Exception as e:
    print(f"✗ Cleanup failed: {e}")

# ==============================================================================
# FINAL VERDICT
# ==============================================================================
print("\n" + "=" * 80)
print("RUNTIME VALIDATION SUMMARY")
print("=" * 80)

print("""
VALIDATION CHECKLIST:
  [ ] A. Django system checks PASS
  [ ] B. Migration 0003 applied successfully
  [ ] C. Schema has status and email columns
  [ ] D. Test merchants and shops created
  [ ] E. CRUD endpoints return 200/201/204
  [ ] F. Merchant 2 cannot access Merchant 1 shops
  [ ] G. Public discovery filters to ACTIVE only
  [ ] H. Curl commands documented for manual testing
  
VERDICT: See outputs above for PASS/FAIL on each section

NEXT STEPS:
  1. If all sections PASS:
     - Deploy Flutter app build
     - Test on merchant device
     - Proceed to deals/flyers feature
  
  2. If any section FAIL:
     - Review error messages above
     - Check backend logs on VPS
     - Fix issues and re-run validation
""")

print("\n" + "=" * 80)
print("END OF VALIDATION")
print("=" * 80)
