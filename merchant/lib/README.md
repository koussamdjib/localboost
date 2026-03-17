# Merchant Module

This directory contains **merchant-facing app features** - everything that business owners and staff use to manage their offers, validate customer stamps, and track analytics.

## Structure

```
merchant/
├── models/              # Merchant-specific data models
│   ├── merchant.dart         # (future) Merchant account details
│   ├── merchant_offer.dart   # (future) Offer management
│   ├── stamp_request.dart    # (future) Stamp validation requests
│   └── redemption.dart       # (future) Reward redemption records
├── providers/           # Merchant-side state management
│   └── (future providers)
├── services/            # Merchant-side business logic & API calls
│   ├── merchant_auth_service.dart   # (future) Merchant authentication
│   ├── stamp_service.dart           # (future) Grant stamps to customers
│   └── redemption_service.dart      # (future) Process redemptions
├── screens/             # Full-page merchant screens
│   ├── scanner/         # QR code scanner for stamp validation
│   │   └── merchant_scanner_screen.dart  ← EXISTING (387 lines, needs refactoring)
│   ├── dashboard/       # (future) Merchant dashboard/home
│   ├── offers/          # (future) Create/manage offers
│   └── analytics/       # (future) View business analytics
└── widgets/             # Merchant-specific UI components
    └── (future widgets)
```

## What Goes Here

### ✅ **INCLUDE:**
- **QR Code Scanning**: Validate customer QR codes to grant stamps
- **Offer Management**: Create, edit, delete loyalty offers (future)
- **Dashboard**: View active offers, recent transactions (future)
- **Analytics**: Track customer engagement, redemptions (future)
- **Merchant-specific models**: Merchant, Offer, StampRequest, Redemption

### ❌ **EXCLUDE:**
- Customer features (deal browsing, enrollments) → `client/`
- Shared auth/profile → `shared/`
- Pure utilities → `core/`

## Guidelines

1. **Merchant-First Design**: Optimize UX for business owners and staff
2. **Security First**: Validate all stamp/redemption requests server-side
3. **Fast Workflows**: Minimize taps for frequently-used features (e.g., scanning)
4. **Clear Feedback**: Provide immediate confirmation of stamp grants/redemptions

## Current Features

### 📱 **QR Code Scanner** (EXISTING)
- **File**: `screens/scanner/merchant_scanner_screen.dart`
- **Status**: ⚠️ Needs refactoring (387 lines → target ≤150 lines)
- **Dependencies**: 
  - Uses `mobile_scanner` package
  - Imports enrollment model/provider from shared infrastructure
  - Uses `AppColors` from core/constants
- **Functionality**:
  - Scan customer QR codes
  - Validate enrollment
  - Grant stamps
  - Show confirmation

## Future Features (Planned)

### 🏪 **Merchant Dashboard**
- View active loyalty programs
- See recent customer enrollments
- Quick stats (total customers, stamps granted today)
- Recent transactions list

### 🎯 **Offer Management**
- Create new loyalty offers
- Set stamp requirements and rewards
- Configure terms & conditions
- Schedule offer start/end dates
- Pause/unpause offers

### 📊 **Analytics**
- Customer engagement metrics
- Stamp grant frequency
- Redemption rates
- Customer retention stats
- Export data for reporting

### 🔔 **Notifications**
- New customer enrollments
- Completed reward alerts
- Low stamp inventory warnings (future feature)

## Migration Notes

### Current State
- **1 existing file**: `merchant_scanner_screen.dart` (currently in `lib/screens/`)
- **Dependencies**: Uses shared enrollment infrastructure (models, providers)
- **Next Step**: Move to `merchant/screens/scanner/` during Phase 3 migration

### Refactoring Needed
- ⚠️ `merchant_scanner_screen.dart`: 387 lines → extract into widgets
- Extract: Scanner view widget, result dialog, error handling, camera controls

## File Naming Conventions

- **Screens**: `merchant_*_screen.dart` or `*_page.dart`
- **Widgets**: `*_widget.dart` or descriptive name
- **Models**: Singular noun with `merchant_` prefix if ambiguous
- **Services**: `*_service.dart`
- **Providers**: `merchant_*_provider.dart`

## Access Control

**Important**: All merchant features should:
1. Verify merchant authentication
2. Check merchant permissions server-side
3. Never expose customer personal data unnecessarily
4. Log all stamp grants and redemptions for audit trail
