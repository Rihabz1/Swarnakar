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

## 17) Final Notes

Swarnakar already provides a strong product-oriented foundation with modern Flutter architecture and practical backend integration.
The fastest path to production quality is to finish backend module wiring, replace mock data sources with APIs, and harden auth/security edges.

If you want, the next README update can include architecture diagrams, API request/response payload tables for every endpoint, and a full contributor onboarding checklist.
