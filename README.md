# flutter-boilerplate

![Flutter](https://img.shields.io/badge/Flutter-3.29.0-02569B?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.7.0-0175C2?logo=dart)
![Platforms](https://img.shields.io/badge/platforms-iOS%20%26%20Android-lightgrey)
![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)
[![CI](https://github.com/aks5686/flutter-boilerplate/actions/workflows/flutter.yml/badge.svg)](https://github.com/aks5686/flutter-boilerplate/actions/workflows/flutter.yml)

Production-ready Flutter boilerplate with Clean Architecture, BLoC, Dart, GoRouter and GitHub Actions CI/CD.

## Getting Started

1. Click **[Use this template](https://github.com/aks5686/flutter-boilerplate/generate)** on GitHub.
2. Clone your repo locally:
   ```bash
   git clone https://github.com/<your-org>/<your-repo>.git
   cd <your-repo>
   ```
3. Run
   ```bash
   ./setup.sh YourAppName
   ```
4. Run
   ```bash
   flutter pub get
   ```
5. Run
   ```bash
   flutter run
   ```

Requirements:
- Flutter 3.29.0 (see `.metadata` / CI workflow for the pinned version)
- Dart SDK ^3.7.0

### Configuring the API base URL

The base URL is injected at build/run time via a Dart define, defaulting to a placeholder:

```bash
flutter run --dart-define=API_BASE_URL=https://api.yourapp.com
```

## Architecture

This project follows **Clean Architecture** with a **feature-first** folder structure. Each feature is sliced into three layers:

- **`domain/`** — Business rules and contracts (use cases, repository interfaces). Has no dependency on Flutter or any external package.
- **`data/`** — Concrete implementations of the domain's repository interfaces, talking to the network client and local storage.
- **`presentation/`** — BLoC/Cubit state management plus the Flutter widgets that render that state.

Dependencies always point inward: `presentation → domain ← data`. The domain layer never imports from `data` or `presentation`.

State management is done exclusively with **BLoC/Cubit** (`flutter_bloc`) — no Provider, no Riverpod. Cubits expose a sealed `State` hierarchy (via `equatable`) and are provided to the widget tree with `BlocProvider`/`BlocConsumer`.

Navigation is handled by **GoRouter**, with a single `redirect` callback in `AppRouter` used for auth gating, so individual screens don't need to reimplement that logic.

Dependencies are wired manually through **`get_it`** in `lib/di/app_module.dart`. There is no code generation step — every registration is an explicit, readable line, which keeps the DI graph easy to audit and to override in tests.

## Folder Structure

```
lib/
├── core/                     # Cross-cutting, feature-agnostic code
│   ├── network/
│   │   ├── network_client.dart   # Dio wrapper: interceptors, timeouts, typed errors
│   │   └── api_error.dart        # Sealed ApiError hierarchy
│   ├── storage/
│   │   └── secure_storage.dart   # flutter_secure_storage wrapper for tokens
│   └── extensions/
│       ├── string_extensions.dart
│       └── context_extensions.dart
├── design_system/            # Design tokens, no business logic
│   ├── app_colors.dart
│   ├── app_typography.dart
│   └── app_spacing.dart
├── di/
│   └── app_module.dart       # Manual DI container (get_it)
├── navigation/
│   └── app_router.dart       # GoRouter configuration + auth redirect
├── features/
│   └── auth/
│       ├── domain/
│       │   └── auth_use_case.dart      # AuthRepository contract + AuthUseCase
│       ├── data/
│       │   └── auth_repository.dart    # AuthRepository implementation
│       └── presentation/
│           ├── login_cubit.dart
│           ├── login_state.dart
│           └── login_screen.dart
└── main.dart
```

Adding a new feature means creating a new folder under `lib/features/<feature_name>/` with the same three-layer split, then registering its dependencies in `AppModule` and its routes in `AppRouter`.

## Features

- **Clean Architecture** — feature-first, three-layer (`domain`/`data`/`presentation`) structure with dependencies pointing inward.
- **BLoC/Cubit state management** — sealed state hierarchies via `equatable`, no Provider or Riverpod.
- **GoRouter navigation** — centralized route table with auth-gating `redirect` logic.
- **Manual dependency injection** — explicit, readable `get_it` registrations in `AppModule`, no code generation.
- **Networking** — a typed `Dio` wrapper (`NetworkClient`) that normalizes errors into sealed `ApiError` subclasses.
- **Secure storage** — a `flutter_secure_storage` wrapper (`SecureStorage`) for persisting auth tokens.
- **Design system tokens** — centralized colors, typography, and spacing so UI code never hardcodes values.
- **Sample auth flow** — a login screen with basic validation and a home screen, wired end-to-end through BLoC and GoRouter.
- **`setup.sh`** — a one-command script to rename the project (package name, Android application ID, iOS bundle ID) to your new app.
- **CI/CD** — GitHub Actions workflow that runs analysis, formatting checks, tests, and release builds for Android and iOS.

## Usage Guide

### Adding a new feature

1. Define the domain contract and use case in `lib/features/<feature>/domain/`.
2. Implement the repository in `lib/features/<feature>/data/`, depending on `NetworkClient` and/or `SecureStorage` as needed.
3. Create a Cubit + sealed state in `lib/features/<feature>/presentation/`.
4. Register the use case/repository in `lib/di/app_module.dart`.
5. Add the screen's route to `lib/navigation/app_router.dart`.

### Networking

```dart
final networkClient = AppModule.instance.networkClient;

final profile = await networkClient.get<Map<String, dynamic>>(
  '/users/me',
  decoder: (data) => data as Map<String, dynamic>,
);
```

Errors are automatically normalized into typed `ApiError` subclasses (`UnauthorizedError`, `ServerError`, `NoInternetError`, etc.) so calling code can `catch` on a specific error type rather than parsing status codes.

### Secure Storage

```dart
final secureStorage = AppModule.instance.secureStorage;

await secureStorage.writeAccessToken(accessToken);
final token = await secureStorage.readAccessToken();
await secureStorage.clearAll(); // e.g. on logout
```

`SecureStorage` wraps `flutter_secure_storage` and is the single place tokens are read from and written to — `AppRouter`'s auth `redirect` reads through this same interface to decide whether a user is signed in.

### Testing

```bash
flutter test
```

Widget tests live in `test/`. The existing `test/widget_test.dart` mocks the secure storage platform channel and exercises the full login → home navigation flow, so new features should follow the same pattern: fake platform channels and external I/O, and drive the UI through the same `BlocProvider`/`GoRouter` setup used at runtime.

### Static analysis & formatting

```bash
flutter analyze
dart format --output=none --set-exit-if-changed .
```

Both commands are enforced in CI (`.github/workflows/flutter.yml`) alongside `flutter test` and release builds for Android and iOS.

## CI/CD

GitHub Actions (`.github/workflows/flutter.yml`) runs on every push and pull request to `main`:

1. **Analyze** — `dart format --set-exit-if-changed` and `flutter analyze --fatal-warnings`.
2. **Test** — `flutter test --coverage`, with the coverage report uploaded as a build artifact.
3. **Build Android** — accepts SDK licenses, installs the pinned NDK, and builds a release APK.
4. **Build iOS** — builds a release, unsigned iOS binary on macOS runners.

## License

MIT — see [LICENSE](LICENSE).
