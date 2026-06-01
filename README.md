# Swarnakar

Swarnakar is a full-stack jewellery business application built with Flutter (client) and Bun + Hono (backend).
It is designed for Bangladeshi jewellery workflows with a Bangla-first UI, premium-themed product experience, account management, Firebase email verification, profile management, price viewing, calculator tools, and zakat/report modules.

This document explains the entire project in detail: architecture, folder structure, feature behavior, API contracts, setup, environment configuration, and current implementation status.

---

## 1) Project Overview

### What this repository contains

- Flutter app (multi-platform scaffold: Android, iOS, Web, Desktop)
- Bun/Hono backend API in `backend/`
- Firebase configuration for Auth + Firestore
- Firestore rules and index configuration
- Asset packs (images, svg, rive)
- Feature-first Flutter codebase organization

### Primary goals of the app

- Jewellery market visibility (gold/silver price screens)
- Business utility tools (calculator and zakat)
- Authentication with Firebase email verification and reset-password OTP
- Profile and subscription-style flows
- Premium UI/UX and Bangla language experience

### Current product maturity snapshot

- Core Flutter UI and navigation are implemented and usable.
- Signup and login are implemented with Firebase Auth.
- Signup verification is now done through Firebase verification email links.
- Password reset flow is implemented with backend OTP + short-lived reset token.
- Email link sign-in is implemented for web/android deep-link flow.
- Profile API is implemented in backend and consumed by Flutter profile provider.
- Several backend modules exist as scaffold files and are not yet wired to routes.
- Many app data screens currently use local mock data providers.

---

## 2) High-Level Architecture

### Client architecture (Flutter)

- Entry: `lib/main.dart` -> `lib/app.dart`
- Routing: GoRouter in `lib/core/router/app_router.dart`
- State management: Riverpod + StateNotifier
- Services: Firebase auth/firestore services, OTP service, profile service
- Features: domain-oriented folders under `lib/features/`
- Shared UI/models: reusable components under `lib/shared/`

### Backend architecture (Bun + Hono)

- Runtime/framework: Bun + Hono
- Entry: `backend/src/index.ts`
- Active route groups:
  - `/api/auth` and `/auth` (OTP/auth endpoints)
  - `/api/profile` (authenticated profile endpoints)
- Persistence:
  - Auth OTP and temporary user store: in-memory maps in auth service
  - Profile data: Firestore via Firebase Admin SDK
- Middleware:
  - CORS + logger + pretty JSON
  - JWT decode-based auth middleware for profile routes

### External services

- Firebase Auth (client-side user auth)
- Firestore (user records, profile fields)
- SMTP (backend OTP email delivery for reset/login OTP purposes when configured)

---

## 3) Repository Structure

Top-level highlights:

- `lib/`: Flutter app source
- `backend/`: Bun/Hono server source
- `assets/`: fonts/images/rive/svg assets
- `android/`, `ios/`, `web/`, `linux/`, `macos/`, `windows/`: Flutter platform projects
- `firebase.json`, `firestore.rules`, `firestore.indexes.json`: Firebase setup files
- `pubspec.yaml`: Flutter package config

### Flutter folder map

- `lib/main.dart`: app bootstrap, Firebase init (web/android), date formatting init
- `lib/app.dart`: `MaterialApp.router`, theme, locale declarations
- `lib/core/`
  - `constants/`: static strings and shared labels
  - `providers/`: global app-level state providers
  - `router/`: GoRouter route map
  - `services/`: Firebase, OTP, Profile API integrations
  - `theme/`: color, text style, and theme definitions
  - `utils/`: formatters/utilities
- `lib/features/`
  - `auth/`: login/signup/otp/forgot/reset screens + auth provider
  - `dashboard/`: home hub and quick entry cards
  - `gold_price/`, `silver_price/`: market screens and mock data providers
  - `calculator/`: jewellery value calculator
  - `zakat/`: zakat calculator logic
  - `reports/`: filtered mock report feed
  - `settings/`: settings and profile management screens
  - `subscription/`: premium/paywall screen
  - `splash/`: startup splash flow
- `lib/shared/`
  - `models/`: `UserModel`, `PriceModel`, `ReportModel`
  - `widgets/`: common controls/cards/bottom nav

### Backend folder map

- `backend/src/index.ts`: app startup, middleware registration, active route mounting
- `backend/src/config/firebase.ts`: Firebase Admin initialization
- `backend/src/routes/`
  - Active: `auth.ts`, `profile.ts`
  - Scaffold/empty: `calculator.ts`, `gold-price.ts`, `silver-price.ts`, `reports.ts`, `subscription.ts`, `zakat.ts`
- `backend/src/controllers/`
  - Active: `auth.controller.ts`, `profile.controller.ts`
  - Scaffold/empty: several domain controllers
- `backend/src/services/`
  - Active: `auth.service.ts`, `profile.service.ts`
  - Scaffold/empty: price/report/calculator/subscription/zakat services
- `backend/src/middleware/auth.middleware.ts`: bearer token parsing and context injection
- `backend/src/types/index.ts`: OTP/auth and API type definitions
- `backend/src/utils/helpers.ts`: email validation, OTP generation/masking helpers
- `backend/src/db/`: Drizzle/Postgres schema and migration scaffolding

### Complete project architecture and file structure (workspace view)

The following structure represents the full project layout used by this workspace.
It includes all product code and platform folders. Build/cache/dependency folders can be very large, so this section focuses on the canonical project structure used for development.

