[![Flutter](https://img.shields.io/badge/Flutter-Dart-7F77DD?style=flat)](https://flutter.dev/) [![Dart](https://img.shields.io/badge/Dart-3.0-1D9E75?logo=dart&logoColor=white&style=flat)](https://dart.dev) [![CI](https://img.shields.io/github/actions/workflow/status/Syzygy-Hub/syzygy-base-flutter/ci.yml?label=ci&style=flat)](https://github.com/Syzygy-Hub/syzygy-base-flutter/actions/workflows/ci.yml) [![Version](https://img.shields.io/badge/version-3.0.0-D85A30?style=flat)](https://github.com/Syzygy-Hub/syzygy-base-flutter/releases) [![License](https://img.shields.io/badge/License-MIT-green?style=flat)](LICENSE)

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/Syzygy-Hub/.github/main/brand/assets/banners/syzygy-banner-dark-1200.png">
  <img src="https://raw.githubusercontent.com/Syzygy-Hub/.github/main/brand/assets/banners/syzygy-banner-light-1200.png" alt="Syzygy" width="600">
</picture>

# syzygy-base-flutter

A template Flutter app (Dart) that wires all 5 Syzygy layers via the Core DI Container.

## About

syzygy-base-flutter is the starting point for any Syzygy-based mobile application. It ships with all 5 Syzygy layers pre-wired through Core's DI Container, a GoRouter navigation setup with an auth guard, and a SyzygyThemeProvider applied via `MaterialApp.builder`. Clone the repo, run `setup.sh` with your app name and bundle ID, and your project is ready to build on.

## Platforms

| Platform | Version | Status |
|---|---|---|
| iOS | 16.0+ | ✅ Supported |
| Android | 8.0+ (API 26) | ✅ Supported |

## Requirements

- Flutter 3.35.0+
- Dart 3.0+
- iOS 16.0+ / Android API 26+
- Xcode 16+ (iOS builds)
- Android Studio (Android builds)

## Installation

1. Clone this repo:
   ```sh
   git clone https://github.com/Syzygy-Hub/syzygy-base-flutter.git
   ```
2. Rename the project to your app:
   ```sh
   ./setup.sh YourAppName com.your.bundle
   ```
3. Fetch dependencies:
   ```sh
   flutter pub get
   ```
4. Run the app:
   ```sh
   flutter run
   ```

## Architecture

syzygy-base-flutter depends on all 5 Syzygy layers via pub.dev. Each layer is pinned at `^3.0.0` in `pubspec.yaml`:

```yaml
dependencies:
  syzygy_foundation: ^3.0.0
  syzygy_core: ^3.0.0
  syzygy_services: ^3.0.0
  syzygy_ai: ^3.0.0
  syzygy_ui: ^3.0.0
```

**DI wiring** lives in `lib/di/`. Call `initDI()` before `runApp` to register all singletons into the Core Container.

**Entry point:** `lib/main.dart`

**Navigation:** GoRouter configured in `lib/navigation/`, with an auth guard that checks `TokenAuthProvider.state` to gate the home screen.

## Contents

```
lib/
├── core/           # App-level abstractions and base classes
├── design_system/  # Design tokens and component overrides
├── di/             # DI container setup and module registration
├── features/       # Feature folders (add your screens here)
├── navigation/     # GoRouter configuration and route definitions
├── network/        # Network client configuration
├── storage/        # Storage provider setup
├── theme/          # SyzygyThemeProvider integration
└── utils/          # Shared utility functions
```

## Usage

### Accessing the DI container

```dart
// Resolve a registered singleton anywhere in the app
final logger = appContainer.resolve<Logger>();
final auth = appContainer.resolve<TokenAuthProvider>();
```

### Applying the theme

`SyzygyThemeProvider` wraps the widget tree via `MaterialApp.builder`:

```dart
MaterialApp.router(
  builder: (context, child) => SyzygyThemeProvider(
    theme: SyzygyTheme.defaultTheme,
    child: child!,
  ),
  ...
)
```

Access the current theme anywhere in the tree:

```dart
final theme = SyzygyThemeProvider.of(context);
```

## Contributing

Open a pull request against `main`. All branches run CI via the shared Hub reusable workflow. Follow the existing code style and ensure `flutter analyze` passes before requesting review.

## Releases

See [CHANGELOG.md](CHANGELOG.md) for release history. Releases are tagged and published to GitHub Releases.

## License

MIT — see [LICENSE](LICENSE) for details.
