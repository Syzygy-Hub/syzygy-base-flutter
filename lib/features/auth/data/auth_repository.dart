import '../../../core/network/api_error.dart';
import '../../../core/network/network_client.dart';
import '../../../core/storage/secure_storage.dart';
import '../domain/auth_use_case.dart';

/// [AuthRepository] implementation backed by [NetworkClient] for the remote
/// API and [SecureStorage] for persisting tokens between sessions.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required NetworkClient networkClient,
    required SecureStorage secureStorage,
  }) : _networkClient = networkClient,
       _secureStorage = secureStorage;

  final NetworkClient _networkClient;
  final SecureStorage _secureStorage;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final response = await _networkClient.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
      decoder: (data) => data as Map<String, dynamic>,
    );

    final accessToken = response['accessToken'] as String?;
    final refreshToken = response['refreshToken'] as String?;
    final user = response['user'] as Map<String, dynamic>?;

    if (accessToken == null || user == null) {
      throw const ParsingError('Login response was missing required fields.');
    }

    await _secureStorage.writeAccessToken(accessToken);
    if (refreshToken != null) {
      await _secureStorage.writeRefreshToken(refreshToken);
    }

    return _userFromJson(user);
  }

  @override
  Future<void> logout() async {
    await _secureStorage.clearAll();
  }

  @override
  Future<AuthUser?> currentUser() async {
    final token = await _secureStorage.readAccessToken();
    if (token == null || token.isEmpty) return null;

    try {
      final response = await _networkClient.get<Map<String, dynamic>>(
        '/auth/me',
        decoder: (data) => data as Map<String, dynamic>,
      );
      return _userFromJson(response);
    } on UnauthorizedError {
      await _secureStorage.clearAll();
      return null;
    }
  }

  AuthUser _userFromJson(Map<String, dynamic> json) => AuthUser(
    id: json['id'] as String,
    email: json['email'] as String,
    name: json['name'] as String?,
  );
}