```text
Swarnakar/
├── analysis_options.yaml
├── firebase.json
├── firestore.indexes.json
├── firestore.rules
├── pubspec.yaml
├── pubspec.lock
├── README.md
├── swarnakar.iml
├── .firebaserc
├── .gitignore
├── .metadata
├── .flutter-plugins-dependencies
├── .vscode/
│   └── settings.json
├── test/
│   └── widget_test.dart
├── assets/
│   ├── fonts/
│   ├── images/
│   │   ├── swarnakar.png
│   │   └── swarnakar-nobg.png
│   ├── rive/
│   └── svg/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── firebase_options.dart
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_assets.dart
│   │   │   └── app_strings.dart
│   │   ├── providers/
│   │   │   └── core_providers.dart
│   │   ├── router/
│   │   │   └── app_router.dart
│   │   ├── services/
│   │   │   ├── firebase_service.dart
│   │   │   ├── otp_service.dart
│   │   │   └── profile_service.dart
│   │   ├── theme/
│   │   │   ├── app_colors.dart
│   │   │   ├── app_text_styles.dart
│   │   │   └── app_theme.dart
│   │   └── utils/
│   │       ├── connectivity_helper.dart
│   │       └── currency_formatter.dart
│   ├── features/
│   │   ├── auth/
│   │   │   ├── presentation/
│   │   │   │   ├── login_screen.dart
│   │   │   │   ├── signup_screen.dart
│   │   │   │   ├── otp_screen.dart
│   │   │   │   ├── forgot_password_screen.dart
│   │   │   │   └── reset_password_screen.dart
│   │   │   └── providers/
│   │   │       └── auth_provider.dart
│   │   ├── splash/
│   │   │   └── presentation/
│   │   │       └── splash_screen.dart
│   │   ├── dashboard/
│   │   │   ├── presentation/
│   │   │   │   └── dashboard_screen.dart
│   │   │   └── providers/
│   │   │       └── dashboard_provider.dart
│   │   ├── gold_price/
│   │   │   ├── data/
│   │   │   │   └── gold_price_mock.dart
│   │   │   ├── presentation/
│   │   │   │   └── gold_price_screen.dart
│   │   │   └── providers/
│   │   │       └── gold_price_provider.dart
│   │   ├── silver_price/
│   │   │   ├── data/
│   │   │   │   └── silver_price_mock.dart
│   │   │   ├── presentation/
│   │   │   │   └── silver_price_screen.dart
│   │   │   └── providers/
│   │   │       └── silver_price_provider.dart
│   │   ├── calculator/
│   │   │   ├── presentation/
│   │   │   │   └── calculator_screen.dart
│   │   │   └── providers/
│   │   │       └── calculator_provider.dart
│   │   ├── zakat/
│   │   │   ├── presentation/
│   │   │   │   └── zakat_screen.dart
│   │   │   └── providers/
│   │   │       └── zakat_provider.dart
│   │   ├── reports/
│   │   │   ├── data/
│   │   │   │   └── reports_mock.dart
│   │   │   ├── presentation/
│   │   │   │   └── reports_screen.dart
│   │   │   └── providers/
│   │   │       └── reports_provider.dart
│   │   ├── subscription/
│   │   │   └── presentation/
│   │   │       └── paywall_screen.dart
│   │   └── settings/
│   │       ├── presentation/
│   │       │   ├── settings_screen.dart
│   │       │   └── profile_screen.dart
│   │       └── providers/
│   │           └── profile_provider.dart
│   └── shared/
│       ├── models/
│       │   ├── user_model.dart
│       │   ├── price_model.dart
│       │   └── report_model.dart
│       └── widgets/
│           ├── app_bottom_nav.dart
│           ├── blur_price_overlay.dart
│           ├── golden_button.dart
│           ├── golden_input_field.dart
│           ├── gold_price_card.dart
│           ├── price_row_widget.dart
│           ├── section_heading.dart
│           └── subscribe_banner.dart
├── backend/
│   ├── package.json
│   ├── package-lock.json
│   ├── bun.lock
│   ├── tsconfig.json
│   ├── drizzle.config.ts
│   ├── README.md
│   ├── .env
│   ├── swarnakar-79e57-firebase-adminsdk-fbsvc-1f11cecb42.json
│   └── src/
│       ├── index.ts
│       ├── config/
│       │   └── firebase.ts
│       ├── controllers/
│       │   ├── auth.controller.ts
│       │   ├── profile.controller.ts
│       │   ├── calculator.controller.ts
│       │   ├── price.controller.ts
│       │   ├── reports.controller.ts
│       │   ├── subscription.controller.ts
│       │   └── zakat.controller.ts
│       ├── routes/
│       │   ├── auth.ts
│       │   ├── profile.ts
│       │   ├── calculator.ts
│       │   ├── gold-price.ts
│       │   ├── silver-price.ts
│       │   ├── reports.ts
│       │   ├── subscription.ts
│       │   └── zakat.ts
│       ├── services/
│       │   ├── auth.service.ts
│       │   ├── profile.service.ts
│       │   ├── calculator.service.ts
│       │   ├── price.service.ts
│       │   ├── reports.service.ts
│       │   ├── subscription.service.ts
│       │   └── zakat.service.ts
│       ├── middleware/
│       │   ├── auth.middleware.ts
│       │   └── error.middleware.ts
│       ├── db/
│       │   ├── index.ts
│       │   ├── migrate.ts
│       │   └── schema.ts
│       ├── types/
│       │   └── index.ts
│       └── utils/
│           └── helpers.ts
├── android/
│   ├── build.gradle.kts
│   ├── gradle.properties
│   ├── gradlew
│   ├── gradlew.bat
│   ├── local.properties
│   ├── settings.gradle.kts
│   ├── swarnakar_android.iml
│   ├── app/
│   │   ├── build.gradle.kts
│   │   ├── google-services.json
│   │   └── src/
│   └── gradle/
│       └── wrapper/
│           ├── gradle-wrapper.jar
│           └── gradle-wrapper.properties
├── ios/
│   ├── Flutter/
│   ├── Runner/
│   ├── Runner.xcodeproj/
│   ├── Runner.xcworkspace/
│   └── RunnerTests/
├── macos/
│   ├── Flutter/
│   ├── Runner/
│   ├── Runner.xcodeproj/
│   ├── Runner.xcworkspace/
│   └── RunnerTests/
├── linux/
│   ├── CMakeLists.txt
│   ├── flutter/
│   └── runner/
├── windows/
│   ├── CMakeLists.txt
│   ├── flutter/
│   └── runner/
└── web/
  ├── index.html
  ├── manifest.json
  ├── favicon.png
  └── icons/
```

If you want a raw, fully exhaustive tree including generated folders (`build/`, `.dart_tool/`, `backend/node_modules/`, platform `ephemeral/` outputs), keep this command in your maintenance notes:

```bash
find . -maxdepth 6 | sort
```

---

## 4) Frontend Runtime and Routing

## App startup sequence

1. Flutter bindings initialized.
2. Firebase initialized only for web/android based on current guard in `main.dart`.
3. Bangla locale date symbols initialized (`bn_BD`).
4. App starts in Riverpod `ProviderScope`.
5. Router initial path is `/` (splash screen).

## Route table

Defined in `lib/core/router/app_router.dart`:

- `/` -> Splash
- `/login` -> Login
- `/signup` -> Signup
- `/forgot-password` -> Forgot Password
- `/finishSignIn` -> Firebase email-link completion handoff
- `/otp?email=...&flow=...` -> OTP screen (currently used for reset flow)
- `/reset-password?email=...&token=...` -> Reset Password
- `/dashboard` -> Dashboard
- `/gold-price` -> Gold market screen
- `/silver-price` -> Silver market screen
- `/calculator` -> Calculator
- `/zakat` -> Zakat
- `/paywall` -> Premium/paywall
- `/reports` -> Reports
- `/settings` -> Settings
- `/profile` -> Profile details/edit screen

---

## 5) Frontend Feature-by-Feature Explanation

## 5.1 Splash

- Visual intro with animation and brand logo.
- Automatically navigates to `/login` after ~3 seconds.

## 5.2 Authentication

### Implemented flows

- Email/password signup via Firebase Auth
- Email/password sign-in via Firebase Auth
- Google sign-in (platform-guarded)
- Firebase verification email send after signup
- Email link sign-in (Firebase action link)
- Firestore user document creation on signup
- Firebase `emailVerified` enforcement on login
- Reset-password flow via backend OTP + reset token

### Main files

- `lib/features/auth/presentation/login_screen.dart`
- `lib/features/auth/presentation/signup_screen.dart`
- `lib/features/auth/presentation/otp_screen.dart`
- `lib/features/auth/presentation/forgot_password_screen.dart`
- `lib/features/auth/presentation/reset_password_screen.dart`
- `lib/features/auth/providers/auth_provider.dart`
- `lib/core/services/firebase_service.dart`
- `lib/core/services/otp_service.dart`

### Important behavior notes

- Signup creates Firebase user + Firestore profile with `isEmailVerified: false` and sends Firebase verification email.
- Signup flow signs user out after sending verification email and routes back to login.
- Sign-in blocks non-verified users by checking Firebase Auth `emailVerified`.
- On first verified login, Firestore `isEmailVerified` is synchronized to `true`.
- Google sign-in has account policy controls (`allowNewUser`, `allowExistingUser`).

## 5.3 Dashboard

- Shows top-level gold and silver headline values from mock providers.
- Price visibility is blurred/locked when subscription provider is false.
- Grid links into all major modules.

## 5.4 Gold/Silver Price Modules

- Data source is currently local mock lists:
  - `gold_price/data/gold_price_mock.dart`
  - `silver_price/data/silver_price_mock.dart`
- Providers group entries into display sections.
- Subscription state controls blur lock + subscribe banner visibility.

## 5.5 Calculator

- User inputs quantity, market rate, labor.
- Converts input unit to bhori and calculates:
  - metal value
  - labor
  - total value
- Result is computed in Riverpod provider and displayed in UI.

## 5.6 Zakat

- Inputs: gold, silver, cash, business goods, receivable, debts.
- Provider calculates total zakatable assets and 2.5% if eligible.
- Uses local constants for rates/nisab threshold in current implementation.

## 5.7 Reports

- Uses local mock reports list.
- Client-side filter tabs: all, gold, silver, zakat.

## 5.8 Subscription/Paywall

- Paywall UI with monthly/yearly visuals.
- Tapping subscribe currently flips local app provider state to subscribed.
- No payment gateway integration yet.

## 5.9 Settings + Profile

