import 'package:syzygy_foundation_flutter/syzygy_foundation_flutter.dart';
import 'package:syzygy_services_flutter/syzygy_services_flutter.dart';

import '../domain/auth_use_case.dart';

/// [AuthRepository] implementation backed by [HttpNetworkClient] for the
/// remote API and [TokenAuthProvider] for persisting tokens between sessions.
///
/// TODO: Wire up real API endpoints once a backend is available.
class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required HttpNetworkClient networkClient,
    required TokenAuthProvider authProvider,
  })  : _networkClient = networkClient,
        _authProvider = authProvider;

  // ignore: unused_field — will be used once real API endpoints are wired
  final HttpNetworkClient _networkClient;
  final TokenAuthProvider _authProvider;

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    // TODO: Replace with a real POST /auth/login call using _networkClient and
    // parse the response into an AuthToken.
    _authProvider.authenticate(
      const AuthToken(accessToken: 'stub-token', refreshToken: null),
    );
    return AuthUser(id: 'stub-user', email: email);
  }

  @override
  Future<void> logout() async {
    _authProvider.signOut();
  }

  @override
  Future<AuthUser?> currentUser() async {
    final state = _authProvider.state;
    if (state is Authenticated) {
      // TODO: Fetch real user profile from /auth/me using _networkClient.
      return const AuthUser(id: 'stub-user', email: 'user@example.com');
    }
    return null;
  }
}
