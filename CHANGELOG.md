# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

## [3.0.0] - 2026-10-06

### Added
- All 5 Syzygy layers declared as dependencies at v3.0.0 (Foundation, Core, Services, AI, UI)
- Core DI Container wiring for Logger, HttpNetworkClient, TokenAuthProvider, InMemoryStorageProvider, EventBus, DefaultScheduler, InMemoryFeatureFlagProvider, ConfigRegistry, AppLifecycleTracker, Router
- SyzygyThemeProvider wrapping the app root via MaterialApp.builder
- Hub reusable CI workflow (flutter-ci.yml@main) with Flutter 3.35.0
- analysis_options.yaml lint configuration
- syzygy.yml layer manifest

### Changed
- Package name renamed from boilerplate to syzygy_base
- Bundle ID renamed from com.aks.boilerplate to com.syzygyhub.base
- App display name renamed from Boilerplate to SyzygyBase
- Version set to 3.0.0+1
- SDK constraints updated to >=3.9.0 <4.0.0 / Flutter >=3.35.0
- AppConstants.appName updated to 'SyzygyBase'
- LoginCubit updated to use TokenAuthProvider instead of local SecureStorage
- LoginScreen updated to resolve TokenAuthProvider from appContainer
- AppRouter.redirect updated to check TokenAuthProvider.state
- home_screen.dart and login_screen.dart updated to use AppSpacing from syzygy_ui_flutter

### Removed
- Inline CI workflow (flutter.yml) replaced by Hub reusable workflow
- Local shadow copies of NetworkClient, ApiError, SecureStorage, AppColors, AppSpacing, AppTypography
- get_it, dio, flutter_secure_storage replaced by Syzygy layer equivalents
- Hand-rolled get_it DI replaced by Core DI Container
- Unconditional debugLogDiagnostics in app_router.dart
- Incorrect *.lock rule from .gitignore