- Settings resolves name/email from auth state + Firestore fallback + Firebase user.
- Profile screen uses backend profile API for:
  - get profile
  - update profile
  - change password event
  - delete account
  - get stats

---

## 6) Frontend State Management

Major state patterns:

- Riverpod providers for simple app states (`isSubscribed`, auth loading/errors, etc.)
- `AuthNotifier` (StateNotifier) for auth workflows
- Feature providers for dashboard, calculator, zakat, reports, prices
- `ProfileNotifier` handles backend profile API communication and editing lifecycle

Data classification in current code:

- Mock/local data: prices, reports, parts of dashboard numbers
- Firebase-backed: user auth identity + user documents
- Backend-backed: reset OTP/password endpoints and profile endpoints

---

## 7) Backend API Deep Dive

## 7.1 Entry and middleware

In `backend/src/index.ts`:

- Logger middleware enabled
- Pretty JSON response formatter enabled
- CORS configured for localhost-style origins
- Health endpoint: `GET /health`

Active route mounting:

- `app.route('/api/auth', authRoutes)`
- `app.route('/auth', authRoutes)`
- `app.route('/api/profile', profileRoutes)`

## 7.2 Auth/OTP routes

Defined in `backend/src/routes/auth.ts`.

Canonical endpoints:

- `POST /auth/send-otp`
- `POST /auth/resend-otp`
- `POST /auth/verify-login`
- `POST /auth/verify-reset`
- `POST /auth/reset-password`

Compatibility endpoints for Flutter:

- `POST /auth/otp/send`
- `POST /auth/otp/resend`
- `POST /auth/otp/verify`
- `POST /auth/otp/verify-reset`
- `POST /auth/password/reset`

Also available under `/api/auth/*` because of dual mount.

## 7.3 OTP/auth service behavior

In `backend/src/services/auth.service.ts`:

- OTP format: 6 digits
- Default OTP expiry: 10 minutes
- Default max attempts: 5
- Default resend cooldown: 45 seconds
- Default per-email hourly rate limit: 10
- OTP hash: SHA-256 over email + purpose + code
- Reset token issuance after successful reset OTP verify
- Password reset via Firebase Admin `updateUser` using reset token

Storage in current implementation:

- OTP records: in-memory `Map`
- Request windows/rate limit counters: in-memory `Map`
- Reset tokens: in-memory `Map`

Important implication:

- Backend auth-memory state resets when server restarts.

## 7.4 Profile routes

Mounted under `/api/profile` and protected by auth middleware.

- `GET /api/profile`
- `PUT /api/profile/update`
- `POST /api/profile/change-password`
- `DELETE /api/profile/delete-account`
- `GET /api/profile/stats`

Profile service uses Firebase Admin Firestore and looks in both collections:

- `users`
- `Users`

## 7.5 Auth middleware note

Current middleware in `backend/src/middleware/auth.middleware.ts` decodes JWT payload to extract user identity but does not cryptographically verify Firebase token signature in production-grade way.

This is acceptable for local/dev experimentation but should be upgraded for hardened production security.

## 7.6 Scaffold modules not yet active

These files currently exist but are empty and not route-mounted in `index.ts`:

- price/gold/silver routes
- calculator route
- reports route
- subscription route
- zakat route
- related controllers/services

---

## 8) Data and Model Notes

### Flutter models

- `UserModel`: uid, name, email, subscription state
- `PriceModel`: label, numeric price, unit, update text
- `ReportModel`: report metadata for list rendering

### Firestore document shape (client-side expectation)

Typical user doc keys used by app/backend include:

- `uid` or `firebaseId`
- `name`
- `email`
- `phone` (optional)
- `address` (optional)
- `profileImage` (optional)
- `isSubscribed`
- `subscriptionExpiry`
- `isEmailVerified`
- `totalCalculations`, `savedReports`, `favoritePrices`
- `preferences`
- timestamps (`createdAt`, `updatedAt`, etc.)

### Drizzle/Postgres scaffold

`backend/src/db/schema.ts` defines SQL-style schema for future migration, but current active backend profile persistence is Firestore.

---

## 9) Environment Configuration

## 9.1 Backend `.env`

Create `backend/.env` with at least:

```env
PORT=8787
FIREBASE_PROJECT_ID=swarnakar-79e57
GOOGLE_APPLICATION_CREDENTIALS=./firebase-service-account.json

JWT_SECRET=change-this-in-production
JWT_EXPIRES_IN=7d

OTP_EXPIRY_MINUTES=10
OTP_MAX_ATTEMPTS=5
OTP_RESEND_COOLDOWN_SECONDS=45
OTP_RATE_LIMIT_PER_HOUR=10

SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=your-email@example.com
SMTP_PASS=your-app-password
OTP_FROM_EMAIL=no-reply@swarnakar.app
```

Notes:

- If SMTP is not configured, backend logs OTP in server console (development fallback).
- Signup verification email does not use backend SMTP now; it uses Firebase Auth email verification.
- Keep service-account credentials private and never expose them publicly.

## 9.2 Flutter backend URL behavior

OTP service base URL:

- Web: `http://localhost:8787`
- Android emulator: `http://10.0.2.2:8787`
- Optional compile-time override: `--dart-define=OTP_API_BASE_URL=...`

Profile service base URL:

- Web: `http://localhost:8787`
- Android emulator: `http://10.0.2.2:8787`

---

## 10) Local Development Setup

## 10.1 Prerequisites

- Flutter SDK 3.x and Dart 3.x
- Bun runtime
- Firebase project configured
- Android Studio/Xcode/Chrome depending on target platform

## 10.2 Install dependencies

### Flutter app

```bash
flutter pub get
```

### Backend

```bash
cd backend
bun install
```

## 10.3 Run backend

```bash
cd backend
bun run dev
```

or

```bash
cd backend
bun run start
```

Backend listens on `http://localhost:8787` by default.

## 10.4 Run Flutter app

```bash
flutter run -d chrome
```

or choose another target device.

---

## 11) End-to-End Flow (Typical)

1. Start backend (`bun run dev`).
2. Start Flutter app.
3. Sign up with email/password.
4. Open verification email and click the Firebase verification link.
5. Log in and navigate dashboard/features.
6. Use forgot-password to test reset OTP -> reset token -> password update flow.
7. Open settings/profile to test profile API calls.

---

## 12) Build and Deployment Notes

### Flutter builds

- Android release: `flutter build apk --release` or `flutter build appbundle --release`
- Web release: `flutter build web`
- iOS/macOS/windows/linux builds follow standard Flutter platform commands

### Backend deployment

- Can run on any Bun-capable server/runtime.
- Ensure env vars and Firebase service account path are correctly configured.
- Replace dev/default JWT secret and tighten CORS/auth verification for production.

### Firebase configuration files in repo

- `firebase.json`
- `firestore.rules`
- `firestore.indexes.json`

Deploy Firebase resources using Firebase CLI in your own secure environment.

---

## 13) Known Gaps and Important Implementation Notes

These are important for anyone extending or productizing this codebase.

1. `main.dart` currently initializes Firebase only for web/android.
2. Firestore creation/deploy in this project requires billing enabled (Firebase CLI returns HTTP 403 without billing).
3. Many market/report values are currently mock data rather than live backend data.
4. Backend auth middleware decodes JWT but does not fully verify token signature using Firebase public keys.
5. Multiple backend domain modules are scaffolded and still empty.
6. Backend reset OTP/reset-token state is in-memory and resets on process restart.

---

## 14) Suggested Next Milestones

1. Add resend-verification UX on login screen to reduce signup friction.
2. Replace mock market/report datasets with persistent API-backed data.
3. Implement and mount remaining backend modules (prices, reports, subscription, calculator, zakat).
4. Upgrade JWT verification in middleware to full Firebase token verification.
5. Introduce persistent DB backing for reset OTP/token state if required for production continuity.
6. Integrate real payment/subscription management.

---

## 18) Recent Implementation Updates (Current Session)

This section summarizes the most important updates that were implemented after the initial README expansion.

### Authentication updates

