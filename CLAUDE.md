# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

SLF Drive — multi-role (customer + driver) car rental platform built with Flutter for Android, iOS, and Web. Responsive-first: the same screens adapt across mobile/tablet/desktop rather than being constrained to mobile size on web.

## Common commands

Secrets must be present before building. On a fresh clone:

```sh
cp .env.example .env
cp android/secrets.properties.example android/secrets.properties
cp ios/Flutter/Secrets.xcconfig.example ios/Flutter/Secrets.xcconfig
```

Dart-side secrets (currently `GOOGLE_MAPS_API_KEY`) are compile-time defines loaded from `.env`, so `--dart-define-from-file=.env` is required for `run` and `build` on web:

```sh
flutter pub get
flutter run -d chrome --dart-define-from-file=.env     # web
flutter run                                            # iOS/Android (reads native secrets)
flutter build web --dart-define-from-file=.env
flutter analyze
flutter test
flutter test test/path/to/file_test.dart --plain-name "name of test"
```

## Architecture

Clean Architecture with Provider state management and `get_it` service locator. Layers live under `lib/src/`:

- `constants/` — colors, endpoints, `breakpoints.dart` (mobile 600 / tablet 900 / desktop 1200 / largeDesktop 1600), asset path constants.
- `core/`
  - `data/datasources/` + `data/repositories/` — remote data sources and repository implementations (abstract + impl).
  - `network/` — Dio-based `api_client.dart` with `auth_interceptor.dart` handling bearer tokens + 401 refresh.
  - `di/injection_container.dart` — `setupDependencyInjection()` registers singletons via `getIt`. Currently minimal (secure storage only); new services/repos/providers register here.
  - `secrets/` — `app_secrets.dart` reads `String.fromEnvironment(...)` defines; `maps_loader.dart` has conditional imports (`maps_loader_web.dart` vs `maps_loader_stub.dart`) to inject the Google Maps JS SDK at runtime on web only.
- `presentation/`
  - `providers/` — `ChangeNotifier`s (theme, language).
  - `routes/app_router.dart` — single `GoRouter` with custom `AppPageTransition` (shared-axis Z) and `AppModalTransition` (slide-up). Route params passed via `state.extra` typed maps.
  - `screens/` — split by role: `customer/`, `driver/`, plus `common/` (auth, onboarding, splash), `language/`, `web/`.
  - `widgets/responsive/` — responsive primitives used across screens.
  - `theme/app_theme.dart` — light/dark themes parameterized by font family.

Entry point `lib/main.dart`: initializes `EasyLocalization`, fires `ensureGoogleMapsLoaded()` (web no-op elsewhere), locks to portrait, then runs `MaterialApp.router` wrapped in `ScreenUtilInit(designSize: Size(390, 844))`.

### Responsive conventions

- **Mobile sizing uses `.r` only** (via `flutter_screenutil`) — not `.sp`, `.w`, or `.h`. Tablet/desktop layouts use hardcoded pixel values inside `LayoutBuilder` branches.
- Screens that need distinct desktop/tablet treatments branch on `constraints.maxWidth` against `Breakpoints` rather than scaling a single mobile layout. See `RESPONSIVE_DESIGN_GUIDE.md`.

### Localization

Seven locales under `assets/translations/` (en-US, ar-AE, hi-IN, ur-PK, de-DE, es-ES, ru-RU). Font family switches to `Tajawal` for `ar`/`ur`, `OpenSans` otherwise (see `MyApp._getFontFamily` in `main.dart`). Use `'key'.tr()` — every new user-facing string must be added to all seven JSON files.

### Secrets

Three per-platform secret files, all gitignored; only `.example` templates are committed. See `SECRETS.md` for how Android (`secrets.properties` → Gradle `manifestPlaceholders`), iOS (`Secrets.xcconfig` → `Info.plist` → `AppDelegate.swift`), and Web (`--dart-define-from-file=.env` → `AppSecrets` → runtime `<script>` injection) each consume the same keys. Never inline API keys into `web/index.html`, `AndroidManifest.xml`, or `Info.plist` — always go through the placeholder.

### Navigation

All routing is declarative via `AppRouter.router`. Detail screens (`/cars/:id`, `/drivers/:id`, `/bookings/:id`, notifications, search, booking flow) use `AppModalTransition`; list/home/auth screens use `AppPageTransition`; splash/language/onboarding use `AppFadeThroughTransition`. Pass complex arguments through `state.extra` as a typed `Map<String, dynamic>`.

## Reference documents

`ARCHITECTURE_GUIDE.md` contains the full SLF Drive spec (roles, API endpoints, data models). `RESPONSIVE_DESIGN_GUIDE.md` documents the LayoutBuilder pattern and per-screen breakpoint behavior. `SECRETS.md` is the source of truth for secret handling.
