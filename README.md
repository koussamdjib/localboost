# LocalBoost - Multi-Package Architecture

LocalBoost is a Flutter workspace with separate client and merchant applications sharing common code.

## 📁 Project Structure

```
localboost/
├── client/                 # Customer-facing mobile app
│   ├── lib/
│   │   ├── screens/       # Customer screens
│   │   ├── widgets/       # Customer widgets
│   │   └── main.dart      # Client app entry point
│   ├── android/
│   ├── ios/
│   ├── web/
│   ├── test/
│   └── pubspec.yaml
│
├── merchant/              # Merchant business management app
│   ├── lib/
│   │   ├── screens/       # Merchant screens (dashboard, flyers, deals, loyalty)
│   │   ├── widgets/       # Merchant widgets
│   │   ├── providers/     # Merchant-specific state management
│   │   ├── models/        # Merchant-specific models
│   │   └── main.dart      # Merchant app entry point
│   ├── android/
│   ├── ios/
│   ├── web/
│   ├── test/
│   └── pubspec.yaml
│
├── shared/                # Shared code between apps
│   ├── lib/
│   │   ├── models/        # Common data models (Shop, Enrollment, User, etc.)
│   │   ├── services/      # API services and business logic
│   │   ├── providers/     # Shared state management (Auth, Notifications)
│   │   └── core/          # Constants, utilities, theme, colors
│   └── pubspec.yaml
│
└── docs/                  # Project documentation
    ├── AI_RULES.md
    ├── ARCHITECTURE_MIGRATION_PLAN.md
    ├── MERCHANT_MVP_ARCHITECTURE.md
    └── NOTIFICATION_SYSTEM_DOCS.md
```

## 🚀 Getting Started

### 1. Install Dependencies

```powershell
# Install shared package dependencies
cd shared
flutter pub get

# Install client app dependencies
cd ../client
flutter pub get

# Install merchant app dependencies
cd ../merchant
flutter pub get
```

### 2. Run Client App (Customer)

```powershell
cd client
flutter run -d <device-id>
```

### 3. Run Merchant App (Business)

```powershell
cd merchant
flutter run -d <device-id>
```

## 📦 Package Dependencies

- **localboost_client** → depends on → **localboost_shared**
- **localboost_merchant** → depends on → **localboost_shared**
- **localboost_shared** → standalone (only pub.dev packages)

## 🔧 Development Workflow

### Working on Shared Code

```powershell
cd shared/lib
# Make changes to models, services, providers, or core utilities
# Then run flutter pub get in client and merchant directories
```

### Working on Client Features

```powershell
cd client/lib
# Make changes to customer screens and widgets
# Import shared code: import 'package:localboost_shared/...'
```

### Working on Merchant Features

```powershell
cd merchant/lib
# Make changes to merchant screens and widgets
# Import shared code: import 'package:localboost_shared/...'
```

## ✨ Benefits of This Architecture

✅ **Separation of Concerns**: Client and merchant code completely separated  
✅ **Code Reuse**: Common models, services, providers shared efficiently  
✅ **Independent Deployment**: Build and deploy each app separately  
✅ **Smaller App Sizes**: Each app only includes relevant code  
✅ **Easier Testing**: Test client and merchant features independently  
✅ **Better CI/CD**: Independent build pipelines for each app  
✅ **Cleaner Imports**: Clear package boundaries with `package:` imports  

## 📚 Documentation

For detailed information:
- **[Merchant MVP Architecture](docs/MERCHANT_MVP_ARCHITECTURE.md)** - Merchant app features and structure
- **[Architecture Migration Plan](docs/ARCHITECTURE_MIGRATION_PLAN.md)** - Migration from monolith to multi-package
- **[Notification System](docs/NOTIFICATION_SYSTEM_DOCS.md)** - Push notification implementation
- **[AI Development Rules](docs/AI_RULES.md)** - Development guidelines and constraints

## 🎯 Features

### Client App (Customer)
- Browse local businesses and deals
- Interactive map with shop markers
- Loyalty program enrollment
- Stamp collection via QR codes
- Deal redemption
- Profile management

### Merchant App (Business)
- Business dashboard
- Flyer management (create, edit, publish)
- Deal management (flash sales, promotions)
- Loyalty program management
- Customer enrollments tracking
- QR code stamp issuance
- Analytics and insights

## 🌍 Djibouti Market Customization

- Local business names from Djibouti-Ville
- Franc Djiboutien (FDJ) currency
- Authentic Djibouti locations
- French language interface
- Optimized for local market needs

## 🛠️ Tech Stack

- **Flutter** - Cross-platform mobile framework
- **Provider** - State management
- **HTTP** - API communication
- **Google Fonts** - Typography (Poppins)
- **Flutter Map** - OpenStreetMap integration
- **Mobile Scanner** - QR code scanning
- **Flutter Local Notifications** - Push notifications

## 📱 Platforms

- ✅ Android
- ✅ iOS
- ✅ Web

---

**Note**: This project was reorganized from a monolithic structure into a multi-package architecture for better maintainability and scalability.
