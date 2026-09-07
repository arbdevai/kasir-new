# Kasir New

Base Flutter shell for **Kasir New**, an offline-first point-of-sale application for Android phones and tablets. The current build establishes the project foundation, visual language, responsive navigation, and route boundaries described in `PRD.md`; feature modules will be implemented incrementally.

## Requirements

- Flutter stable (3.35 or newer)
- Dart 3.8 or newer
- Android SDK configured through Android Studio or the Flutter toolchain

## Local setup

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

To run on an Android device or emulator:

```bash
flutter devices
flutter run -d <device-id>
```

## Project structure

- `lib/main.dart` — application entry point and Riverpod scope.
- `lib/src/app/` — app widget and `go_router` navigation configuration.
- `lib/src/features/` — feature-owned presentation shells for POS, history, products, reports, and settings.
- `lib/src/theme/` — shared orange-accent design tokens and Material 3 theme.
- `assets/images/` and `assets/icons/` — reserved for product imagery, QRIS, and branding assets.
- `.github/workflows/build-apk.yml` — stable Flutter CI workflow that analyzes, tests, and builds debug/release APKs.

## Navigation shell

Phone layouts use a bottom navigation bar. Tablet layouts (768 logical pixels and wider) use a navigation rail and expanded content area. Routes are named and isolated in `lib/src/app/app_router.dart` so each feature can add nested routes without changing the app entry point.

## Adding features

Keep domain, data, and presentation code within the owning `lib/src/features/<feature>/` directory. Add dependencies only when needed, then run `flutter pub get`, `flutter analyze`, and `flutter test` before opening a pull request. Database, printer, and backup integrations should remain behind feature/data abstractions so the shell stays usable offline.
