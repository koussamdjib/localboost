# Merchant Mobile QA Strict Pass-Fail Checklist

Purpose: hard gate before starting Merchant Deals CRUD rollout.

Run metadata:
- Date:
- Tester:
- Device/OS:
- App build:
- Backend base URL:

## A. QA checklist

| ID | Scenario | Steps | Pass | Fail | Evidence |
|---|---|---|---|---|---|
| QA-01 | login | Sign in with valid merchant credentials | [ ] | [ ] | |
| QA-02 | create shop | Create a new shop with required fields and submit | [ ] | [ ] | |
| QA-03 | list shops | Refresh list and confirm created shop appears | [ ] | [ ] | |
| QA-04 | edit shop | Update name/status/address and save | [ ] | [ ] | |
| QA-05 | archive shop | Archive an existing shop and confirm | [ ] | [ ] | |
| QA-06 | empty state | Verify no-shop screen for account with zero shops | [ ] | [ ] | |
| QA-07 | multiple shops | Verify switch/selection behavior with 2+ shops | [ ] | [ ] | |
| QA-08 | logout | Logout and confirm session clear and auth screen | [ ] | [ ] | |
| QA-09 | wrong-account access behavior | Attempt merchant app login with customer account | [ ] | [ ] | |
| QA-10 | public visibility active vs archived | Validate public discovery for active and archived shops | [ ] | [ ] | |

## B. Expected results

- QA-01: Merchant login returns authenticated merchant shell without errors.
- QA-02: Shop create returns success and new shop is present in merchant list.
- QA-03: Only own shops are listed; no cross-merchant records are visible.
- QA-04: Edited values persist after refresh and app re-open.
- QA-05: Archive behaves as soft delete and removes shop from active/public discovery.
- QA-06: Empty state is shown with create CTA; app remains stable.
- QA-07: Selected shop context updates correctly across merchant screens.
- QA-08: Logout clears token/session and blocks protected merchant screens.
- QA-09: Customer account cannot access merchant workspace.
- QA-10: Public discovery shows active shops only and hides archived shops.

## C. Failure conditions

Critical:
- Non-merchant user can access merchant workspace or merchant endpoints.
- Merchant can read/write another merchant's shop data.
- Archived shop remains publicly discoverable.
- Session does not clear on logout.

Major:
- UI indicates success but backend data is not persisted.
- Shop context switch points campaigns/actions to wrong shop.
- Empty state missing or app crashes in no-shop scenario.

Minor:
- Cosmetic issues that do not affect CRUD/auth/visibility behavior.

## D. Final sign-off criteria

- 10/10 checklist items marked Pass.
- Zero open Critical and zero open Major defects.
- Wrong-account and public-visibility checks pass in two consecutive runs.
- Evidence captured for every case (screenshot + request/response).
- Sign-off recorded:
  - QA lead:
  - Product owner:
  - Engineering owner:
