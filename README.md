# Kasir New

Offline-first point-of-sale application for Android phones and tablets. The active build provides a responsive dashboard, POS catalog and cart, inventory, reports, settings, and shift workflows.

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

- `lib/main.dart` — application entry point and stable `MaterialApp`.
- `lib/screens/` — active dashboard, POS, products, reports, settings, and navigation shell screens.
- `lib/state/pos_state.dart` — observable in-memory POS state and business operations.
- `lib/models/models.dart` — active UI/domain models.
- `lib/theme/` and `lib/widgets/` — shared Material 3 theme, design tokens, and reusable widgets.
- `lib/src/domain/` and `lib/kasir_services.dart` — service contracts and independently tested domain/service models.
- `assets/images/` and `assets/icons/` — reserved for product imagery, QRIS, and branding assets.
- `.github/workflows/build-apk.yml` — stable Flutter CI workflow that analyzes, tests, and builds debug/release APKs.

## Navigation shell

Phone layouts use a bottom navigation bar. Tablet layouts (780 logical pixels and wider) use a responsive sidebar with indexed view switching to maintain ephemeral state. Feature modules map cleanly to `lib/screens/` and `lib/state/pos_state.dart`.

## Adding features

Keep feature screens and widgets within `lib/screens/` and `lib/widgets/`. Shared domain and backend service models reside in `lib/models/` and `lib/src/domain/`. Add dependencies only when needed, then run `flutter pub get`, `flutter analyze`, and `flutter test` before opening a pull request. Database, printer, and backup integrations should remain behind feature/data abstractions so the shell stays usable offline.
