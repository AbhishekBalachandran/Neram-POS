# NERAM POS - Restaurant & Cafe Management System

NERAM POS is a high-performance, internal point-of-sale mobile and tablet application built with Flutter for restaurant and cafe staff management.

---

## Key Features
- **Cross-Platform**: Android and iOS support with tailored phone and tablet layouts.
- **Modern Design System**: High-contrast, clean UI inspired by top food-tech applications (Swiggy, Zepto), featuring theme tokens, micro-animations, and haptic feedback.
- **Robust Color System**: Primary amber/orange theme (`#F59E0B`), elegant gradients, status indicators, and full Light & Dark mode support across all Material 3 components.
- **Enterprise-Grade Security**: Hardware-backed token and session security via Android Keystore and iOS Keychain (`flutter_secure_storage`).
- **Resilient Network Layer**: Powered by `Dio` with interceptors for bearer token injection, automated token refresh, and structured error handling.
- **Architecture**: Scalable MVVM pattern with Provider, engineered with clear abstractions for straightforward migration to Clean Architecture and BLoC.

---

## Directory Structure
```
lib/
├── app.dart                   # Root MaterialApp with responsive & theme configuration
├── main.dart                  # App bootstrap, security initialization & provider scope
├── core/
│   ├── config/                # Environment & runtime app configuration
│   ├── constants/             # App titles, asset paths, API endpoints
│   ├── errors/                # Typed domain and network exceptions
│   ├── network/               # Dio client, interceptors & network contract
│   ├── security/              # Secure token manager & encrypted storage
│   ├── services/              # Haptics, logger & hardware services
│   ├── theme/                 # AppColors, typography, decorations, ThemeData & ThemeProvider
│   ├── utils/                 # Responsive breakpoint helpers, formatters
│   └── widgets/               # Core atomic widgets (buttons, animated pressables)
├── data/
│   ├── models/                # DTOs and entity models
│   └── repositories/          # Abstract contracts & repository implementations
└── viewmodels/                # ViewModels (Provider ChangeNotifiers)
```

---

## Getting Started

### Prerequisites
- Flutter SDK `^3.12.2` (Dart `^3.12.2`)
- Xcode (for iOS) & Android Studio (for Android)

### Configuration
1. Copy `.env.example` to `.env` and fill in necessary endpoints:
   ```bash
   cp .env.example .env
   ```
2. For Android release builds, copy `android/key.properties.example` to `android/key.properties`:
   ```bash
   cp android/key.properties.example android/key.properties
   ```

### Running the App
```bash
flutter pub get
flutter run
```

---

## Quality & Verification
All changes must adhere to zero-warning quality standards:
```bash
dart format .
flutter analyze
flutter test
```
# Neram-POS