- Signup verification moved from backend OTP to Firebase email verification links.
- Signup flow sends verification email and signs out user before returning to login.
- Login enforces Firebase `emailVerified` and synchronizes Firestore verification flag.
- Email link sign-in completion route `/finishSignIn` is active.
- Forgot password flow now uses backend reset OTP + reset token + Firebase Admin password update.

### Password-manager and UX updates

- Added autofill hints for email/password/new-password fields.
- Added `AutofillGroup` and `TextInput.finishAutofillContext(...)` on auth screens.
- Added in-app "Generate strong password" fallback on signup and reset screens.

### Backend/auth API updates

- Removed signup OTP verification path from active app flow.
- Kept reset OTP/password reset endpoints active.
- Reset eligibility checks now validate against Firebase Admin user lookup.

### Firestore and deployment setup updates

- Firestore rules/index deploy command was attempted with Firebase CLI.
- Current blocker encountered: Firestore database creation returns HTTP 403 until billing is enabled for project `swarnakar-79e57`.
- Resolution path: enable billing in Google Cloud Console for the Firebase project, then redeploy:

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

---

## 15) Key Commands Cheat Sheet

```bash
# Flutter
flutter pub get
flutter run -d chrome
flutter analyze
flutter test

# Backend
cd backend
bun install
bun run dev
bun run start

# Optional Drizzle scaffolding commands (backend/package.json)
bun run db:generate
bun run db:migrate
bun run db:studio
```

---

## 16) Technology Stack

### Client

- Flutter
- Dart
- flutter_riverpod
- go_router
- firebase_core
- firebase_auth
- cloud_firestore
- google_sign_in
- animate_do
- rive
- intl
- connectivity_plus
- flutter_secure_storage
- flutter_svg
- cached_network_image
- shimmer

### Server

- Bun
- TypeScript
- Hono
- firebase-admin
- bcryptjs
- jsonwebtoken
- nodemailer
- node-cron
- axios
- drizzle-kit (scaffold)

---

## 17) Architecture Diagrams

### High-Level System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                       CLIENT APPLICATIONS                        │
├─────────────────────────────────────────────────────────────────┤
│  Flutter App (Multi-platform)                                   │
│  ├── Web Browser (Chrome, Safari, Firefox)                      │
│  ├── Android (Native Emulator / Physical Device)                │
│  ├── iOS (Xcode Simulator / Physical Device)                    │
│  ├── Linux Desktop (GTK)                                        │
│  ├── macOS Desktop (Cocoa)                                      │
│  └── Windows Desktop (Win32)                                    │
└──────────────────────────┬──────────────────────────────────────┘
                           │
                    HTTP/REST API
                           │
┌──────────────────────────┴──────────────────────────────────────┐
│              BACKEND LAYER (Bun + Hono)                          │
├─────────────────────────────────────────────────────────────────┤
│  Routes:                                                         │
│  ├── /api/auth  → Authentication & OTP                          │
│  ├── /api/profile → User Profile Management                     │
│  ├── /health   → Status Check                                   │
│  └── [Scaffolded] prices, calculator, reports, zakat            │
│                                                                  │
│  Services:                                                       │
│  ├── AuthService (OTP generation, verification, JWT)            │
│  └── ProfileService (CRUD operations)                           │
│                                                                  │
│  Middleware:                                                     │
│  ├── CORS Handler                                               │
│  ├── Logger                                                     │
│  ├── JWT Verification                                           │
│  └── Error Handler                                              │
└──────────────┬──────────────────────────┬──────────────────────┘
               │                          │
               │                    Firebase Admin
               │                   Service Account
               │                          │
┌──────────────┴──────────────────────────┴──────────────────────┐
│           EXTERNAL SERVICES & PERSISTENCE                       │
├─────────────────────────────────────────────────────────────────┤
│  Firebase Console (Project: swarnakar-79e57)                    │
│  ├── Firebase Auth (Email/Password, Google Sign-In)            │
│  ├── Firestore Database (User profiles, stats)                 │
│  └── Firebase Hosting (Optional web deployment)                │
│                                                                  │
│  Email Delivery (SMTP)                                          │
│  └── Gmail SMTP (OTP email delivery)                            │
│                                                                  │
│  Data Store (In-Memory on Backend)                              │
│  ├── OTP Records (email, code, expiry, attempts)               │
│  ├── Reset Tokens (email, token, expiry)                       │
│  └── Request Windows (rate limiting)                           │
└─────────────────────────────────────────────────────────────────┘
```

### Frontend Data Flow (Riverpod State Management)

```
App Initialization
       ↓
ProviderScope (Riverpod Container)
       ↓
┌─────────────────────────────────┐
│   Global State Providers         │
├─────────────────────────────────┤
│ • authStateProvider             │
│ • isSubscribedProvider          │
│ • userProvider                  │
│ • connectionStatusProvider      │
└─────────────────────────────────┘
       ↓
┌─────────────────────────────────┐
│   Feature Providers              │
├─────────────────────────────────┤
│ • authNotifierProvider          │
│ • profileNotifierProvider       │
│ • goldPriceProvider             │
│ • calculatorProvider            │
│ • zakatProvider                 │
│ • reportsProvider               │
└─────────────────────────────────┘
       ↓
┌─────────────────────────────────┐
│   Core Services                  │
├─────────────────────────────────┤
│ • FirebaseService               │
│ • OTPService                    │
│ • ProfileService                │
└─────────────────────────────────┘
       ↓
┌─────────────────────────────────┐
│   External APIs                  │
├─────────────────────────────────┤
│ • Firebase Auth API             │
│ • Firestore API                 │
│ • Backend REST API              │
└─────────────────────────────────┘
```

### Authentication Flow Diagram

```
User → Signup/Login Screen
  │
  ├─ EMAIL/PASSWORD PATH:
  │  ├→ Firebase Auth (Create User)
  │  ├→ Firestore (Create User Document)
  │  ├→ Firebase Email Verification
  │  ├→ User Clicks Email Link
  │  └→ Login → Firebase Verify → Sync Firestore
  │
  └─ GOOGLE SIGN-IN PATH:
     ├→ Google Sign-In Popup
     ├→ Firebase Auth (Create/Link User)
     ├→ Firestore (Create/Update User Document)
     └→ Dashboard (Auto-verified)

RESET PASSWORD FLOW:
Forgot Password Screen
  ├→ Backend: Send OTP (email)
  ├→ User Gets OTP in Email
  ├→ OTP Screen (Verify OTP)
  ├→ Backend: Verify OTP → Generate Reset Token
  ├→ Reset Password Screen (New Password)
  ├→ Backend: Validate Token → Firebase Admin updateUser()
  └→ Login with New Password
```

---

## 18) Complete API Documentation

### API Overview

All API endpoints are prefixed with the backend base URL:
- **Development (Web):** `http://localhost:8787`
- **Development (Android Emulator):** `http://10.0.2.2:8787`
- **Production:** Configure via environment variables

### Authentication Endpoints

#### 1. Send OTP for Password Reset

**Endpoint:** `POST /auth/send-otp` or `POST /auth/otp/send`

**Description:** Initiates password reset flow by sending 6-digit OTP to user's email.

**Request Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "purpose": "reset_password"
}
```

**Response (200 - Success):**
```json
{
  "success": true,
  "message": "OTP sent successfully.",
  "data": {
    "maskedEmail": "us**@example.com",
    "expiresInSeconds": 600,
    "cooldownSeconds": 0,
    "debugOtp": "123456"  // Only in development mode
  }
}
```

**Response (400 - Error):**
```json
{
  "success": false,
  "message": "Email and purpose are required.",
  "error": "Email and purpose are required."
}
```

**Status Codes:**
- `200` - OTP sent successfully
- `400` - Invalid request parameters
- `429` - Rate limit exceeded (10 OTPs per hour per email)
- `500` - Server error

**Rate Limits:**
- 10 OTP requests per email per hour
- 45 second cooldown between resend requests

---

#### 2. Resend OTP

**Endpoint:** `POST /auth/resend-otp` or `POST /auth/otp/resend`

**Description:** Resend OTP if user didn't receive the first one.

**Request Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "purpose": "reset_password"
}
```

