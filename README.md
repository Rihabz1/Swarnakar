# Swarnakar

Swarnakar is a Flutter application for jewellery businesses in Bangladesh. It focuses on daily price tracking, business calculations, customer/account flows, and a premium-style UI built around gold-accented visuals.

This repository contains:

- A **Flutter client app** with complete authentication (email/password + Google), OTP verification, and Firebase integration.
- A **Bun/TypeScript backend** with production-grade OTP service, user management, and REST API endpoints.

## What The App Does

The Flutter app is designed to help with the everyday workflows of a jewellery business:

- View gold and silver price screens.
- Run quick jewellery-related calculations.
- Estimate zakat-related values.
- Browse filtered reports.
- Sign up, log in, and verify OTP-based access.
- Manage your profile and subscription.
- Move through the app with a dashboard and bottom navigation.
- Support a premium or paywall-style experience.

## Quick Start

### Prerequisites

- **Flutter** 3.0+ ([install](https://flutter.dev/docs/get-started/install))
- **Bun** (for backend, [install](https://bun.sh))
- **Firebase** project configured with Auth and Firestore enabled

### Frontend (Flutter)

```bash
flutter pub get       # Install dependencies
flutter run -d chrome # Run on web (or -d android, -d ios)
```

### Backend (Bun)

```bash
cd backend
bun install
bun run start         # Server runs on http://localhost:8787
```

The app will auto-detect the backend on localhost:8787 (web) or 10.0.2.2:8787 (Android emulator).

## Project Layout

The app follows a feature-first structure:

- `lib/main.dart` bootstraps Flutter, initializes Bangla date formatting, and starts the app inside `ProviderScope`.
- `lib/app.dart` creates the `MaterialApp.router` shell.
- `lib/core/` holds app-wide constants, router setup, theme, providers, and utilities.
- `lib/features/` contains the product screens grouped by domain.
- `lib/shared/` contains reusable models and widgets.
- `assets/` stores images, SVGs, Rive files, and fonts.

## App Entry Points

### Startup

- [lib/main.dart](lib/main.dart) initializes Flutter bindings, sets up `bn_BD` date formatting, and launches the app.
- [lib/app.dart](lib/app.dart) applies the dark theme and connects routing.

### Routing

The router lives in [lib/core/router/app_router.dart](lib/core/router/app_router.dart) and uses GoRouter.

Available routes:

- `/` — Splash screen.
- `/login` — Login with email/password or Google.
- `/signup` — Sign up with email/password or Google.
- `/otp?email=...&flow=signup|reset` — OTP verification screen (supports signup and password reset flows).
- `/forgot-password` — Forgot password screen to request OTP.
- `/reset-password?email=...` — Reset password screen to set new password.
- `/dashboard` — Main dashboard (home screen).
- `/gold-price` — Gold price tracking.
- `/silver-price` — Silver price tracking.
- `/calculator` — Jewellery calculations.
- `/zakat` — Zakat estimator.
- `/paywall` — Subscription/premium screen.
- `/reports` — Filtered reports.
- `/settings` — User profile and app settings.

## Main Features

### Authentication

The auth system supports three methods:

1. **Email + Password**: Firebase Auth with OTP verification via backend service.
2. **Google Sign-In**: Firebase Auth with account policy enforcement (signup rejects existing accounts; login rejects new accounts).
3. **OTP Verification**: 6-digit codes sent via SMTP, with 15-minute expiry, 60-second resend cooldown, and 3-attempt max per code.

**Auth Flow**:
- Signup validates email format, password strength, and prevents duplicate accounts.
- OTP codes are generated server-side, hashed with bcrypt, and verified against rate limits (5 per hour per email).
- Login requires email verification (isEmailVerified flag in Firestore).
- User profile is synced to Firestore `users` collection with fields: uid, name, email, isSubscribed, subscriptionExpiry, isEmailVerified, createdAt, updatedAt.

**Key Files**:

- [lib/features/auth/presentation/login_screen.dart](lib/features/auth/presentation/login_screen.dart)
- [lib/features/auth/presentation/signup_screen.dart](lib/features/auth/presentation/signup_screen.dart)
- [lib/features/auth/presentation/otp_screen.dart](lib/features/auth/presentation/otp_screen.dart)
- [lib/core/services/firebase_service.dart](lib/core/services/firebase_service.dart)
- [lib/core/services/otp_service.dart](lib/core/services/otp_service.dart)
- [lib/features/auth/providers/auth_provider.dart](lib/features/auth/providers/auth_provider.dart)

**Backend OTP Service**:

- [backend/src/services/auth.service.ts](backend/src/services/auth.service.ts) — Canonical OTP logic with hashing, expiry, rate limiting.
- [backend/src/controllers/auth.controller.ts](backend/src/controllers/auth.controller.ts) — HTTP request handling.
- [backend/src/routes/auth.ts](backend/src/routes/auth.ts) — Dual-mount endpoints at `/api/auth/*` and `/auth/*`.
- Endpoints: POST `/send-otp`, `/verify-signup`, `/verify-login` (flow-agnostic verification with JWT issuance).

### Market Prices

Gold and silver have dedicated screens and supporting data/provider folders. The app is arranged to show market information in a structured, reusable way.

Key files and folders:

- [lib/features/gold_price/](lib/features/gold_price/)
- [lib/features/silver_price/](lib/features/silver_price/)
- [lib/shared/widgets/gold_price_card.dart](lib/shared/widgets/gold_price_card.dart)
- [lib/shared/widgets/price_row_widget.dart](lib/shared/widgets/price_row_widget.dart)

### Business Tools

The app includes utility screens for day-to-day jewellery calculations, zakat support, and filtered reports.

Key files:

- [lib/features/calculator/presentation/calculator_screen.dart](lib/features/calculator/presentation/calculator_screen.dart)
- [lib/features/zakat/presentation/zakat_screen.dart](lib/features/zakat/presentation/zakat_screen.dart)
- [lib/features/reports/presentation/reports_screen.dart](lib/features/reports/presentation/reports_screen.dart)

### Dashboard And Navigation

The dashboard acts as the main hub after the user enters the app. Navigation is handled through GoRouter, with a custom bottom navigation widget used across the app.

Key files:

- [lib/features/dashboard/presentation/dashboard_screen.dart](lib/features/dashboard/presentation/dashboard_screen.dart)
- [lib/shared/widgets/app_bottom_nav.dart](lib/shared/widgets/app_bottom_nav.dart)
- [lib/core/router/app_router.dart](lib/core/router/app_router.dart)

### Subscription And Settings

The app includes a paywall screen and a settings screen for app-level controls. A global subscription state is exposed through core providers.

Key files:

- [lib/features/subscription/presentation/paywall_screen.dart](lib/features/subscription/presentation/paywall_screen.dart)
- [lib/features/settings/presentation/settings_screen.dart](lib/features/settings/presentation/settings_screen.dart)
- [lib/core/providers/core_providers.dart](lib/core/providers/core_providers.dart)

## UI System

The visual layer is intentionally consistent:

- Gold-focused colors and a dark premium theme.
- Shared text styles and theme configuration.
- Reusable input and button widgets for form screens.
- Card, banner, and overlay widgets for price and premium UI.
- Motion support through `animate_do` and `rive`.
- SVG, raster image, and cached network image support.

Important files:

- [lib/core/theme/app_theme.dart](lib/core/theme/app_theme.dart)
- [lib/core/theme/app_colors.dart](lib/core/theme/app_colors.dart)
- [lib/core/theme/app_text_styles.dart](lib/core/theme/app_text_styles.dart)
- [lib/shared/widgets/golden_button.dart](lib/shared/widgets/golden_button.dart)
- [lib/shared/widgets/golden_input_field.dart](lib/shared/widgets/golden_input_field.dart)

## State And Data Flow

The app uses Riverpod for state management. The structure is designed so global app state and feature-level providers stay separated.

Common state and model locations:

- [lib/core/providers/](lib/core/providers/)
- [lib/features/*/providers/](lib/features)
- [lib/shared/models/](lib/shared/models/)

## Localization

The app is prepared for Bangla and English:

- `bn_BD`
- `en_US`

Bangla date formatting is initialized in `main.dart`, and Flutter localization support is enabled in `app.dart`.

## Firebase Integration

The app uses **Firebase Auth** and **Cloud Firestore** for authentication and data storage.

### Setup

1. Create a Firebase project at [firebase.google.com](https://firebase.google.com).
2. Enable **Firebase Authentication** (Email/Password and Google Sign-In).
3. Enable **Cloud Firestore** and create a `users` collection.
4. Download your Firebase config and update the credentials in the app if needed.

### Firestore Schema

**Collection: `users`**

Document fields (auto-created on signup):

```json
{
  "uid": "firebase-auth-uid",
  "name": "User Name",
  "email": "user@example.com",
  "isSubscribed": false,
  "subscriptionExpiry": null,
  "isEmailVerified": false,
  "createdAt": "2026-04-16T...",
  "updatedAt": "2026-04-16T..."
}
```

The settings screen pulls real user data from this collection, with fallbacks to Firebase Auth display name and email if needed.

## Technology Stack

**Frontend (Flutter)**:

- Flutter 3.0+
- Dart 3.0+
- Riverpod (state management)
- GoRouter (navigation)
- Firebase Auth (authentication)
- Cloud Firestore (data storage)
- Google Sign-In
- animate_do (animations)
- Rive (advanced animations)
- intl (localization)
- connectivity_plus (network detection)
- flutter_secure_storage (secure storage)
- google_fonts, flutter_svg, cached_network_image, shimmer

**Backend (Bun/TypeScript)**:

- Bun (fast JavaScript runtime)
- TypeScript (type-safe server code)
- Elysia framework (HTTP routing)
- bcryptjs (password/OTP hashing)
- jsonwebtoken (JWT issuance)
- nodemailer (SMTP email delivery)
- Drizzle ORM (for future database migration)

## Backend Setup

The backend runs on **Bun** (a fast JavaScript runtime) on port **8787**.

### Running the Backend

```bash
cd backend
bun install        # Install dependencies
bun run start      # Start the server on http://localhost:8787
```

### Backend Services

1. **OTP Auth Service** (`src/services/auth.service.ts`):
   - Generate 6-digit OTP codes (bcrypt hashed, 15-min expiry).
   - Verify codes with rate limiting (5 per hour per email) and attempt limiting (3 attempts per code).
   - Resend cooldown (60 seconds between requests).
   - SMTP delivery (falls back to console.log if unconfigured).
   - Issue JWT tokens on successful signup/login.

2. **User Persistence** (Currently in-memory):
   - Can migrate to Firestore or Postgres later.
   - Tracks OTP state, user sessions, and rate limits.

Flutter client:

- Flutter
- Dart
- Riverpod
- GoRouter
- animate_do
- Rive
- intl
- connectivity_plus
- flutter_secure_storage
- google_fonts
- flutter_svg
- cached_network_image
- shimmer

Backend scaffold:

- Node.js
- Express-style TypeScript layout
- Drizzle ORM configuration files are present

### Environment Variables

Create `backend/.env`:

```env
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-password
SMTP_FROM=noreply@swarnakar.app

JWT_SECRET=your-jwt-secret-key
JWT_EXPIRY=7d
```

### API Endpoints

All endpoints are available at both `/api/auth/*` and `/auth/*`:

- `POST /auth/otp/send` — Send OTP to email.
- `POST /auth/otp/verify` — Verify OTP and return JWT.
- `POST /auth/otp/resend` — Resend OTP with cooldown checks.

Request body example:

```json
{
  "email": "user@example.com",
  "code": "123456"
}
```

Response example (on success):

```json
{
  "success": true,
  "message": "OTP verified successfully",
  "jwt": "eyJhbGc...",
  "user": {
    "uid": "firebase-uid",
    "email": "user@example.com"
  }
}
```

## Backend Status (Legacy)

The [backend/](backend/) folder includes TypeScript configuration and Drizzle ORM setup for future database migration. Current implementation is production-ready for OTP auth but uses in-memory storage.

## Repository Structure

```text
Swarnakar/
├── .firebaserc
├── .gitignore
├── .metadata
├── .vscode/
│   └── settings.json
├── analysis_options.yaml
├── firebase.json
├── firestore.indexes.json
├── firestore.rules
├── pubspec.yaml
├── pubspec.lock
├── README.md
├── swarnakar.iml
├── android/
│   ├── build.gradle.kts
│   ├── gradle.properties
│   ├── local.properties
│   ├── settings.gradle.kts
│   ├── app/
│       ├── build.gradle.kts
│       └── src/
│           ├── debug/
│           ├── main/
│           └── profile/
│   └── gradle/
│       └── wrapper/
│           └── gradle-wrapper.properties
├── assets/
│   ├── fonts/
│   ├── images/
│   ├── rive/
│   └── svg/
├── backend/
│   ├── .env
│   ├── drizzle.config.ts
│   ├── package.json
│   ├── README.md
│   ├── tsconfig.json
│   └── src/
│       ├── index.ts
│       ├── controllers/
│       │   ├── auth.controller.ts
│       │   ├── calculator.controller.ts
│       │   ├── price.controller.ts
│       │   ├── reports.controller.ts
│       │   ├── subscription.controller.ts
│       │   └── zakat.controller.ts
│       ├── db/
│       │   ├── index.ts
│       │   ├── migrate.ts
│       │   ├── schema.ts
│       │   └── migrations/
│       ├── middleware/
│       │   ├── auth.middleware.ts
│       │   └── error.middleware.ts
│       ├── routes/
│       │   ├── auth.ts
│       │   ├── calculator.ts
│       │   ├── gold-price.ts
│       │   ├── reports.ts
│       │   ├── silver-price.ts
│       │   ├── subscription.ts
│       │   └── zakat.ts
│       ├── services/
│       │   ├── auth.service.ts
│       │   ├── calculator.service.ts
│       │   ├── price.service.ts
│       │   ├── reports.service.ts
│       │   ├── subscription.service.ts
│       │   └── zakat.service.ts
│       ├── types/
│       │   └── index.ts
│       └── utils/
│           └── helpers.ts
├── .idea/
│   ├── libraries/
│   ├── modules.xml
│   ├── runConfigurations/
│   └── workspace.xml
├── build/
│   └── ... generated Flutter build output omitted ...
├── lib/
│   ├── app.dart
│   ├── main.dart
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_assets.dart
│   │   │   └── app_strings.dart
│   │   ├── providers/
│   │   │   └── core_providers.dart
│   │   ├── router/
│   │   │   └── app_router.dart
│   │   ├── theme/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_styles.dart
│   │   │   └── app_theme.dart
│   │   └── utils/
│   │       ├── connectivity_helper.dart
│   │       └── currency_formatter.dart
│   ├── features/
│   │   ├── auth/
│   │   │   └── presentation/
│   │   ├── calculator/
│   │   │   ├── presentation/
│   │   │   └── providers/
│   │   ├── dashboard/
│   │   │   ├── presentation/
│   │   │   └── providers/
│   │   ├── gold_price/
│   │   │   ├── data/
│   │   │   ├── presentation/
│   │   │   └── providers/
│   │   ├── reports/
│   │   │   ├── data/
│   │   │   ├── presentation/
│   │   │   └── providers/
│   │   ├── settings/
│   │   │   └── presentation/
│   │   ├── silver_price/
│   │   │   ├── data/
│   │   │   ├── presentation/
│   │   │   └── providers/
│   │   ├── splash/
│   │   │   └── presentation/
│   │   ├── subscription/
│   │   │   └── presentation/
│   │   └── zakat/
│   │       ├── presentation/
│   │       └── providers/
│   └── shared/
│       ├── models/
│       └── widgets/
├── linux/
│   ├── CMakeLists.txt
│   ├── flutter/
│   │   ├── CMakeLists.txt
│   │   ├── generated_plugin_registrant.cc
│   │   ├── generated_plugin_registrant.h
│   │   ├── generated_plugins.cmake
│   │   └── ephemeral/
│   └── runner/
│       ├── CMakeLists.txt
│       ├── main.cc
│       ├── my_application.cc
│       └── my_application.h
└── test/
    └── widget_test.dart
```

The build directory is generated by Flutter and not meant to be edited directly, so only a summarized build entry is shown above.

## Getting Started

### Prerequisites

- Flutter SDK 3.x
- Android Studio or VS Code with Flutter and Dart extensions
- Android toolchain or Linux desktop toolchain, depending on your target platform

### Install Dependencies

```bash
flutter pub get
```

### Run The App

```bash
flutter run
```

Run on a specific device:

```bash
flutter devices
flutter run -d <device-id>
```

### Run Tests

```bash
flutter test
```

### Linux Desktop Notes

If Linux desktop packaging fails with a permission error while copying into `/usr/local`, update `linux/CMakeLists.txt` to install into `${PROJECT_BINARY_DIR}/bundle`, then run `flutter clean` before launching again with `flutter run -d linux`.

## Notes For Contributors

- Keep feature code inside `lib/features/`.
- Reuse shared widgets from `lib/shared/widgets/` before creating new UI components.
- Add new app-wide constants, router changes, and theme updates under `lib/core/`.
- Document backend behavior in this README only after the backend files contain real implementation.

## Development Notes

- Current price and report sources are mock-data driven for fast UI iteration.
- App-level providers are centralized in `lib/core/providers/core_providers.dart`.
- Keep feature changes scoped inside each feature module to preserve maintainability.

## Version

Current app version from `pubspec.yaml`:

- `2.1.0+1`
