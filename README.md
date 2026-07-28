# flutter-boilerplate

![Flutter](https://img.shields.io/badge/Flutter-3.29.0-02569B?logo=flutter)
![Architecture](https://img.shields.io/badge/architecture-Clean%20Architecture-informational)
![State Management](https://img.shields.io/badge/state-BLoC%2FCubit-purple)
![License](https://img.shields.io/badge/license-MIT-blue.svg)
[![Flutter CI/CD](https://github.com/aks5686/flutter-boilerplate/actions/workflows/flutter.yml/badge.svg)](https://github.com/aks5686/flutter-boilerplate/actions/workflows/flutter.yml)

A production-ready Flutter architecture boilerplate built with **Clean Architecture**, **BLoC/Cubit**, **GoRouter**, and manual dependency injection via **get_it**. Use it as the starting point for a new app instead of wiring the same foundation from scratch every time.

## Getting Started

Click **[Use this template](https://github.com/aks5686/flutter-boilerplate/generate)** to create your own repository from this boilerplate.

Then, locally:

```bash
git clone https://github.com/<your-org>/<your-repo>.git
cd <your-repo>
flutter pub get
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

## Usage Guide

### Adding a new feature

1. Define the domain contract and use case in `lib/features/<feature>/domain/`.
2. Implement the repository in `lib/features/<feature>/data/`, depending on `NetworkClient` and/or `SecureStorage` as needed.
3. Create a Cubit + sealed state in `lib/features/<feature>/presentation/`.
4. Register the use case/repository in `lib/di/app_module.dart`.
5. Add the screen's route to `lib/navigation/app_router.dart`.

### Calling the network client

```dart
final networkClient = AppModule.instance.networkClient;

final profile = await networkClient.get<Map<String, dynamic>>(
  '/users/me',
  decoder: (data) => data as Map<String, dynamic>,
);
```

Errors are automatically normalized into typed `ApiError` subclasses (`UnauthorizedError`, `ServerError`, `NoInternetError`, etc.) so calling code can `catch` on a specific error type rather than parsing status codes.

### Running tests

```bash
flutter test
```

### Static analysis & formatting

```bash
flutter analyze
dart format --output=none --set-exit-if-changed .
```

Both commands are enforced in CI (`.github/workflows/flutter.yml`) alongside `flutter test` and release builds for Android and iOS.

## License

MIT — see [LICENSE](LICENSE).