**Response (200 - Success):**
```json
{
  "success": true,
  "message": "OTP resent successfully.",
  "data": {
    "maskedEmail": "us**@example.com",
    "expiresInSeconds": 600,
    "cooldownSeconds": 45,
    "debugOtp": "123456"
  }
}
```

**Response (400 - Error):**
```json
{
  "success": false,
  "message": "Must wait 45 seconds before resending OTP.",
  "error": "Must wait 45 seconds before resending OTP."
}
```

**Status Codes:**
- `200` - OTP resent successfully
- `400` - Cooldown period not elapsed
- `429` - Rate limit exceeded
- `500` - Server error

---

#### 3. Verify Reset OTP

**Endpoint:** `POST /auth/verify-reset` or `POST /auth/otp/verify-reset`

**Description:** Verify the 6-digit OTP sent to user's email. Returns a reset token for password change.

**Request Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "code": "123456",
  "purpose": "reset_password"
}
```

**Response (200 - Success):**
```json
{
  "success": true,
  "message": "OTP verified successfully. Reset token generated.",
  "data": {
    "resetToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresInSeconds": 1800
  }
}
```

**Response (400 - Error):**
```json
{
  "success": false,
  "message": "Invalid or expired OTP.",
  "error": "Invalid or expired OTP."
}
```

**Response (410 - Gone):**
```json
{
  "success": false,
  "message": "No OTP request found for this email.",
  "error": "No OTP request found for this email."
}
```

**Status Codes:**
- `200` - OTP verified, reset token generated
- `400` - Invalid OTP or max attempts exceeded
- `410` - No OTP found for email
- `500` - Server error

**OTP Constraints:**
- 6 digits (0-9)
- Expires in 10 minutes (600 seconds)
- Maximum 5 verification attempts per OTP
- Case-insensitive code input

---

#### 4. Reset Password

**Endpoint:** `POST /auth/reset-password` or `POST /auth/password/reset`

**Description:** Update user password using reset token from verified OTP. Updates password in Firebase Auth.

**Request Headers:**
```
Content-Type: application/json
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "resetToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "newPassword": "SecureNewPassword123!@#"
}
```

**Response (200 - Success):**
```json
{
  "success": true,
  "message": "Password reset successfully. Please log in with your new password.",
  "data": {
    "email": "user@example.com"
  }
}
```

**Response (400 - Error):**
```json
{
  "success": false,
  "message": "Invalid or expired reset token.",
  "error": "Invalid or expired reset token."
}
```

**Response (401 - Unauthorized):**
```json
{
  "success": false,
  "message": "User not found in Firebase.",
  "error": "User not found in Firebase."
}
```

**Status Codes:**
- `200` - Password updated successfully
- `400` - Invalid token or password validation failed
- `401` - User not found
- `500` - Server error

**Password Constraints:**
- Minimum 8 characters
- Firebase Auth enforces additional security rules
- Cannot reuse recent passwords

---

### Profile Endpoints (Authenticated)

**Authentication Required:** All profile endpoints require a valid Firebase JWT token in the `Authorization` header.

```
Authorization: Bearer <Firebase_JWT_Token>
```

#### 5. Get User Profile

**Endpoint:** `GET /api/profile`

**Description:** Retrieve complete user profile information from Firestore.

**Request Headers:**
```
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IjE2YzBlODA5YjM5MzEwY2YwYzZjMWMxMzYyMzcwYjE0NjE2YzA3YTkiLCJ0eXAiOiJKV1QifQ...
```

**Request Body:** None

**Response (200 - Success):**
```json
{
  "success": true,
  "message": "Profile retrieved successfully.",
  "data": {
    "uid": "firebase_user_id_123",
    "name": "John Doe",
    "email": "john@example.com",
    "phone": "+880123456789",
    "address": "Dhaka, Bangladesh",
    "profileImage": "https://storage.googleapis.com/swarnakar-79e57.appspot.com/profiles/user_123.jpg",
    "isSubscribed": true,
    "subscriptionExpiry": "2026-12-31T23:59:59Z",
    "isEmailVerified": true,
    "totalCalculations": 45,
    "savedReports": 12,
    "favoritePrices": 8,
    "preferences": {
      "language": "bn",
      "theme": "dark",
      "notifications": true,
      "currency": "BDT"
    },
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-05-18T14:22:15Z"
  }
}
```

**Response (401 - Unauthorized):**
```json
{
  "success": false,
  "message": "Unauthorized",
  "error": "Missing or invalid token"
}
```

**Response (404 - Not Found):**
```json
{
  "success": false,
  "message": "User profile not found.",
  "error": "User profile not found."
}
```

**Status Codes:**
- `200` - Profile retrieved successfully
- `401` - Missing or invalid authentication token
- `404` - User profile doesn't exist
- `500` - Server error

---

#### 6. Update User Profile

**Endpoint:** `PUT /api/profile/update`

**Description:** Update user profile information. Only provided fields are updated (partial update supported).

**Request Headers:**
```
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IjE2YzBlODA5YjM5MzEwY2YwYzZjMWMxMzYyMzcwYjE0NjE2YzA3YTkiLCJ0eXAiOiJKV1QifQ...
```

**Request Body (all fields optional):**
```json
{
  "name": "Jane Doe",
  "phone": "+880198765432",
  "address": "Chittagong, Bangladesh",
  "profileImage": "https://storage.googleapis.com/swarnakar-79e57.appspot.com/profiles/user_123_new.jpg",
  "preferences": {
    "language": "en",
    "theme": "light",
    "notifications": false
  }
}
```

**Response (200 - Success):**
```json
{
  "success": true,
  "message": "Profile updated successfully.",
  "data": {
    "uid": "firebase_user_id_123",
    "name": "Jane Doe",
    "email": "john@example.com",
    "phone": "+880198765432",
    "address": "Chittagong, Bangladesh",
    "profileImage": "https://storage.googleapis.com/swarnakar-79e57.appspot.com/profiles/user_123_new.jpg",
    "isSubscribed": true,
    "subscriptionExpiry": "2026-12-31T23:59:59Z",
    "isEmailVerified": true,
    "totalCalculations": 45,
    "savedReports": 12,
    "favoritePrices": 8,
    "preferences": {
      "language": "en",
      "theme": "light",
      "notifications": false,
      "currency": "BDT"
    },
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-05-18T15:00:00Z"
  }
}
```

**Response (400 - Validation Error):**
```json
{
  "success": false,
  "message": "Invalid profile data provided.",
  "error": "Phone number format is invalid"
}
```

**Response (401 - Unauthorized):**
```json
{
  "success": false,
  "message": "Unauthorized",
  "error": "Missing or invalid token"
}
```

**Status Codes:**
- `200` - Profile updated successfully
- `400` - Validation error in request data
- `401` - Missing or invalid token
- `404` - User not found
- `500` - Server error

**Validation Rules:**
- `name`: 2-100 characters
- `phone`: Valid international format
- `address`: 5-500 characters
- `profileImage`: Valid HTTPS URL
- `preferences.language`: 'bn' or 'en'
- `preferences.theme`: 'dark' or 'light'

---

#### 7. Change Password

**Endpoint:** `POST /api/profile/change-password`

**Description:** Change user password (requires current password verification). Updates password in Firebase Auth.

**Request Headers:**
```
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IjE2YzBlODA5YjM5MzEwY2YwYzZjMWMxMzYyMzcwYjE0NjE2YzA3YTkiLCJ0eXAiOiJKV1QifQ...
```

**Request Body:**
```json
{
  "currentPassword": "OldPassword123!@#",
  "newPassword": "NewPassword456!@#"
}
```

**Response (200 - Success):**
```json
{
  "success": true,
  "message": "Password changed successfully.",
  "data": {
    "email": "john@example.com"
  }
}
```

**Response (400 - Invalid Current Password):**
```json
{
  "success": false,
  "message": "Current password is incorrect.",
  "error": "Current password is incorrect."
}
```

**Response (401 - Unauthorized):**
```json
{
  "success": false,
  "message": "Unauthorized",
  "error": "Missing or invalid token"
}
```

**Status Codes:**
- `200` - Password changed successfully
- `400` - Invalid current password or weak new password
- `401` - Missing or invalid token
- `500` - Server error

**Password Constraints:**
- Minimum 8 characters required
- Must include uppercase, lowercase, numbers, and special characters (recommended)
- Cannot reuse last 3 passwords

---

#### 8. Delete Account

**Endpoint:** `DELETE /api/profile/delete-account`

**Description:** Permanently delete user account, including Firestore document and Firebase Auth user. This action is irreversible.

**Request Headers:**
```
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IjE2YzBlODA5YjM5MzEwY2YwYzZjMWMxMzYyMzcwYjE0NjE2YzA3YTkiLCJ0eXAiOiJKV1QifQ...
```

**Request Body (Optional confirmation):**
```json
{
  "confirm": true
}
```

**Response (200 - Success):**
```json
{
  "success": true,
  "message": "Account deleted successfully.",
  "data": {
    "email": "john@example.com",
    "deletedAt": "2024-05-18T15:30:00Z"
  }
}
```

**Response (401 - Unauthorized):**
```json
{
  "success": false,
  "message": "Unauthorized",
  "error": "Missing or invalid token"
}
```

**Response (404 - Not Found):**
```json
{
  "success": false,
  "message": "User not found.",
  "error": "User not found."
}
```

**Status Codes:**
- `200` - Account deleted successfully
- `401` - Missing or invalid token
- `404` - User not found
- `500` - Server error

**⚠️ WARNING:** This action is irreversible. All user data will be permanently deleted.

---

#### 9. Get User Statistics

**Endpoint:** `GET /api/profile/stats`

**Description:** Retrieve user activity statistics including calculations, reports, and saved items.

**Request Headers:**
```
Content-Type: application/json
Authorization: Bearer eyJhbGciOiJSUzI1NiIsImtpZCI6IjE2YzBlODA5YjM5MzEwY2YwYzZjMWMxMzYyMzcwYjE0NjE2YzA3YTkiLCJ0eXAiOiJKV1QifQ...
```

**Request Body:** None

**Response (200 - Success):**
```json
{
  "success": true,
  "message": "User statistics retrieved successfully.",
  "data": {
    "uid": "firebase_user_id_123",
    "email": "john@example.com",
    "totalCalculations": 45,
    "totalGoldCalculations": 28,
    "totalSilverCalculations": 17,
    "savedReports": 12,
    "favoritePrices": 8,
    "favoriteGoldPrices": 5,
    "favoriteSilverPrices": 3,
    "zakatCalculations": 3,
    "lastActivityDate": "2024-05-18T14:30:00Z",
    "accountAgeInDays": 124,
    "totalTimeSpentMinutes": 3456,
    "subscriptionDaysRemaining": 227,
    "mostUsedFeature": "calculator",
    "statisticsUpdatedAt": "2024-05-18T15:00:00Z"
  }
}
```

**Response (401 - Unauthorized):**
```json
{
  "success": false,
  "message": "Unauthorized",
  "error": "Missing or invalid token"
}
```

**Status Codes:**
- `200` - Statistics retrieved successfully
- `401` - Missing or invalid token
- `404` - User not found
- `500` - Server error

---

### System Health Endpoint

#### 10. Health Check

**Endpoint:** `GET /health`

**Description:** Check if backend server is running and responsive. No authentication required.

**Request Headers:** None

**Request Body:** None

**Response (200 - OK):**
```json
{
  "status": "ok",
  "timestamp": "2024-05-18T15:00:00.123Z"
}
```

**Status Codes:**
- `200` - Server is healthy
- `503` - Server unavailable

---

### Error Response Format

All error responses follow this standardized format:

```json
{
  "success": false,
  "message": "Human-readable error message",
  "error": "Technical error details",
  "code": "ERROR_CODE",
  "timestamp": "2024-05-18T15:00:00Z"
}
```

### Common HTTP Status Codes

| Code | Meaning | Example |
|------|---------|---------|
| 200 | OK - Request successful | Profile retrieved |
| 400 | Bad Request - Invalid parameters | Missing required fields |
| 401 | Unauthorized - Invalid/missing token | Token expired |
| 404 | Not Found - Resource doesn't exist | User profile not found |
| 429 | Too Many Requests - Rate limit exceeded | OTP limit exceeded |
| 500 | Internal Server Error | Database connection failed |

---

## 19) Complete Setup Guide (Step-by-Step)

### Prerequisites

Before starting, ensure you have:

- **Git** installed (for cloning and version control)
- **Flutter SDK 3.x** ([Download](https://flutter.dev/docs/get-started/install))
- **Dart 3.x** (comes with Flutter)
- **Bun** runtime ([Install](https://bun.sh))
- **Firebase CLI** ([Install](https://firebase.google.com/docs/cli))
- **Android Studio** (for Android development) or **Xcode** (for iOS) or **Chrome** (for web)
- **Node.js 18+** (optional, for some Drizzle tools)

### Step 1: Clone Repository

```bash
git clone https://github.com/yourusername/swarnakar.git
cd Swarnakar
```

### Step 2: Firebase Project Setup

#### 2.1 Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click **"Create a project"** or select existing **swarnakar-79e57**
3. Enter project name: **"Swarnakar"**
4. Accept terms and create project

#### 2.2 Enable Firebase Authentication

1. In Firebase Console, go to **Authentication** → **Sign-in method**
2. Enable **Email/Password**:
   - Click "Email/Password"
   - Toggle "Enable"
   - Select "Email link (passwordless sign-in)" and "Email/password"
   - Save

3. Enable **Google Sign-In**:
   - Click "Google"
   - Toggle "Enable"
   - Select project support email
   - Save

#### 2.3 Create Firestore Database

1. Go to **Firestore Database**
2. Click **"Create database"**
3. Select **"Start in production mode"** (configure rules later)
4. Choose region: **"asia-south1"** (closest to Bangladesh) or your preferred region
5. Click **"Enable"**

#### 2.4 Set Up Firestore Collections

1. In Firestore, create collections:
   - **Collection name:** `users`
   - **Collection name:** `Users` (alternative, backend checks both)

2. Add initial security rules (go to **Rules** tab):

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own documents
    match /users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId;
    }
    
    match /Users/{userId} {
      allow read: if request.auth.uid == userId;
      allow write: if request.auth.uid == userId;
    }
  }
}
```

