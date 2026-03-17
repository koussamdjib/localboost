# LocalBoost Architecture Migration Plan

## A. GOAL
Introduce a clean folder structure that clearly separates:
- **client** - Customer-facing app features
- **merchant** - Merchant/business-facing features  
- **shared** - Code used by both client and merchant
- **core** - Global utilities, constants, themes, helpers

All new merchant code MUST go under `lib/merchant/`.
All new client code SHOULD go under `lib/client/`.
No source file may exceed 150 lines.

---

## B. CURRENT STRUCTURE OBSERVATIONS

### Current Folder Structure:
```
lib/
├── constants/
│   └── app_colors.dart
├── data/
│   ├── mock_flyers.dart
│   └── mock_shops.dart
├── models/
│   ├── enrollment.dart
│   ├── flyer.dart
│   ├── notification_preferences.dart
│   ├── search_filter.dart
│   ├── shop.dart
│   ├── stamp_history.dart
│   ├── transaction.dart
│   └── user.dart
├── providers/
│   ├── auth_provider.dart
│   ├── enrollment_provider.dart
│   ├── notification_provider.dart
│   └── search_provider.dart
├── screens/
│   ├── change_password_page.dart
│   ├── deal_details_page.dart (128 lines - ✓ refactored)
│   ├── edit_profile_page.dart (540 lines - ⚠️ needs refactoring)
│   ├── flyers_page.dart (694 lines - ⚠️ needs refactoring)
│   ├── home_page.dart (136 lines - ✓)
│   ├── login_screen.dart (239 lines - ⚠️ needs refactoring)
│   ├── main_screen.dart
│   ├── merchant_scanner_screen.dart (387 lines - ⚠️ needs refactoring)
│   ├── my_cards_page.dart (797 lines - ⚠️ needs refactoring)
│   ├── notification_settings_page.dart (452 lines - ⚠️ needs refactoring)
│   ├── profile_page.dart (1281 lines - ⚠️ CRITICAL)
│   ├── qr_code_screen.dart (167 lines - ⚠️ needs refactoring)
│   ├── register_screen.dart (272 lines - ⚠️ needs refactoring)
│   ├── search_page.dart (473 lines - ⚠️ needs refactoring)
│   └── transaction_history_page.dart (463 lines - ⚠️ needs refactoring)
├── services/
│   ├── auth_service.dart (213 lines - ⚠️ needs refactoring)
│   ├── enrollment_service.dart (219 lines - ⚠️ needs refactoring)
│   ├── notification_service.dart (274 lines - ⚠️ needs refactoring)
│   ├── profile_service.dart (240 lines - ⚠️ needs refactoring)
│   ├── search_service.dart (258 lines - ⚠️ needs refactoring)
│   └── stamp_history_service.dart
├── utils/
│   ├── distance_calculator.dart
│   └── share_helper.dart
├── widgets/
│   ├── deal_card_widget.dart (255 lines - ⚠️ needs refactoring)
│   ├── deal_details/ (16 files - ✓ all under 150 lines)
│   ├── deals_section_widget.dart
│   ├── filter_bottom_sheet.dart (345 lines - ⚠️ needs refactoring)
│   ├── map_view_widget.dart (283 lines - ⚠️ needs refactoring)
│   ├── search_bar_widget.dart
│   └── shop_details_sheet.dart (847 lines - ⚠️ CRITICAL)
└── main.dart

**Total**: 45 Dart files
**Files over 150 lines**: 26 (58%)
**Merchant-specific**: 1 file (merchant_scanner_screen.dart)
**Client-specific**: ~30 files
**Shared**: ~14 files
```

