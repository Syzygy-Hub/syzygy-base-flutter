import 'package:get_it/get_it.dart';

import '../core/network/network_client.dart';
import '../core/storage/secure_storage.dart';
import '../features/auth/data/auth_repository.dart';
import '../features/auth/domain/auth_use_case.dart';

/// Manual dependency injection container built on [GetIt].
///
/// Centralizing registrations here (rather than scattering `GetIt.I`
/// look-ups) keeps the wiring explicit and makes it easy to swap
/// implementations for tests via [AppModule.reset] + [AppModule.init]
/// with overrides.
class AppModule {
  AppModule._();

  static final AppModule instance = AppModule._();

  final GetIt _getIt = GetIt.instance;

  bool _isInitialized = false;

  /// Registers all app-wide singletons and factories. Call once during
  /// `main()`, before `runApp`.
  Future<void> init({
    required String apiBaseUrl,
    bool enableNetworkLogging = false,
  }) async {
    if (_isInitialized) return;

    _getIt.registerLazySingleton<SecureStorage>(() => SecureStorageImpl());

    _getIt.registerLazySingleton<NetworkClient>(
      () => NetworkClient(
        baseUrl: apiBaseUrl,
        secureStorage: _getIt<SecureStorage>(),
        enableLogging: enableNetworkLogging,
      ),
    );

    _getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(
        networkClient: _getIt<NetworkClient>(),
        secureStorage: _getIt<SecureStorage>(),
      ),
    );

    _getIt.registerLazySingleton<AuthUseCase>(
      () => AuthUseCase(_getIt<AuthRepository>()),
    );

    _isInitialized = true;
  }

  /// Unregisters everything. Intended for use between tests.
  Future<void> reset() async {
    await _getIt.reset();
    _isInitialized = false;
  }

  SecureStorage get secureStorage => _getIt<SecureStorage>();
  NetworkClient get networkClient => _getIt<NetworkClient>();
  AuthRepository get authRepository => _getIt<AuthRepository>();
  AuthUseCase get authUseCase => _getIt<AuthUseCase>();
}
