# Merchant Deals CRUD Next Phase Plan

Scope: deals attached to merchant-owned shops.

Target endpoints:
- POST   /api/v1/merchant/shops/{shop_id}/deals/
- GET    /api/v1/merchant/shops/{shop_id}/deals/
- GET    /api/v1/merchant/deals/{id}/
- PUT    /api/v1/merchant/deals/{id}/
- DELETE /api/v1/merchant/deals/{id}/

Rules:
- only authenticated merchants
- only own-shop deals
- preserve existing auth and shop behavior
- do not break public shop discovery

## A. models

- Keep deal ownership through Deal.shop foreign key.
- Keep deal lifecycle statuses draft/published/archived.
- Keep delete as archive transition (soft delete).

## B. serializers

- Use merchant serializer as API contract for CRUD payloads.
- Keep shop_id read-only and route-driven.
- Keep validation for deal_type, status, schedule (ends_at > starts_at), and max_redemptions >= 1.

## C. permissions

- Gate all merchant deal endpoints with IsAuthenticated + merchant role.
- Keep ownership checks for shop and deal object access.

## D. views

- Keep nested list/create under shops/{shop_id}/deals.
- Keep detail GET/PUT/DELETE under deals/{id}.
- Keep delete behavior as archive status update, not hard delete.

## E. urls

- Merchant deal routes stay under merchant namespace.
- Keep existing public shop routes unchanged.

## F. curl tests

Set env vars first:
- BASE_URL
- MERCHANT_TOKEN
- CUSTOMER_TOKEN
- SHOP_ID
- OTHER_SHOP_ID
- DEAL_ID

Core checks:
1) create own-shop deal -> 201
2) list own-shop deals -> 200
3) get own deal detail -> 200
4) update own deal via PUT -> 200
5) delete own deal (archive) -> 204
6) create against other merchant shop -> 404
7) customer token access to merchant deals -> 403
8) public shops endpoint remains stable for active vs archived shops -> 200 with expected filtering

## G. merchant Flutter screens/files to modify

Backend-facing merchant deal flow:
- merchant/lib/services/merchant_deals_service.dart
- merchant/lib/providers/deal_provider.dart
- merchant/lib/screens/deals/form/deal_form_screen_actions.dart
- merchant/lib/screens/deals/list/deals_list_screen_data.dart
- merchant/lib/screens/deals/list/deals_list_screen_actions.dart

Regression safety tests:
- backend/apps/deals/tests.py
- backend/apps/shops/tests.py

## H. recommended validation order

1. Backend unit/API tests for merchant deals ownership + PUT + archive behavior.
2. Backend public discovery regression tests.
3. Curl contract checks for all five endpoint operations.
4. Merchant Flutter data-layer verification (provider/service mapping).
5. Merchant app manual CRUD pass with one shop.
6. Merchant app manual CRUD pass with multiple shops.
7. Final public discovery verification after archive operations.