### Key Observations:
1. **No separation** between client and merchant code
2. **merchant_scanner_screen.dart** is the only merchant-specific file currently
3. Most screens are **client-facing** (customer app)
4. Auth, profile, and user models are **shared** between both sides
5. **26 files still exceed 150 lines** (from previous refactoring session)
6. **deal_details/** widgets are well-organized (recently refactored)

---

## C. PROPOSED FOLDER STRUCTURE

```
lib/
├── core/                          # Global utilities & configuration
│   ├── constants/
│   │   ├── app_colors.dart
│   │   ├── app_strings.dart      # NEW - extract hardcoded strings
│   │   └── app_config.dart       # NEW - API endpoints, app settings
│   ├── theme/                     # NEW
│   │   └── app_theme.dart
│   └── utils/
│       ├── distance_calculator.dart
│       ├── share_helper.dart
│       ├── validators.dart        # NEW - form validation helpers
│       └── formatters.dart        # NEW - date/currency formatters
│
├── shared/                        # Code used by BOTH client & merchant
│   ├── models/
│   │   ├── user.dart
│   │   └── transaction.dart       # If merchants see transactions
│   ├── providers/
│   │   └── auth_provider.dart
│   ├── services/
│   │   ├── auth_service.dart
│   │   └── profile_service.dart
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   └── profile/
│   │       ├── edit_profile_page.dart
│   │       ├── change_password_page.dart
│   │       └── profile_page.dart  # If both use same profile
│   └── widgets/
│       └── common/
│           ├── custom_button.dart
│           ├── loading_indicator.dart
│           └── error_dialog.dart
│
├── client/                        # Customer-facing app
│   ├── models/
│   │   ├── enrollment.dart
│   │   ├── flyer.dart
│   │   ├── notification_preferences.dart
│   │   ├── search_filter.dart
│   │   ├── shop.dart
│   │   └── stamp_history.dart
│   ├── providers/
│   │   ├── enrollment_provider.dart
│   │   ├── notification_provider.dart
│   │   └── search_provider.dart
│   ├── services/
│   │   ├── enrollment_service.dart
│   │   ├── notification_service.dart
│   │   ├── search_service.dart
│   │   └── stamp_history_service.dart
│   ├── screens/
│   │   ├── home/
│   │   │   ├── home_page.dart
│   │   │   └── main_screen.dart
│   │   ├── deals/
│   │   │   ├── deal_details_page.dart
│   │   │   ├── search_page.dart
│   │   │   └── flyers_page.dart
│   │   ├── loyalty/
│   │   │   ├── my_cards_page.dart
│   │   │   ├── qr_code_screen.dart
│   │   │   └── transaction_history_page.dart
│   │   └── settings/
│   │       └── notification_settings_page.dart
│   ├── widgets/
│   │   ├── deal_card_widget.dart
│   │   ├── deals_section_widget.dart
│   │   ├── deal_details/          # (already refactored)
│   │   ├── filter_bottom_sheet.dart
│   │   ├── map_view_widget.dart
│   │   ├── search_bar_widget.dart
│   │   └── shop_details_sheet.dart
│   └── data/                       # Mock data for development
│       ├── mock_shops.dart
│       └── mock_flyers.dart
│
├── merchant/                      # Merchant/business-facing app
│   ├── models/
│   │   ├── merchant.dart          # NEW
│   │   ├── merchant_offer.dart    # NEW
│   │   ├── stamp_request.dart     # NEW
│   │   └── redemption.dart        # NEW
│   ├── providers/
│   │   ├── merchant_auth_provider.dart  # NEW
│   │   └── merchant_offers_provider.dart # NEW
│   ├── services/
│   │   ├── merchant_auth_service.dart   # NEW
│   │   ├── stamp_service.dart           # NEW - grant stamps to customers
│   │   └── redemption_service.dart      # NEW - redeem rewards
│   ├── screens/
│   │   ├── scanner/
│   │   │   └── merchant_scanner_screen.dart  # MOVE from lib/screens/
│   │   ├── dashboard/
│   │   │   └── merchant_dashboard.dart      # NEW
│   │   ├── offers/
│   │   │   ├── offers_list_page.dart        # NEW
│   │   │   └── create_offer_page.dart       # NEW
│   │   └── analytics/
│   │       └── analytics_page.dart          # NEW (future)
│   └── widgets/
│       ├── offer_card.dart        # NEW
│       └── scan_result_dialog.dart # NEW
│
└── main.dart                      # Entry point (no changes initially)
```

---

## D. SAFE MIGRATION PLAN (Incremental Steps)

### **Phase 1: Create Folder Structure (IMMEDIATE - SAFE)**
- ✅ Create empty folders: `core/`, `shared/`, `client/`, `merchant/`
- ✅ Create subfolders as outlined above
- ✅ **NO file moves yet** - just folder creation
- ✅ **NO import changes** - existing code still works

### **Phase 2: Move Core Utilities (LOW RISK)**
- Move `constants/` → `core/constants/`
- Move `utils/` → `core/utils/`
- Update imports in all files (batch operation)
- Test compilation

### **Phase 3: Create Merchant Foundation (NEW CODE ONLY)**
- Create `merchant/models/` with NEW merchant models
- Create `merchant/services/` with NEW merchant services
- Create `merchant/providers/` with NEW merchant providers
- Move `merchant_scanner_screen.dart` → `merchant/screens/scanner/`
- Update imports for merchant_scanner_screen.dart only
- Test compilation

### **Phase 4: Separate Shared Code (MEDIUM RISK)**
- Move `auth_provider.dart` → `shared/providers/`
- Move `auth_service.dart` → `shared/services/`
- Move `profile_service.dart` → `shared/services/`
- Move `user.dart` → `shared/models/`
- Move `login_screen.dart` → `shared/screens/auth/`
- Move `register_screen.dart` → `shared/screens/auth/`
- Update imports (batch operation)
- Test authentication flow

### **Phase 5: Organize Client Code (HIGHER RISK - DO CAREFULLY)**
- Move client models → `client/models/`
- Move client providers → `client/providers/`
- Move client services → `client/services/`
- Move client screens → `client/screens/` (organized by feature)
- Move client widgets → `client/widgets/`
- Move mock data → `client/data/`
- Update all imports (large batch operation)
- Test all client flows

### **Phase 6: Refactor Oversized Files (ONGOING)**
- Continue refactoring files exceeding 150 lines
- Apply same pattern as deal_details_page.dart refactoring
- Priority order:
  1. profile_page.dart (1281 lines) - CRITICAL
  2. shop_details_sheet.dart (847 lines) - CRITICAL
  3. my_cards_page.dart (797 lines)
  4. flyers_page.dart (694 lines)
  5. edit_profile_page.dart (540 lines)
  6. (Continue with remaining oversized files)

---

## E. FILES/FOLDERS TO CREATE NOW

### Step 1: Create Core Structure (SAFE - Do Immediately)
```
lib/core/
lib/core/constants/
lib/core/theme/
lib/core/utils/
```

### Step 2: Create Shared Structure (SAFE - Do Immediately)
```
lib/shared/
lib/shared/models/
lib/shared/providers/
lib/shared/services/
lib/shared/screens/
lib/shared/screens/auth/
lib/shared/screens/profile/
lib/shared/widgets/
lib/shared/widgets/common/
```

### Step 3: Create Client Structure (SAFE - Do Immediately)
```
lib/client/
lib/client/models/
lib/client/providers/
lib/client/services/
lib/client/screens/
lib/client/screens/home/
lib/client/screens/deals/
lib/client/screens/loyalty/
lib/client/screens/settings/
lib/client/widgets/
lib/client/widgets/deal_details/
lib/client/data/
```

### Step 4: Create Merchant Structure (SAFE - Do Immediately)
```
lib/merchant/
lib/merchant/models/
lib/merchant/providers/
lib/merchant/services/
lib/merchant/screens/
lib/merchant/screens/scanner/
lib/merchant/screens/dashboard/
lib/merchant/screens/offers/
lib/merchant/screens/analytics/
lib/merchant/widgets/
```

### Step 5: Create Placeholder Files (Documentation Only)
```
lib/core/README.md
lib/shared/README.md
lib/client/README.md
lib/merchant/README.md
```

---

## F. RISKS & NOTES

### ⚠️ **RISKS:**
1. **Import Hell**: Moving files will break ~100+ import statements
2. **Main.dart Routes**: Navigation routes must be updated carefully
3. **Provider Registration**: MultiProvider in main.dart needs updates
4. **Assets**: pubspec.yaml asset paths may need updates
5. **Testing**: Every move requires compilation + manual testing
6. **Merge Conflicts**: If multiple people work on this, conflicts will happen

### ✅ **MITIGATIONS:**
1. **Use IDE Refactoring**: VS Code "Move to new file" + auto-import
2. **One Folder at a Time**: Never move more than 5-10 files at once
3. **Git Commits**: Commit after each successful move/test
4. **Automated Testing**: Run `flutter test` after each phase
5. **Import Fixing Script**: Use regex find/replace for batch updates

### 📝 **IMPORTANT NOTES:**
1. **Backward Compatibility**: Keep old folder structure until migration complete
2. **Feature Flags**: Consider feature flags for merchant features
3. **Documentation**: Update README.md with new structure
4. **Team Communication**: Notify all developers before starting
5. **Rollback Plan**: Tag current version before migration starts

### 🎯 **SUCCESS CRITERIA:**
- ✅ All files compile without errors
- ✅ No file exceeds 150 lines
- ✅ All client features work identically
- ✅ Merchant scanner works identically
- ✅ All imports resolve correctly
- ✅ No broken navigation routes
- ✅ All providers registered correctly

---

## RECOMMENDED EXECUTION ORDER

### **TODAY (Immediate):**
1. Create all folder structures (Phase 1)
2. Create README.md files for each module
3. Commit: "feat: create modular folder structure"

### **Next Session:**
1. Move core utilities (Phase 2)
2. Test compilation
3. Commit: "refactor: move core utilities"

### **Following Sessions:**
1. Create merchant foundation (Phase 3)
2. Separate shared code (Phase 4)
3. Organize client code (Phase 5)
4. Continue refactoring oversized files (Phase 6)

### **Rule of Thumb:**
- Never move more than **10 files** in a single commit
- Always **test compilation** after each move
- Always **commit** after successful migration step
- Keep **old and new** structure in parallel until 100% migrated
