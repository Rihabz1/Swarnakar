# Swarnakar

Swarnakar is a Flutter application for jewellery businesses in Bangladesh. It focuses on daily price tracking, business calculations, customer/account flows, and a premium-style UI built around gold-accented visuals.

This repository currently contains two parts:

- A Flutter client app that is actively structured and wired up.
- A backend folder that is scaffolded in TypeScript but not yet implemented.

## What The App Does

The Flutter app is designed to help with the everyday workflows of a jewellery business:

- View gold and silver price screens.
- Run quick jewellery-related calculations.
- Estimate zakat-related values.
- Browse filtered reports.
- Sign up, log in, and verify OTP-based access.
- Move through the app with a dashboard and bottom navigation.
- Support a premium or paywall-style experience.

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

- `/` opens the splash screen.
- `/login` opens the login screen.
- `/signup` opens the signup screen.
- `/otp` opens OTP verification and reads the `email` query parameter.
- `/dashboard` opens the main dashboard.
- `/gold-price` opens the gold price screen.
- `/silver-price` opens the silver price screen.
- `/calculator` opens the calculator screen.
- `/zakat` opens the zakat screen.
- `/paywall` opens the subscription or premium screen.
- `/reports` opens the reports screen.
- `/settings` opens the settings screen.

## Main Features

### Authentication

The auth flow includes login, signup, and OTP verification screens. The signup screen validates required fields, email format, whitespace in credentials, password length, and password confirmation.

Key files:

- [lib/features/auth/presentation/login_screen.dart](lib/features/auth/presentation/login_screen.dart)
- [lib/features/auth/presentation/signup_screen.dart](lib/features/auth/presentation/signup_screen.dart)
- [lib/features/auth/presentation/otp_screen.dart](lib/features/auth/presentation/otp_screen.dart)
- [lib/core/providers/core_providers.dart](lib/core/providers/core_providers.dart)

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

## Technology Stack

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

## Backend Status

The [backend/](backend/) folder is present, but the current implementation files are empty. That means the backend is best treated as a scaffold for future API work rather than a live API service right now.

Current backend structure includes:

- `backend/src/routes/`
- `backend/src/controllers/`
- `backend/src/services/`
- `backend/src/middleware/`
- `backend/src/db/`

If you want to turn the backend into a working API later, the README should be extended with the actual server start command, environment variables, database setup, and endpoint documentation once those files are implemented.

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