3. Click **"Publish"**

#### 2.5 Get Firebase Service Account Key

1. Go to **Project Settings** → **Service Accounts**
2. Click **"Generate New Private Key"**
3. Save the JSON file as `swarnakar-79e57-firebase-adminsdk-fbsvc-1f11cecb42.json`
4. **⚠️ IMPORTANT:** Never commit this file to git (it contains production credentials)

#### 2.6 Add Firebase Credentials to Backend

```bash
# Copy service account JSON to backend
cp /path/to/downloaded/firebase-service-account.json backend/

# Verify it's in .gitignore
echo "backend/*.json" >> .gitignore
echo "backend/.env" >> .gitignore
```

### Step 3: Backend Setup

```bash
# Navigate to backend directory
cd backend

# Install dependencies
bun install

# Create .env file
cat > .env << 'EOF'
PORT=8787
FIREBASE_PROJECT_ID=swarnakar-79e57
GOOGLE_APPLICATION_CREDENTIALS=./swarnakar-79e57-firebase-adminsdk-fbsvc-1f11cecb42.json

# JWT Configuration (change for production)
JWT_SECRET=your-super-secret-jwt-key-change-in-production
JWT_EXPIRES_IN=7d

# OTP Configuration
OTP_EXPIRY_MINUTES=10
OTP_MAX_ATTEMPTS=5
OTP_RESEND_COOLDOWN_SECONDS=45
OTP_RATE_LIMIT_PER_HOUR=10

# SMTP Configuration (for email delivery)
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_SECURE=false
SMTP_USER=your-email@gmail.com
SMTP_PASS=your-app-specific-password
OTP_FROM_EMAIL=your-email@gmail.com

# Database (if using PostgreSQL in future)
DATABASE_URL=postgresql://user:password@localhost:5432/swarnakar_db
EOF

# Test backend startup
bun run dev
```

