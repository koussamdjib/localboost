# Backend Integration Status

Last Updated: March 10, 2026
Status: LIVE - Auth and Shop Discovery verified on VPS

---

## Current Production State

- Auth API is live at https://sirius-djibouti.com/api/v1/auth
- Shop discovery API is live at https://sirius-djibouti.com/api/v1/shops
- VPS services are active: localboost-backend and nginx
- VPS remote access uses SSH port 2222
- CORS allows:
  - https://client.localboost.com
  - https://merchant.localboost.com
  - https://sirius-djibouti.com
- Seeded discovery shop is present for smoke checks:
  - shop_id=1
  - slug=ocean-cafe-seed
  - has_active_deals=true
  - has_loyalty_programs=true

---

## Latest Verification Snapshot (March 10, 2026)

### Local Validation

- Backend targeted tests:
  - Command: C:/Users/loli/localboost/.venv/Scripts/python.exe manage.py test apps.accounts apps.shops
  - Result: EXIT_CODE=0
- Flutter package tests:
  - shared: pass
  - client: pass
  - merchant: pass
  - Combined result: EXIT_SHARED=0 EXIT_CLIENT=0 EXIT_MERCHANT=0

### Live VPS Validation

- Auth and CORS verifier:
  - Command: bash vps_live_verify_only.sh
  - Result: VERDICT=PASS
  - Key statuses:
    - REGISTER_STATUS=201
    - LOGIN_STATUS=200
    - ME_STATUS=200
    - PUT_STATUS=200
    - PASS_CHANGE_STATUS=200
    - LOGIN_NEW_STATUS=200
    - REFRESH_STATUS=200
    - DELETE_STATUS=204
    - CORS_CLIENT=https://client.localboost.com
    - CORS_MERCHANT=https://merchant.localboost.com
    - CORS_DOMAIN=https://sirius-djibouti.com

- Shop discovery verifier:
  - Command: bash vps_shops_live_verify_only.sh
  - Result: VERDICT=PASS
  - Key statuses:
    - LIST_STATUS=200
    - SEARCH_STATUS=200
    - DETAIL_STATUS=200
    - SEARCH_HAS_EXPECTED=true
    - DETAIL_FLAGS=slug=ocean-cafe-seed deals=true loyalty=true

---

## Implemented API Surface

### Auth Endpoints

- POST /api/v1/auth/register/
- POST /api/v1/auth/token/
- POST /api/v1/auth/token/refresh/
- GET /api/v1/auth/me/
- PUT /api/v1/auth/me/
- POST /api/v1/auth/me/password/
- DELETE /api/v1/auth/me/

### Shop Discovery Endpoints

- GET /api/v1/shops/
- GET /api/v1/shops/search/
- GET /api/v1/shops/{id}/

---

## Delivered Components

### Flutter

- Shared and client async shop discovery wiring through ShopEndpoints
- Auth boundary wrappers for client and merchant shells
- API client infrastructure with token injection and mock/API feature flag support

### Backend

- apps.accounts auth views/serializers/routes aligned with Flutter auth contract
- apps.shops discovery routes deployed and serving production traffic
- VPS route/service drift fixed and re-verified

---

## Operational Scripts

- vps_live_verify_only.sh
  - One-command live auth lifecycle and CORS verification
  - Defaults: SHOW_BODIES=0, REDACT_TOKENS=1, CURL_MAX_TIME=45, CURL_RETRY=1
  - Supports BASE override for alternate endpoint targets
- vps_auth_fix_and_verify.sh
  - Restore/fix VPS auth files, run checks/restarts, then full live auth verification
  - Supports SHOW_BODIES, REDACT_TOKENS, CURL_MAX_TIME, CURL_RETRY, and BASE overrides
- vps_shops_live_verify_only.sh
  - One-command live shops list/search/detail verification
  - Defaults: SHOW_BODIES=0, CURL_MAX_TIME=45, CURL_RETRY=1, ALLOW_EMPTY_RESULTS=0
  - Emits parse-health fields: LIST_JSON_OK, SEARCH_JSON_OK, DETAIL_JSON_OK
- vps_shops_cleanup_seed.sh
  - Run seeded-shop cleanup on VPS and re-run shops verification
  - Runs verifier in allow-empty mode after cleanup
  - Optional strict verify: VERIFY_STRICT=1
- backend/deploy/scripts/seed_shop_discovery_data.py
  - Idempotent production seed for discovery smoke tests
- backend/deploy/scripts/cleanup_seed_shop_discovery_data.py
  - Idempotent cleanup for seeded production discovery data

---

## Quick Runbook

From workspace root:

```bash
# Live auth and CORS checks
bash vps_live_verify_only.sh

# Live shops checks
bash vps_shops_live_verify_only.sh

# Optional deep debug output (auth bodies with token redaction)
SHOW_BODIES=1 bash vps_live_verify_only.sh

# Optional deep debug output (shops response bodies)
SHOW_BODIES=1 bash vps_shops_live_verify_only.sh

# Optional custom timeout/retry settings
CURL_MAX_TIME=60 CURL_RETRY=2 bash vps_shops_live_verify_only.sh

# Optional base override for alternate environments
BASE=https://sirius-djibouti.com/api/v1/auth bash vps_live_verify_only.sh
BASE=https://sirius-djibouti.com/api/v1/shops bash vps_shops_live_verify_only.sh

# Optional timeout/retry tuning for full auth restore-and-verify flow
CURL_MAX_TIME=60 CURL_RETRY=2 bash vps_auth_fix_and_verify.sh

# Optional allow-empty mode (for post-cleanup or empty datasets)
ALLOW_EMPTY_RESULTS=1 EXPECTED_SLUG='' bash vps_shops_live_verify_only.sh

# Optional explicit auth token visibility (controlled troubleshooting only)
SHOW_BODIES=1 REDACT_TOKENS=0 bash vps_live_verify_only.sh

# Optional seeded data cleanup, then shops verification
bash vps_shops_cleanup_seed.sh

# Optional strict cleanup verification (non-zero exit if verify fails)
VERIFY_STRICT=1 bash vps_shops_cleanup_seed.sh
```

---

## Notes

- Verifier scripts suppress response body output by default.
- Auth verifier redacts access and refresh tokens by default when bodies are enabled.
- Full token output requires explicit REDACT_TOKENS=0 and should be used only in controlled operational contexts.
- For PowerShell shells, set env overrides through bash: `bash -lc 'SHOW_BODIES=1 bash vps_live_verify_only.sh'`.
- If production should not keep seeded discovery data, run vps_shops_cleanup_seed.sh.
