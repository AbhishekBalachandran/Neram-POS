# NERAM POS - Engineering & Architecture Rules

## 1. Project Overview & Identity
- **Application Name**: NERAM POS
- **Full Display Title**: `NERAM POS - Restaurant & Cafe Management System` (Must be used in title spaces, login page headers, about dialogs, and app headers)
- **Target Platforms**: Android & iOS
- **Form Factors**: Responsive layout supporting both mobile phones and tablets (compact, medium, expanded screen sizes)

---

## 2. Architecture & Evolution Roadmap
- **Current Architecture**: MVVM (Model-View-ViewModel) pattern
  - Separation of UI (`views/` & `widgets/`), Business State Logic (`viewmodels/`), and Data Sources (`data/models/` & `data/repositories/`)
- **Future Migration**: Clean Architecture (Domain, Data, Presentation layers with UseCases)
  - All ViewModels and Repositories must be abstracted through clean contracts to guarantee seamless transition.
- **State Management**:
  - Currently: `Provider` (`ChangeNotifierProvider`, `Consumer`, `Selector`)
  - Future Migration: `BLoC` (`BlocProvider`, `BlocBuilder`, `Cubit`/`Bloc`)
  - Keep ViewModels decoupled from Flutter UI widgets so converting them to BLoCs requires zero business logic rewrite.

---

## 3. UI/UX & Design System Principles
- **Aesthetic**: Highly elegant, modern, high-contrast, fast-paced food-tech & POS interface (inspired by Swiggy, Zepto, Square POS).
- **Primary Color**: `#F59E0B` (Amber / Golden Orange)
  - Primary gradient accents: Linear gradient `[#F59E0B, #D97706]`
  - Dark mode and light mode must be thoroughly supported.
  - Every component theme must be explicitly defined in `ThemeData` (Card, AppBar, Button, Input, BottomSheet, Dialog, NavigationBar, Chip, TabBar, etc.).
- **Typography & Layout**:
  - Modern, legible typography (e.g. Poppins / Inter) with distinct hierarchy for table numbers, order statuses, item counters, bill summaries.
  - Responsive layout utilities (`ResponsiveLayout`, `DeviceUtils`) supporting dual-pane or grid layouts for tablets and unified lists for phones.
- **Interactivity & Feel**:
  - Haptic feedback integration (`HapticService`) on critical staff actions (order punch, item quantity change, payment confirmation, cancellation).
  - Micro-animations for buttons, cards, and transitions (`AnimatedPressable`, smooth fade/slide).

---

## 4. Security & Sensitive Data Handling
- **Token & Key Safety**:
  - Sensitive tokens (Access Tokens, Refresh Tokens, PINs, Passwords) must NEVER be saved in plain `SharedPreferences`.
  - Always use `SecureStorageService` backed by `flutter_secure_storage` (Android Keystore / iOS Keychain).
  - Automatically handle token refresh through Dio interceptor (`AuthInterceptor`).
- **Git & Secret Exclusions**:
  - NEVER commit actual keystores (`*.jks`, `*.keystore`), `key.properties`, `google-services.json`, `GoogleService-Info.plist`, `.env*`, real config JSON files, or iOS signing certificates.
  - Provide and maintain `*.example` templates (`.env.example`, `key.properties.example`, `config.example.json`).
  - If a production secret or file is required to proceed, STOP and ask the user.

---

## 5. Network & API Layer
- **Client**: `Dio`
- **Structure**:
  - Standardized client with interceptors for auth bearer token injection, refresh token rotation, error translation, and network timeout handling.
  - Dedicated custom exceptions (`AppException`, `ApiException`, `NetworkException`, `UnauthorizedException`).

---

## 6. Development & Quality Gate Rules
After **every** change, run and resolve all issues from:
1. `dart format .`
2. `flutter analyze` (**Zero warnings or infos allowed**)
3. `flutter test`

**Important**:
- Never report a task as completed until all three verification commands pass cleanly.
- Report all file modifications as a clean list of files, not a narrative.
- Keep changes small, atomic, and reviewable.