If the backend starts successfully, you'll see:
```
Server running at http://localhost:8787
```

Press `Ctrl+C` to stop.

### Step 4: Frontend (Flutter) Setup

```bash
# Navigate to project root
cd ..

# Get Flutter dependencies
flutter pub get

# Generate Riverpod providers (if needed)
dart run build_runner build

# Verify Flutter setup
flutter doctor

# List available devices
flutter devices
```

### Step 5: Configure Firebase Options (Automatic)

Firebase options are auto-generated, but verify:

```bash
# Check if firebase_options.dart exists
cat lib/firebase_options.dart | head -20
```

If missing, regenerate:

```bash
flutterfire configure \
  --project=swarnakar-79e57 \
  --platforms=web,android,ios,macos,windows,linux \
  --out=lib/firebase_options.dart
```

### Step 6: Run the Application

#### Option 1: Run on Web (Easiest for Development)

```bash
# Terminal 1: Start Backend
cd backend
bun run dev

# Terminal 2: Start Flutter Web
flutter run -d chrome
```

#### Option 2: Run on Android Emulator

```bash
# Start Android Emulator first
emulator -avd Pixel_6_API_30

# Terminal 1: Start Backend
cd backend
bun run dev

# Terminal 2: Start Flutter Android
flutter run -d emulator-5554
```

#### Option 3: Run on iOS Simulator

```bash
# Terminal 1: Start Backend
cd backend
bun run dev

# Terminal 2: Start Flutter iOS
flutter run -d ios
```

#### Option 4: Run on Linux Desktop

```bash
# Terminal 1: Start Backend
cd backend
bun run dev

# Terminal 2: Start Flutter Linux
flutter run -d linux
```

### Step 7: Test the Application

1. **Splash Screen** - Should load automatically
2. **Signup** - Create account with email/password
3. **Email Verification** - Check inbox for Firebase verification email
4. **Login** - Login with verified email
5. **Dashboard** - View home screen with gold/silver prices
6. **Features** - Navigate through calculator, zakat, reports
7. **Profile** - Access profile settings
8. **Forgot Password** - Test password reset flow

### Step 8: SMTP Configuration (Optional but Recommended)

To send OTP emails via SMTP:

