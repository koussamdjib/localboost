# Core Module

This directory contains **global utilities, constants, themes, and configuration** used throughout the entire LocalBoost application (both client and merchant sides).

## Structure

```
core/
├── constants/      # App-wide constants (colors, strings, config values)
├── theme/          # Material theme configuration, text styles
└── utils/          # Global utility functions, validators, formatters
```

## What Goes Here

### ✅ **INCLUDE:**
- App color definitions (`AppColors`)
- App-wide string constants
- API endpoints and configuration
- Theme data (Material theme, text styles, etc.)
- Global utilities (validators, formatters, helpers)
- App-wide constants that never change

### ❌ **EXCLUDE:**
- Business logic (put in services)
- UI widgets (put in client/widgets or merchant/widgets)
- Models (put in client/models, merchant/models, or shared/models)
- Screen-specific code
- Provider state management

## Guidelines

1. **Pure Functions Only**: Code in `core/` should be stateless and reusable
2. **No Dependencies on Screens**: Don't import from client/ or merchant/
3. **Minimal External Dependencies**: Avoid heavy packages
4. **Well Documented**: Add clear comments for all constants and utilities

## Examples

**Good:**
```dart
// core/constants/app_colors.dart
class AppColors {
  static const primaryGreen = Color(0xFF00FF00);
}

// core/utils/validators.dart
class Validators {
  static bool isValidEmail(String email) { ... }
}
```

**Bad:**
```dart
// ❌ Don't put business logic here
class EnrollmentManager { ... }

// ❌ Don't put widgets here
class CustomButton extends StatelessWidget { ... }
```
