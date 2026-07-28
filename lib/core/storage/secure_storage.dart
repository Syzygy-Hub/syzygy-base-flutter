import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Thin wrapper around [FlutterSecureStorage] scoped to the auth tokens and
/// other sensitive values the app needs to persist.
///
/// Kept as an interface + implementation so it can be swapped for an
/// in-memory fake in tests without touching platform channels.
abstract interface class SecureStorage {
  Future<void> writeAccessToken(String token);
  Future<String?> readAccessToken();

  Future<void> writeRefreshToken(String token);
  Future<String?> readRefreshToken();

  Future<void> write(String key, String value);
  Future<String?> read(String key);
  Future<void> delete(String key);

  /// Clears all values written through this storage, e.g. on logout.
  Future<void> clearAll();
}

class SecureStorageImpl implements SecureStorage {
  SecureStorageImpl({FlutterSecureStorage? storage})
    : _storage =
          storage ??
          const FlutterSecureStorage(
            aOptions: AndroidOptions(encryptedSharedPreferences: true),
            iOptions: IOSOptions(
              accessibility: KeychainAccessibility.first_unlock_this_device,
            ),
          );

  final FlutterSecureStorage _storage;

  static const _accessTokenKey = 'auth.access_token';
  static const _refreshTokenKey = 'auth.refresh_token';

  @override
  Future<void> writeAccessToken(String token) => write(_accessTokenKey, token);

  @override
  Future<String?> readAccessToken() => read(_accessTokenKey);

  @override
  Future<void> writeRefreshToken(String token) =>
      write(_refreshTokenKey, token);

  @override
  Future<String?> readRefreshToken() => read(_refreshTokenKey);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);

  @override
  Future<void> clearAll() => _storage.deleteAll();
}