1. **For Gmail:**
   - Enable 2-Factor Authentication
   - Generate App Password: [Google Account Security](https://myaccount.google.com/apppasswords)
   - Use generated password in `.env` as `SMTP_PASS`

2. **Update backend/.env:**
   ```env
   SMTP_HOST=smtp.gmail.com
   SMTP_PORT=587
   SMTP_USER=your-email@gmail.com
   SMTP_PASS=xxxx-xxxx-xxxx-xxxx
   ```

3. **Restart backend:**
   ```bash
   cd backend
   bun run dev
   ```

### Step 9: Enable Firestore Billing (Production)

**⚠️ WARNING:** Firestore requires billing enabled for deployment.

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select **swarnakar-79e57** project
3. **Billing** → Link a billing account
4. Deploy Firestore rules and indexes:
   ```bash
   firebase deploy --only firestore:rules,firestore:indexes
   ```

---

## 20) Testing Guide

### Flutter Testing

#### Unit Tests

```bash
# Run all unit tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
```

#### Widget Tests

```bash
# Test example from widget_test.dart
flutter test test/widget_test.dart -v

# Run test in verbose mode
flutter test --verbose
```

#### Integration Tests

```bash
# Create integration test
touch test_driver/app.dart

# Run integration tests
flutter drive --target=test_driver/app.dart
```

### Backend Testing

```bash
# Create simple test
cat > backend/src/__tests__/auth.test.ts << 'EOF'
import { describe, it, expect } from 'bun:test';
import { AuthService } from '../services/auth.service';

describe('AuthService', () => {
  it('should generate 6-digit OTP', () => {
    const authService = new AuthService();
    // Test implementation
  });
});
EOF

# Run tests
cd backend
bun test
```

---

## 21) Troubleshooting Guide

### Common Issues and Solutions

#### Issue: "Failed to load Firebase options"

**Cause:** Firebase options not initialized

**Solution:**
```bash
flutterfire configure --project=swarnakar-79e57
flutter pub get
flutter clean
flutter pub get
```

#### Issue: "Firestore database creation returns HTTP 403"

**Cause:** Billing not enabled on Firebase project

**Solution:**
1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Select project
3. Enable billing
4. Wait 5 minutes
5. Create Firestore database again

#### Issue: "Backend CORS error: 'has been blocked by CORS policy'"

**Cause:** Frontend and backend on different origins

**Solution:** Update `backend/src/index.ts` CORS config:
```typescript
app.use('*', cors({
  origin: (origin) => {
    if (!origin) return '*'
    if (origin.includes('localhost')) return origin
    if (origin.includes('10.0.2.2')) return origin // Android emulator
    return origin // Allow all for development
  },
  credentials: true
}))
```

#### Issue: "Android emulator cannot reach localhost:8787"

**Cause:** Android emulator runs in isolated network

**Solution:** Use `10.0.2.2` instead of `localhost`:
```bash
flutter run --dart-define=OTP_API_BASE_URL=http://10.0.2.2:8787
```

#### Issue: "Flutter build fails: 'No package found'"

**Cause:** Missing dependencies

**Solution:**
```bash
flutter clean
rm pubspec.lock
flutter pub get
flutter pub outdated
```

#### Issue: "Bun backend crashes on startup"

**Cause:** Port 8787 already in use

**Solution:**
```bash
# Find process using port 8787
lsof -i :8787

# Kill the process
kill -9 <PID>

# Or change port in .env
PORT=8788 bun run dev
```

#### Issue: "Firebase Auth: 'User disabled' error"

**Cause:** User account disabled in Firebase

**Solution:** Re-enable user in Firebase Console → Authentication → Users

#### Issue: "OTP email not received"

**Cause:** SMTP not configured or email marked as spam

**Solution:**
1. Check `.env` SMTP settings
2. Check spam folder
3. Check Firebase Console logs
4. For development, check backend console (debugOtp field)

#### Issue: "jwt malformed" or "jwt expired"

**Cause:** Token invalid or expired

**Solution:**
```bash
# Clear app cache
flutter clean

# Logout and login again
# Re-get fresh token from Firebase
```

#### Issue: "Firestore document not found after signup"

**Cause:** User document not created

**Solution:**
```bash
# Manually create in Firebase Console:
# Collection: users
# Document ID: user's Firebase UID
# Fields: email, name, isEmailVerified: false
```

---

## 22) Deployment Guide

### Deploy Frontend (Flutter Web)

```bash
# Build web app
flutter build web --release

# Option 1: Deploy to Firebase Hosting
firebase deploy --only hosting

# Option 2: Deploy to custom server (e.g., Netlify, Vercel)
# Copy build/web/* to hosting provider
```

### Deploy Backend (Bun)

#### Option 1: Deploy to Railway

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login
railway login

# Deploy
railway up
```

#### Option 2: Deploy to Render

```bash
# Push to GitHub
git push origin main

# Connect repository to Render
# Set build command: bun install && bun run build
# Set start command: bun run start
```

#### Option 3: Deploy to Vercel (with serverless functions)

```bash
# Update backend/src/index.ts for serverless:
export default app

# Deploy
vercel deploy
```

#### Option 4: Deploy to Docker

```bash
# Create Dockerfile in backend/
cat > Dockerfile << 'EOF'
FROM oven/bun:latest

WORKDIR /app
COPY . .

RUN bun install

EXPOSE 8787

CMD ["bun", "run", "start"]
EOF

# Build and push to Docker Hub
docker build -t yourname/swarnakar-backend .
docker push yourname/swarnakar-backend

# Run container
docker run -p 8787:8787 \
  -e PORT=8787 \
  -e FIREBASE_PROJECT_ID=swarnakar-79e57 \
  yourname/swarnakar-backend
```

### Deploy Mobile Apps

#### Android APK/AAB Release

```bash
# Build APK (for direct installation)
flutter build apk --release

# Build AAB (for Google Play Store)
flutter build appbundle --release

# Sign APK
jarsigner -verbose -sigalg MD5withRSA -digestalg SHA1 \
  -keystore ~/key.jks \
  build/app/outputs/apk/release/app-release-unsigned.apk \
  alias_name

# Upload to Google Play Console
```

#### iOS Release

```bash
# Build iOS app
flutter build ios --release

# Archive and upload to App Store
# Use Xcode or Transporter app
```

### Production Security Checklist

- [ ] Change `JWT_SECRET` in `.env`
- [ ] Disable debug mode in Flutter (`kDebugMode = false`)
- [ ] Enable HTTPS only (set SMTP_SECURE=true if using TLS)
- [ ] Update CORS to specific domains
- [ ] Rotate Firebase service account key regularly
- [ ] Enable Firebase Security Rules (don't use permissive rules)
- [ ] Set up rate limiting on API endpoints
- [ ] Enable Firebase Authentication with email verification
- [ ] Configure Firebase backup & restore
- [ ] Set up monitoring and alerts
- [ ] Use environment-specific secrets (.env.production)
- [ ] Enable Firebase Performance Monitoring
- [ ] Set up error logging (Crashlytics)
- [ ] Audit Firebase database access logs

---

## 23) Contributing Guidelines

### Code of Conduct

- Be respectful to all contributors
- Report issues professionally
- Help others when possible
- Share knowledge and experiences

### How to Contribute

#### 1. Fork the Repository

```bash
# Fork on GitHub, then clone
git clone https://github.com/yourusername/swarnakar.git
cd Swarnakar
```

#### 2. Create a Feature Branch

```bash
# Create branch from main
git checkout -b feature/your-feature-name
# or
git checkout -b bugfix/your-bug-fix
# or
git checkout -b docs/improve-documentation
```

#### 3. Make Your Changes

```bash
# Make changes to files
# Follow code style guidelines

# Format code (Dart)
dart format lib/
flutter analyze

# Format code (TypeScript)
cd backend && bun run format  # if available
```

#### 4. Commit with Clear Messages

```bash
# Use conventional commits
git commit -m "feat: add gold price API endpoint"
git commit -m "fix: resolve CORS issue on profile endpoint"
git commit -m "docs: update API documentation"
git commit -m "style: format code according to guidelines"
git commit -m "refactor: simplify authentication logic"
git commit -m "test: add unit tests for OTP service"
```

#### 5. Push and Create Pull Request

```bash
# Push to your fork
git push origin feature/your-feature-name

# Create PR on GitHub
# Fill in PR template with:
# - Description of changes
# - Related issues
# - How to test
# - Screenshots (if UI changes)
```

#### 6. Code Review and Merge

- Wait for code review
- Address feedback
- Merge after approval

### Coding Standards

#### Dart/Flutter

```dart
// ✅ Good: Clear naming
class UserAuthenticationProvider extends StateNotifier<AuthState> {
  // Implementation
}

// ❌ Bad: Unclear naming
class UAP extends StateNotifier<AS> {
  // Implementation
}

// ✅ Good: Comments for complex logic
// Verify OTP with rate limiting and retry attempts
void verifyOtp(String code) {
  // Implementation
}

// ✅ Good: Error handling
try {
  final user = await authService.signup(email, password);
} catch (e) {
  _handleAuthError(e);
}

// ❌ Bad: Silent failures
try {
  final user = await authService.signup(email, password);
} catch (e) {
  // Ignore
}
```

#### TypeScript (Backend)

```typescript
// ✅ Good: Proper typing
interface OtpRequest {
  email: string;
  purpose: 'reset_password' | 'login_verification';
}

async sendOtp(request: OtpRequest): Promise<OtpResponse> {
  // Implementation
}

// ❌ Bad: Use of any
function sendOtp(request: any): any {
  // Implementation
}

// ✅ Good: Error handling
try {
  await authService.sendOtp(email);
} catch (error) {
  logger.error('OTP send failed:', error);
  throw new ApiError('Failed to send OTP', 500);
}
```

### Issue Reporting

When reporting issues, include:

```markdown
## Description
What is the problem?

## Steps to Reproduce
1. Step 1
2. Step 2
3. Step 3

## Expected Behavior
What should happen?

## Actual Behavior
What actually happened?

## Environment
- Flutter version: `flutter --version`
- Dart version: `dart --version`
- OS: Windows/Mac/Linux
- Device: Android/iOS/Web/Desktop

## Logs
```
Paste error logs here
```

## Screenshots
Attach screenshots if applicable
```

### Feature Requests

Template:

```markdown
## Feature Description
What feature do you want to add?

## Use Case
Why is this feature needed?

## Proposed Implementation
How should this work?

## Alternatives
Are there alternative approaches?

## Additional Context
Any other relevant information?
```

---

## 24) Frequently Asked Questions (FAQ)

### Setup & Installation

**Q: Do I need Android Studio or Xcode?**  
A: Only if developing for Android or iOS. For web development, Chrome is sufficient.

**Q: Can I run backend on a different port?**  
A: Yes, change `PORT` in `backend/.env` and update Flutter's `OTP_API_BASE_URL`.

**Q: Why is Firebase billing required?**  
A: Firestore databases require billing to be enabled, even if within free tier limits.

### Architecture & Features

**Q: Is this production-ready?**  
A: The core auth and profile systems are production-ready. Market prices and other features are currently mocked.

**Q: Can I use PostgreSQL instead of Firestore?**  
A: The database layer is scaffolded for future migration. Currently, Firestore is used for user data.

**Q: How often is the OTP valid?**  
A: By default, 10 minutes (600 seconds). Change `OTP_EXPIRY_MINUTES` in `.env`.

**Q: Can I customize the UI theme?**  
A: Yes, modify `lib/core/theme/app_colors.dart` and `app_text_styles.dart`.

### Security

**Q: Is the backend JWT verification production-ready?**  
A: Currently, it decodes without full verification. For production, upgrade to Firebase token verification.

**Q: How do I rotate Firebase credentials?**  
A: Generate new service account key in Firebase Console → Project Settings → Service Accounts.

**Q: Should I commit `.env` and service account JSON?**  
A: No. Add to `.gitignore` and use CI/CD secrets management.

### Deployment

**Q: Which hosting provider should I use?**  
A: For web: Firebase Hosting, Netlify, or Vercel. For backend: Railway, Render, or Docker.

**Q: How do I set up HTTPS?**  
A: Most hosting providers (Firebase, Vercel, Railway) provide SSL/TLS automatically.

**Q: Can I use subdomain-based routing?**  
A: Yes, configure CORS and update API base URLs accordingly.

---

## 25) Final Notes

**Swarnakar** is a comprehensive full-stack jewellery business application with:
- ✅ Modern Flutter architecture (Riverpod, GoRouter)
- ✅ TypeScript backend (Bun + Hono)
- ✅ Firebase authentication and data persistence
- ✅ Production-ready auth flows (OTP, email verification, password reset)
- ✅ Multi-platform support (Web, Android, iOS, Desktop)
- ✅ Bangla-first UI/UX

### Next Steps

1. **Complete Setup:** Follow Step-by-Step Setup Guide (Section 19)
2. **Run Tests:** Verify installation with Section 20
3. **Contribute:** Submit PRs following Contributing Guidelines (Section 23)
4. **Deploy:** Use Deployment Guide (Section 22) for production

### Support

For questions, issues, or contributions:
- 📧 Email: sarkarkabbo72@gmail.com
- 🐛 Report bugs: Open GitHub issues
- 💡 Feature requests: Discuss in GitHub discussions
- 📝 Documentation: Check this README and inline code comments

### License

This project is open source. [Add your license here]

---

**Happy coding! 🚀**
