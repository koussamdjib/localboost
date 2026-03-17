# Merchant-Side MVP Architecture

**Project**: LocalBoost/NearDeal  
**Date**: March 8, 2026  
**Status**: Architecture Definition (Pre-Implementation)

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Merchant Feature Map](#merchant-feature-map)
3. [Merchant Screen Tree](#merchant-screen-tree)
4. [Merchant User Flows](#merchant-user-flows)
5. [Merchant Data Models](#merchant-data-models)
6. [Merchant-to-Client Data Flow](#merchant-to-client-data-flow)
7. [Backend/API Expectations](#backendapi-expectations)
8. [Implementation Order](#implementation-order)
9. [Risks & Dependencies](#risks--dependencies)

---

## 1. Executive Summary

### Purpose
Define a merchant-facing mobile application that enables business owners to:
- Manage their shop identity and settings
- Create and publish flyers (PDF/image prospectus)
- Create and manage deals/loyalty programs
- Scan customer QR codes to grant stamps and redeem rewards
- View basic dashboard statistics

### Key Architectural Principles
1. **Flyers as First-Class Objects**: Flyers are multi-product promotional documents (PDF/image), not individual product cards
2. **Modular from Day One**: No file exceeds 150 lines; clear separation of concerns
3. **Client-Side Coherence**: Merchant actions directly feed customer-side data structures
4. **Progressive Complexity**: MVP focuses on core workflows; advanced features deferred

### Merchant vs. Customer Architecture
- **Customer Side**: Browse → Discover → Enroll → Collect → Redeem
- **Merchant Side**: Setup → Publish → Scan → Track → Analyze

---

## 2. Merchant Feature Map

### 2.1 Core Features (MVP Phase 1)

#### A. Shop Management
- **Shop Profile**
  - Business name, description, category
  - Logo and cover image upload
  - Contact information (phone, email, address)
  - Business hours
  - GPS location configuration
  
#### B. Flyer Management
- **Create Flyer**
  - Upload PDF or image file
  - Set flyer title and validity period
  - Preview before publishing
  - Auto-extract products (future: OCR/AI-assisted)
  
- **Manage Flyers**
  - List of active/expired flyers
  - Edit flyer details (title, validity)
  - Pause/unpublish flyer
  - Delete flyer
  - View flyer engagement stats (views, shares)

#### C. Deal/Loyalty Program Management
- **Create Program**
  - Program type: Flash Sale, Loyalty Card, Standard Deal
  - Reward configuration:
    - Stamps required
    - Reward value and type (free item, discount, money, special offer)
  - Terms and conditions
  - Validity period (start/end dates)
  - Enrollment limit (optional)
  
- **Manage Programs**
  - List of active/scheduled/expired programs
  - Edit program details (not stamps required if enrollments exist)
  - Pause/resume program
  - View program stats (enrollments, stamps granted, redemptions)

#### D. Scanner Operations
- **QR Code Scanner** (EXISTING - needs refactoring)
  - Scan customer QR code
  - Identify customer enrollment
  - Grant stamp (with optional merchant note)
  - Redeem reward (mark as used)
  - Offline mode support (queue operations)
  
#### E. Dashboard & Analytics
- **Quick Stats**
  - Active programs count
  - Total enrollments (all programs)
  - Stamps granted today/this week
  - Pending redemptions
  
- **Recent Activity**
  - Latest stamp grants
  - Latest redemptions
  - New customer enrollments

### 2.2 Deferred Features (Post-MVP)

- **Advanced Analytics**
  - Customer retention graphs
  - Peak hours analysis
  - Revenue impact tracking
  - Export reports (CSV, PDF)
  
- **Notifications**
  - New customer enrollment alerts
  - Completed reward alerts
  - Low inventory warnings (for flyers/stamps)
  
- **Multi-Location Support**
  - Manage multiple shop locations from one account
  - Location-specific programs
  
- **Team Management**
  - Add staff accounts with limited permissions
  - Role-based access control
  - Activity audit logs

---

## 3. Merchant Screen Tree

```
MerchantApp (Root)
│
├── Authentication
│   ├── MerchantLoginScreen
│   ├── MerchantRegisterScreen
│   └── ForgotPasswordScreen
│
├── Main Navigation (Bottom Nav)
│   ├── Dashboard
│   │   ├── DashboardScreen (home)
│   │   ├── StatsWidget
│   │   ├── RecentActivityList
│   │   └── QuickActionsCard
│   │
│   ├── Flyers
│   │   ├── FlyersListScreen
│   │   ├── CreateFlyerScreen
│   │   │   ├── FlyerUploadStep
│   │   │   ├── FlyerDetailsStep
│   │   │   └── FlyerPreviewStep
│   │   ├── EditFlyerScreen
│   │   └── FlyerStatsScreen (detail view)
│   │
│   ├── Deals
│   │   ├── DealsListScreen
│   │   ├── CreateDealScreen
│   │   │   ├── DealTypeSelector
│   │   │   ├── RewardConfigStep
│   │   │   ├── TermsConfigStep
│   │   │   └── DealPreviewStep
│   │   ├── EditDealScreen
│   │   └── DealStatsScreen (detail view)
│   │
│   ├── Scanner
│   │   ├── ScannerScreen (QR scanner)
│   │   ├── StampConfirmationDialog
│   │   └── RedemptionConfirmationDialog
│   │
│   └── Profile
│       ├── MerchantProfileScreen
│       ├── EditShopScreen
│       ├── BusinessHoursScreen
│       ├── SettingsScreen
│       └── HelpScreen
│
└── Shared Dialogs/Modals
    ├── SuccessDialog
    ├── ErrorDialog
    ├── ConfirmationDialog
    └── LoadingOverlay
```

### Screen Responsibilities (≤150 lines each)

| Screen | Primary Responsibility | Lines Est. |
|--------|----------------------|-----------|
| DashboardScreen | Display stats overview + recent activity | 130 |
| FlyersListScreen | List flyers with filter/sort | 120 |
| CreateFlyerScreen | Multi-step flyer creation wizard | 140 |
| FlyerStatsScreen | Detailed flyer analytics | 110 |
| DealsListScreen | List deals with status indicators | 120 |
| CreateDealScreen | Multi-step deal creation wizard | 145 |
| DealStatsScreen | Detailed deal analytics | 115 |
| ScannerScreen | QR scanner + quick action buttons | 130 |
| MerchantProfileScreen | Shop profile display + edit navigation | 100 |
| EditShopScreen | Form for shop details editing | 140 |

---

## 4. Merchant User Flows

### Flow 1: First-Time Merchant Setup
```
1. Register merchant account
   ├── Email/phone + password
   ├── Business verification (email/SMS code)
   └── Accept terms of service

2. Complete shop profile
   ├── Upload logo
   ├── Upload cover image
   ├── Enter business details (name, category, description)
   ├── Set location (GPS or manual)
   └── Configure business hours

3. Create first loyalty program
   ├── Follow "Create Deal" wizard
   └── Publish program

4. Dashboard shows onboarding checklist
   ├── ✅ Profile complete
   ├── ✅ First program created
   ├── ⬜ Upload first flyer
   └── ⬜ Grant first stamp
```

### Flow 2: Create & Publish Flyer
```
1. Navigate to Flyers tab
2. Tap "+" Create Flyer button
3. Step 1: Upload File
   ├── Choose PDF or Image from device
   ├── Preview uploaded file
   └── Tap "Next"
4. Step 2: Enter Details
   ├── Flyer title (e.g., "Weekly Specials")
   ├── Validity period (date picker)
   ├── Category (auto-filled from shop category)
   └── Tap "Next"
5. Step 3: Preview & Publish
   ├── Review all details
   ├── Tap "Publish Flyer"
   └── Success confirmation → back to Flyers list
```

### Flow 3: Create Loyalty Program
```
1. Navigate to Deals tab
2. Tap "+" Create Deal button
3. Step 1: Choose Deal Type
   ├── Flash Sale (time-limited)
   ├── Loyalty Card (stamp-based)
   └── Standard Deal (simple offer)
4. Step 2: Configure Reward
   ├── Stamps required (if loyalty)
   ├── Reward type (free item, discount, etc.)
   ├── Reward value/description
   └── Upload reward image (optional)
5. Step 3: Set Terms
   ├── Validity period
   ├── Terms & conditions text
   ├── Max enrollments (optional)
   └── Auto-renew toggle (future)
6. Step 4: Preview & Publish
   ├── Review all details
   ├── Tap "Publish Deal"
   └── Success confirmation → back to Deals list
```

### Flow 4: Grant Stamp via QR Scan
```
1. Navigate to Scanner tab
2. Position camera to scan customer QR code
3. Auto-detect QR code (LOCALBOOST-DJIBOUTI-USER-{userId})
4. System validates:
   ├── User exists
   ├── User is enrolled in this shop's program
   └── Program is active
5. Merchant confirms:
   ├── Customer name/ID displayed
   ├── Current stamp count shown
   ├── Optional: Add merchant note
   └── Tap "Grant Stamp"
6. Success animation + sound
7. Updated stamp count displayed
8. Return to scanner (ready for next scan)
```

### Flow 5: Redeem Reward via QR Scan
```
1. Navigate to Scanner tab
2. Scan customer QR code
3. System detects completed reward
4. Merchant confirms:
   ├── Customer name/ID displayed
   ├── Reward details shown (e.g., "Free Coffee")
   ├── Customer confirmation required
   └── Tap "Redeem Reward"
5. Success animation + confetti
6. Enrollment marked as redeemed
7. Option to re-enroll customer immediately
8. Return to scanner
```

---

## 5. Merchant Data Models

### 5.1 MerchantAccount
```dart
class MerchantAccount {
  final String id;
  final String businessName;
  final String ownerName;
  final String email;
  final String phone;
  final String? logoUrl;
  final String? coverImageUrl;
  final String description;
  final ShopCategory category; // Reuse from client-side
  final String address;
  final double latitude;
  final double longitude;
  final BusinessHours businessHours;
  final DateTime createdAt;
  final bool isVerified;
  final bool isActive;
  
  // Computed
  bool get isProfileComplete => logoUrl != null && description.isNotEmpty;
}
```

### 5.2 BusinessHours
```dart
class BusinessHours {
  final Map<DayOfWeek, DaySchedule?> schedule; // null = closed
  final List<SpecialHours> specialHours; // holidays, temp closures
  
  bool isOpenNow();
  String getOpeningStatus(); // "Open", "Closed", "Opens at 9:00 AM"
}

class DaySchedule {
  final TimeOfDay openTime;
  final TimeOfDay closeTime;
  final TimeOfDay? breakStart; // Optional lunch break
  final TimeOfDay? breakEnd;
}

enum DayOfWeek { monday, tuesday, wednesday, thursday, friday, saturday, sunday }
```

### 5.3 MerchantFlyer (extends client-side Flyer)
```dart
class MerchantFlyer extends Flyer {
  final String merchantId;
  final FlyerStatus status; // draft, published, paused, expired
  final String fileUrl; // Full PDF/image URL
  final int viewCount;
  final int shareCount;
  final DateTime createdAt;
  final DateTime? publishedAt;
  final DateTime? lastEditedAt;
  
  // Override/add merchant-specific methods
  bool get isPublished => status == FlyerStatus.published;
  bool get canEdit => status != FlyerStatus.expired;
  bool get isExpired => DateTime.now().isAfter(validUntilDate);
}

enum FlyerStatus { draft, published, paused, expired }
```

### 5.4 MerchantDeal (extends client-side Shop concept)
```dart
class MerchantDeal {
  final String id;
  final String merchantId;
  final String title;
  final String description;
  final DealType dealType; // flashSale, loyalty, standard
  final int stampsRequired; // For loyalty programs
  final RewardConfig reward;
  final String? imageUrl;
  final String termsAndConditions;
  final DateTime startDate;
  final DateTime endDate;
  final int? maxEnrollments;
  final DealStatus status;
  
  // Analytics
  final int enrollmentCount;
  final int stampsGrantedTotal;
  final int redemptionCount;
  
  // Computed
  bool get isActive => status == DealStatus.active && 
                       DateTime.now().isBefore(endDate);
  bool get canEnroll => maxEnrollments == null || 
                        enrollmentCount < maxEnrollments!;
  double get redemptionRate => enrollmentCount > 0 
      ? redemptionCount / enrollmentCount 
      : 0.0;
}

enum DealStatus { draft, active, paused, expired }

class RewardConfig {
  final String rewardType; // 'free_item', 'discount', 'money', 'special_offer'
  final String rewardValue; // "Free Coffee", "20% Off", "500 FDJ"
  final String? rewardDescription;
}
```

### 5.5 StampTransaction (merchant-initiated)
```dart
class StampTransaction {
  final String id;
  final String merchantId;
  final String userId;
  final String enrollmentId;
  final String dealId;
  final TransactionType type; // stamp_added, reward_redeemed
  final int stampsAdded; // Usually 1, but can be bulk
  final String? merchantNote;
  final String merchantStaffName; // Who scanned
  final DateTime timestamp;
  final bool isSynced; // For offline mode
  
  // Computed
  String get displayText => type == TransactionType.stamp_added
      ? "$stampsAdded stamp(s) granted"
      : "Reward redeemed";
}

enum TransactionType { stamp_added, reward_redeemed }
```

### 5.6 MerchantStats (dashboard aggregates)
```dart
class MerchantStats {
  final String merchantId;
  final DateTime periodStart;
  final DateTime periodEnd;
  
  // Deals
  final int activeDealsCount;
  final int totalEnrollments;
  final int newEnrollmentsThisPeriod;
  
  // Stamps
  final int stampsGrantedToday;
  final int stampsGrantedThisWeek;
  final int stampsGrantedTotal;
  
  // Redemptions
  final int redemptionsToday;
  final int redemptionsThisWeek;
  final int redemptionsTotal;
  
  // Flyers
  final int activeFlyersCount;
  final int flyerViewsThisPeriod;
  final int flyerSharesThisPeriod;
  
  // Computed
  double get avgStampsPerDay => stampsGrantedThisWeek / 7;
  double get redemptionRateOverall => totalEnrollments > 0
      ? redemptionsTotal / totalEnrollments
      : 0.0;
}
```

---

## 6. Merchant-to-Client Data Flow

### How Merchant Actions Feed Customer Side

#### 6.1 Flyer Publication Flow
```
MERCHANT SIDE                    BACKEND                      CLIENT SIDE
─────────────────────────────────────────────────────────────────────────
CreateFlyerScreen                                            
  ├─ Upload PDF/image    ──→  POST /merchant/flyers         
  ├─ Set details             ├─ Store file in CDN          
  └─ Publish             ──→  ├─ Create Flyer record        
                              ├─ Trigger notification       ──→  Push to nearby clients
                              └─ Update search index        ──→  Available in FlyersPage
                                                            ──→  Searchable in SearchPage
```

**Client-Side Impact:**
- New flyer appears in `FlyersPage` (lib/screens/flyers_page.dart)
- Searchable via `SearchService.searchFlyers()`
- Triggers notification if client enabled `newFlyersAlerts`

#### 6.2 Deal Creation Flow
```
MERCHANT SIDE                    BACKEND                      CLIENT SIDE
─────────────────────────────────────────────────────────────────────────
CreateDealScreen                                            
  ├─ Configure reward    ──→  POST /merchant/deals          
  ├─ Set stamps & terms      ├─ Create Deal record         
  └─ Publish             ──→  ├─ Generate shop-compatible   
                              │   data structure            
                              ├─ Trigger geofence check     ──→  Push to nearby clients
                              └─ Update discovery index     ──→  Available in HomePage
                                                            ──→  Available in deals section
```

**Client-Side Impact:**
- New deal appears as `Shop` object in `mockShops` (future: API call)
- Visible in `HomePage` "Nearby Deals" section
- Enrollable via `DealDetailsPage`
- Searchable via `SearchService.searchShops()`

#### 6.3 Stamp Grant Flow
```
MERCHANT SIDE                    BACKEND                      CLIENT SIDE
─────────────────────────────────────────────────────────────────────────
ScannerScreen                                               
  ├─ Scan QR code        ──→  POST /merchant/stamps         
  ├─ Validate enrollment     ├─ Validate enrollment        
  └─ Grant stamp         ──→  ├─ Update Enrollment.stamps   ──→  EnrollmentProvider updates
                              ├─ Create Transaction record  ──→  Transaction history
                              ├─ Check if reward complete   
                              └─ Trigger notification       ──→  Push "Stamp Collected!" alert
```

**Client-Side Impact:**
- `Enrollment.stampsCollected` increments
- `EnrollmentProvider` notifies listeners → UI updates
- `StampHistorySection` shows new entry in `DealDetailsPage`
- Client receives local notification (if enabled)
- `MyCardsPage` updates progress bar

#### 6.4 Reward Redemption Flow
```
MERCHANT SIDE                    BACKEND                      CLIENT SIDE
─────────────────────────────────────────────────────────────────────────
ScannerScreen                                               
  ├─ Scan QR code        ──→  POST /merchant/redeem         
  ├─ Confirm redemption      ├─ Validate completion        
  └─ Mark redeemed       ──→  ├─ Set Enrollment.isRedeemed  ──→  EnrollmentProvider updates
                              ├─ Create Transaction         ──→  Transaction history
                              ├─ Reset or archive           
                              └─ Trigger notification       ──→  Push "Reward Used!" alert
```

**Client-Side Impact:**
- `Enrollment.isRedeemed = true`
- `DealDetailsPage` shows "Redeemed" badge
- `MyCardsPage` moves to "Completed" tab
- Client receives congratulations notification

---

## 7. Backend/API Expectations

### 7.1 Authentication Endpoints

```
POST   /auth/merchant/register
POST   /auth/merchant/login
POST   /auth/merchant/verify-email
POST   /auth/merchant/reset-password
GET    /auth/merchant/me
PUT    /auth/merchant/profile
```

### 7.2 Shop Management Endpoints

```
GET    /merchant/shop
PUT    /merchant/shop
PUT    /merchant/shop/logo
PUT    /merchant/shop/cover
PUT    /merchant/shop/hours
GET    /merchant/shop/stats
```

### 7.3 Flyer Management Endpoints

```
GET    /merchant/flyers
POST   /merchant/flyers
GET    /merchant/flyers/:id
PUT    /merchant/flyers/:id
DELETE /merchant/flyers/:id
POST   /merchant/flyers/:id/publish
POST   /merchant/flyers/:id/pause
GET    /merchant/flyers/:id/stats
POST   /merchant/flyers/upload  # For file upload
```

**Request/Response Examples:**

```json
// POST /merchant/flyers
{
  "title": "Weekly Specials",
  "validUntil": "2026-03-15T23:59:59Z",
  "fileUrl": "https://cdn.localboost.dj/flyers/merchant123_flyer456.pdf",
  "fileType": "pdf",
  "category": "supermarket"
}

// Response
{
  "id": "flyer-456",
  "merchantId": "merchant-123",
  "status": "draft",
  "createdAt": "2026-03-08T10:30:00Z",
  // ... other fields
}
```

### 7.4 Deal Management Endpoints

```
GET    /merchant/deals
POST   /merchant/deals
GET    /merchant/deals/:id
PUT    /merchant/deals/:id
DELETE /merchant/deals/:id
POST   /merchant/deals/:id/publish
POST   /merchant/deals/:id/pause
GET    /merchant/deals/:id/stats
GET    /merchant/deals/:id/enrollments
```

**Request/Response Examples:**

```json
// POST /merchant/deals
{
  "title": "Coffee Loyalty Card",
  "description": "Buy 10 coffees, get 1 free!",
  "dealType": "loyalty",
  "stampsRequired": 10,
  "reward": {
    "rewardType": "free_item",
    "rewardValue": "Free Coffee",
    "rewardDescription": "Any size, any flavor"
  },
  "termsAndConditions": "Valid for 30 days from enrollment.",
  "startDate": "2026-03-09T00:00:00Z",
  "endDate": "2026-06-09T23:59:59Z",
  "maxEnrollments": null
}

// Response
{
  "id": "deal-789",
  "merchantId": "merchant-123",
  "status": "active",
  "enrollmentCount": 0,
  "stampsGrantedTotal": 0,
  "redemptionCount": 0,
  "createdAt": "2026-03-08T10:45:00Z",
  // ... other fields
}
```

### 7.5 Scanner/Transaction Endpoints

```
POST   /merchant/stamps/grant
POST   /merchant/rewards/redeem
GET    /merchant/transactions?page=1&limit=20
GET    /merchant/enrollments/:enrollmentId  # For QR validation
```

**Request/Response Examples:**

```json
// POST /merchant/stamps/grant
{
  "userId": "user-001",
  "dealId": "deal-789",
  "stampsToAdd": 1,
  "merchantNote": "Cappuccino purchased",
  "staffName": "John (Cashier)"
}

// Response
{
  "transactionId": "txn-1001",
  "enrollmentId": "enroll-555",
  "newStampCount": 7,
  "stampsRequired": 10,
  "isCompleted": false,
  "timestamp": "2026-03-08T11:00:00Z"
}

// POST /merchant/rewards/redeem
{
  "userId": "user-001",
  "enrollmentId": "enroll-555",
  "dealId": "deal-789",
  "staffName": "John (Cashier)"
}

// Response
{
  "transactionId": "txn-1002",
  "success": true,
  "rewardRedeemed": "Free Coffee",
  "timestamp": "2026-03-08T11:05:00Z"
}
```

### 7.6 Dashboard/Analytics Endpoints

```
GET    /merchant/dashboard/stats?period=today|week|month
GET    /merchant/dashboard/recent-activity?limit=10
GET    /merchant/analytics/deals/:dealId?start=:date&end=:date
GET    /merchant/analytics/flyers/:flyerId?start=:date&end=:date
```

### 7.7 Expected Backend Services

1. **File Storage Service**
   - CDN for flyer PDFs/images
   - Image optimization/resizing
   - Secure upload URLs (presigned)

2. **Geofencing Service**
   - Trigger nearby client notifications when deals/flyers published
   - Calculate distance for "nearby deals" alerts

3. **Notification Service (FCM)**
   - Send push notifications to clients
   - Send merchant alerts (new enrollments, completed rewards)

4. **Search/Discovery Service**
   - Real-time indexing of deals and flyers
   - Category-based filtering
   - Location-based ranking

5. **Analytics Service**
   - Aggregate merchant stats (daily/weekly/monthly)
   - Track flyer views and shares
   - Calculate redemption rates

---

## 8. Implementation Order

### Phase 1: Foundation (Week 1)
**Goal**: Basic merchant infrastructure + scanner refactor

1. **Models**
   - Create `lib/merchant/models/merchant_account.dart`
   - Create `lib/merchant/models/business_hours.dart`
   - Create `lib/merchant/models/stamp_transaction.dart`
   
2. **Services**
   - Create `lib/merchant/services/merchant_auth_service.dart`
   - Create `lib/merchant/services/merchant_api_service.dart` (mock)
   
3. **Providers**
   - Create `lib/merchant/providers/merchant_auth_provider.dart`
   
4. **Scanner Refactor**
   - Move `merchant_scanner_screen.dart` to `lib/merchant/screens/scanner/`
   - Split into smaller widgets (<150 lines)
   - Extract scanner logic to `ScannerService`

**Deliverables:**
- ✅ Merchant auth flow (login/register screens)
- ✅ Refactored scanner (under 150 lines, modular)
- ✅ Mock API service for testing

---

### Phase 2: Dashboard (Week 2)
**Goal**: Merchant home screen with stats overview

1. **Models**
   - Create `lib/merchant/models/merchant_stats.dart`
   
2. **Services**
   - Create `lib/merchant/services/stats_service.dart`
   
3. **Screens**
   - Create `lib/merchant/screens/dashboard/dashboard_screen.dart`
   - Create `lib/merchant/widgets/stats_card.dart`
   - Create `lib/merchant/widgets/recent_activity_list.dart`
   
4. **Navigation**
   - Create merchant bottom navigation
   - Integrate dashboard as home tab

**Deliverables:**
- ✅ Dashboard screen with mock stats
- ✅ Recent activity feed
- ✅ Quick action buttons (to scanner, create deal, create flyer)

---

### Phase 3: Deal Management (Week 3)
**Goal**: Create, edit, and manage loyalty programs

1. **Models**
   - Create `lib/merchant/models/merchant_deal.dart`
   - Create `lib/merchant/models/reward_config.dart`
   
2. **Services**
   - Create `lib/merchant/services/deal_service.dart`
   
3. **Providers**
   - Create `lib/merchant/providers/deal_provider.dart`
   
4. **Screens**
   - Create `lib/merchant/screens/deals/deals_list_screen.dart`
   - Create `lib/merchant/screens/deals/create_deal_screen.dart` (wizard)
   - Create `lib/merchant/screens/deals/edit_deal_screen.dart`
   - Create `lib/merchant/screens/deals/deal_stats_screen.dart`
   
5. **Widgets**
   - Create `lib/merchant/widgets/deal_card.dart`
   - Create `lib/merchant/widgets/deal_status_badge.dart`

**Deliverables:**
- ✅ Deal creation wizard (3-4 steps, each <150 lines)
- ✅ Active deals list with filters
- ✅ Deal stats/analytics view

---

### Phase 4: Flyer Management (Week 4)
**Goal**: Upload, publish, and manage flyers

1. **Models**
   - Create `lib/merchant/models/merchant_flyer.dart`
   
2. **Services**
   - Create `lib/merchant/services/flyer_service.dart`
   - Create `lib/merchant/services/file_upload_service.dart`
   
3. **Providers**
   - Create `lib/merchant/providers/flyer_provider.dart`
   
4. **Screens**
   - Create `lib/merchant/screens/flyers/flyers_list_screen.dart`
   - Create `lib/merchant/screens/flyers/create_flyer_screen.dart` (wizard)
   - Create `lib/merchant/screens/flyers/edit_flyer_screen.dart`
   - Create `lib/merchant/screens/flyers/flyer_stats_screen.dart`
   
5. **Widgets**
   - Create `lib/merchant/widgets/flyer_card.dart`
   - Create `lib/merchant/widgets/flyer_upload_widget.dart`
   - Create `lib/merchant/widgets/flyer_preview.dart`

**Deliverables:**
- ✅ Flyer upload (PDF/image picker)
- ✅ Flyer creation wizard
- ✅ Active flyers list
- ✅ Flyer preview and stats

---

### Phase 5: Shop Profile (Week 5)
**Goal**: Manage merchant shop identity and settings

1. **Models**
   - Extend `merchant_account.dart` with all profile fields
   
2. **Services**
   - Create `lib/merchant/services/shop_service.dart`
   
3. **Providers**
   - Create `lib/merchant/providers/shop_provider.dart`
   
4. **Screens**
   - Create `lib/merchant/screens/profile/merchant_profile_screen.dart`
   - Create `lib/merchant/screens/profile/edit_shop_screen.dart`
   - Create `lib/merchant/screens/profile/business_hours_screen.dart`
   - Create `lib/merchant/screens/profile/settings_screen.dart`
   
5. **Widgets**
   - Create `lib/merchant/widgets/shop_header.dart`
   - Create `lib/merchant/widgets/hours_editor.dart`

**Deliverables:**
- ✅ Shop profile view
- ✅ Edit shop details (name, logo, description, etc.)
- ✅ Business hours configuration
- ✅ Settings (notifications, account)

---

### Phase 6: Integration & Testing (Week 6)
**Goal**: Connect merchant-to-client flows, polish UX

1. **Integration**
   - Link merchant actions to client-side data updates
   - Test scanner → client enrollment update flow
   - Test deal creation → client discovery flow
   - Test flyer publish → client flyers page flow
   
2. **Offline Support**
   - Implement offline stamp queue
   - Auto-sync when back online
   
3. **Error Handling**
   - Graceful failure messages
   - Retry mechanisms for failed API calls
   
4. **UX Polish**
   - Loading states
   - Empty states
   - Success animations
   - Haptic feedback for scanner

**Deliverables:**
- ✅ End-to-end merchant-to-client flows working
- ✅ Offline mode for scanner
- ✅ Error handling and retry logic
- ✅ Polished UI/UX

---

## 9. Risks & Dependencies

### 9.1 Risks

#### Technical Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|-----------|------------|
| **Scanner performance on low-end devices** | High | Medium | Test on budget Android devices; optimize camera initialization |
| **File upload failures (flyers)** | Medium | Medium | Implement chunked uploads; retry logic; show progress |
| **Offline sync conflicts** | Medium | Low | Use optimistic UI updates; resolve conflicts server-side |
| **Scanner not working on iOS** | High | Low | Test early on iOS; use maintained `mobile_scanner` package |
| **Data model mismatch (merchant ↔ client)** | High | Low | Shared models in `/shared`; strict API contracts |

#### Product Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|-----------|------------|
| **Merchants don't understand QR scanning** | High | Medium | In-app tutorial; video guides; customer support |
| **Merchants prefer web dashboard over mobile** | Medium | Medium | Ensure web version mirrors mobile features; progressive enhancement |
| **Low merchant adoption** | High | Low | Pilot with 5-10 merchants; iterate based on feedback |
| **Flyer creation too complex** | Medium | Medium | Simplify to 2 steps; allow quick publish with minimal info |

### 9.2 Dependencies on Client Side

#### Hard Dependencies (Must Not Break)

1. **Enrollment Model**
   - Merchant scanner reads `Enrollment.userId`, `Enrollment.stampsCollected`
   - ⚠️ **Risk**: If enrollment model changes, scanner breaks
   - 🛡️ **Mitigation**: Version API contracts; use shared models

2. **EnrollmentProvider**
   - Merchant stamp grant triggers `EnrollmentProvider.addStamp()`
   - ⚠️ **Risk**: If provider method signature changes, integration fails
   - 🛡️ **Mitigation**: Treat as public API; deprecate before removing

3. **Shop/Deal Data Structure**
   - Client displays deals as `Shop` objects
   - ⚠️ **Risk**: Merchant deal format must map cleanly to client `Shop`
   - 🛡️ **Mitigation**: Backend transformation layer; strict schema validation

4. **Notification System**
   - Merchant actions trigger client notifications
   - ⚠️ **Risk**: If notification service down, client misses alerts
   - 🛡️ **Mitigation**: Queue notifications; retry failed sends

#### Soft Dependencies (Nice-to-Have)

1. **Search Service**
   - Merchant deals/flyers should be searchable by clients
   - Not critical for MVP (can be added later)

2. **Transaction History**
   - Merchant-initiated stamps should appear in client transaction history
   - Deferred to Phase 2 (client-side implementation)

3. **Geofencing**
   - "Nearby deals" alerts require backend geofencing
   - Can use simpler distance calculation for MVP

### 9.3 Backend Dependencies

#### Critical (Blocking)

1. **Authentication API**
   - Merchant login/register endpoints
   - Without this: Cannot test merchant flows
   - **ETA**: Week 1

2. **Deal CRUD API**
   - Create, read, update, delete deals
   - Without this: Cannot test deal publishing
   - **ETA**: Week 2

3. **Stamp Grant API**
   - POST /merchant/stamps/grant
   - Without this: Scanner is useless
   - **ETA**: Week 1 (highest priority)

#### Non-Critical (Can Mock)

1. **Flyer Upload API**
   - Can use local file paths for MVP
   - Real upload needed for production
   - **ETA**: Week 3-4

2. **Analytics API**
   - Can show mock stats initially
   - Real data needed for pilot merchants
   - **ETA**: Week 4-5

3. **Notification Service (FCM)**
   - Can defer to post-MVP
   - Local notifications sufficient for testing
   - **ETA**: Week 6+

### 9.4 External Dependencies

1. **mobile_scanner** package
   - Current version: 5.2.3
   - Risk: Breaking changes in future versions
   - Mitigation: Pin version; test before upgrading

2. **file_picker** package (for flyer upload)
   - Need to add to `pubspec.yaml`
   - Risk: Platform-specific issues
   - Mitigation: Test on Android + iOS early

3. **image_picker** / **image_cropper** (for logos/cover images)
   - Need to add to `pubspec.yaml`
   - Risk: iOS permissions issues
   - Mitigation: Configure Info.plist early

---

## 10. File Structure Blueprint

```
lib/
├── merchant/
│   ├── models/
│   │   ├── merchant_account.dart           (80 lines)
│   │   ├── business_hours.dart             (60 lines)
│   │   ├── merchant_flyer.dart             (70 lines)
│   │   ├── merchant_deal.dart              (90 lines)
│   │   ├── reward_config.dart              (40 lines)
│   │   ├── stamp_transaction.dart          (50 lines)
│   │   └── merchant_stats.dart             (65 lines)
│   │
│   ├── providers/
│   │   ├── merchant_auth_provider.dart     (110 lines)
│   │   ├── shop_provider.dart              (100 lines)
│   │   ├── deal_provider.dart              (130 lines)
│   │   └── flyer_provider.dart             (120 lines)
│   │
│   ├── services/
│   │   ├── merchant_auth_service.dart      (90 lines)
│   │   ├── merchant_api_service.dart       (140 lines)
│   │   ├── shop_service.dart               (100 lines)
│   │   ├── deal_service.dart               (130 lines)
│   │   ├── flyer_service.dart              (120 lines)
│   │   ├── scanner_service.dart            (80 lines)
│   │   ├── stats_service.dart              (90 lines)
│   │   └── file_upload_service.dart        (110 lines)
│   │
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── merchant_login_screen.dart  (130 lines)
│   │   │   └── merchant_register_screen.dart (140 lines)
│   │   │
│   │   ├── dashboard/
│   │   │   └── dashboard_screen.dart       (130 lines)
│   │   │
│   │   ├── deals/
│   │   │   ├── deals_list_screen.dart      (120 lines)
│   │   │   ├── create_deal_screen.dart     (145 lines)
│   │   │   ├── edit_deal_screen.dart       (140 lines)
│   │   │   └── deal_stats_screen.dart      (115 lines)
│   │   │
│   │   ├── flyers/
│   │   │   ├── flyers_list_screen.dart     (120 lines)
│   │   │   ├── create_flyer_screen.dart    (140 lines)
│   │   │   ├── edit_flyer_screen.dart      (130 lines)
│   │   │   └── flyer_stats_screen.dart     (110 lines)
│   │   │
│   │   ├── profile/
│   │   │   ├── merchant_profile_screen.dart (100 lines)
│   │   │   ├── edit_shop_screen.dart       (140 lines)
│   │   │   ├── business_hours_screen.dart  (125 lines)
│   │   │   └── settings_screen.dart        (90 lines)
│   │   │
│   │   └── scanner/
│   │       └── scanner_screen.dart         (130 lines) ← REFACTORED
│   │
│   └── widgets/
│       ├── stats_card.dart                 (60 lines)
│       ├── recent_activity_list.dart       (80 lines)
│       ├── deal_card.dart                  (70 lines)
│       ├── deal_status_badge.dart          (40 lines)
│       ├── flyer_card.dart                 (70 lines)
│       ├── flyer_upload_widget.dart        (90 lines)
│       ├── flyer_preview.dart              (80 lines)
│       ├── shop_header.dart                (60 lines)
│       ├── hours_editor.dart               (110 lines)
│       ├── stamp_confirmation_dialog.dart  (85 lines)
│       └── redemption_confirmation_dialog.dart (90 lines)
│
└── shared/
    ├── models/
    │   ├── enrollment.dart                 (EXISTING - shared)
    │   └── transaction.dart                (EXISTING - shared)
    │
    └── widgets/
        ├── success_dialog.dart             (60 lines)
        ├── error_dialog.dart               (55 lines)
        └── loading_overlay.dart            (50 lines)
```

**Total New Files**: ~40 files  
**Total Lines (estimated)**: ~4,500 lines  
**Max File Size**: 145 lines (CreateDealScreen)  
**Avg File Size**: ~112 lines ✅

---

## 11. Success Criteria

### MVP Launch Readiness Checklist

#### Functional Requirements
- [ ] Merchant can register and log in
- [ ] Merchant can complete shop profile
- [ ] Merchant can create and publish flyers (PDF/image)
- [ ] Merchant can create and publish loyalty programs
- [ ] Merchant can scan customer QR codes
- [ ] Merchant can grant stamps via scanner
- [ ] Merchant can redeem rewards via scanner
- [ ] Merchant can view dashboard stats
- [ ] All screens are <150 lines
- [ ] Client-side enrollments update in real-time when stamps granted

#### Non-Functional Requirements
- [ ] Scanner works offline (queue syncs when online)
- [ ] Scanner responds within 2 seconds
- [ ] File uploads show progress indicators
- [ ] All API errors show user-friendly messages
- [ ] App works on Android 8.0+ and iOS 13+
- [ ] No memory leaks in scanner (tested with 50+ scans)

#### User Experience
- [ ] First-time merchant onboarding takes <5 minutes
- [ ] Creating a deal takes <3 minutes
- [ ] Uploading a flyer takes <2 minutes
- [ ] Granting a stamp takes <5 seconds (from scan to confirmation)
- [ ] All actions have visual/haptic feedback

#### Code Quality
- [ ] All merchant files follow 150-line rule
- [ ] Provider/Service separation maintained
- [ ] Shared models used where applicable
- [ ] No client-side code imported in merchant code (except shared/)
- [ ] All public APIs documented
- [ ] Error handling on all async operations

---

## 12. Next Steps

### Immediate Actions (This Week)
1. **Review & Approve Architecture**
   - Validate data models with backend team
   - Confirm API contracts
   - Get stakeholder sign-off

2. **Setup Development Environment**
   - Create `lib/merchant/` folder structure
   - Install required packages (mobile_scanner, file_picker, image_picker)
   - Configure iOS permissions (Info.plist)

3. **Start Phase 1**
   - Begin merchant auth screens
   - Refactor existing scanner screen
   - Create mock API service

### Week 2-6
- Follow implementation order (Phases 1-6)
- Weekly demos to stakeholders
- Continuous testing with pilot merchants

### Post-MVP
- Add advanced analytics
- Implement multi-location support
- Build team/staff management
- Web dashboard parity

---

## Appendices

### A. Glossary

- **Flyer**: Multi-product promotional document (PDF/image), not individual product listings
- **Deal**: Generic term for any offer (flash sale, loyalty program, or standard deal)
- **Loyalty Program**: Stamp-based reward system (e.g., "Buy 10, get 1 free")
- **Stamp**: Digital loyalty stamp granted by merchant after purchase/visit
- **Enrollment**: Customer's participation in a specific merchant's loyalty program
- **Redemption**: Merchant-initiated action to mark a completed reward as used

### B. References

- Customer-Side Models: `lib/models/`
- Customer-Side Screens: `lib/screens/`
- Existing Scanner: `lib/screens/merchant_scanner_screen.dart` (needs refactor)
- Notification System: `NOTIFICATION_SYSTEM_DOCS.md`
- Architecture Guidelines: `AI_RULES.md`

---

**Document Version**: 1.0  
**Last Updated**: March 8, 2026  
**Status**: Ready for Review → Implementation
