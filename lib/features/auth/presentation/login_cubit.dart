import 'package:flutter_bloc/flutter_bloc.dart';
// AuthToken is a Foundation type; syzygy_services_flutter does not re-export it.
import 'package:syzygy_foundation_flutter/syzygy_foundation_flutter.dart'
    show AuthToken;
import 'package:syzygy_services_flutter/syzygy_services_flutter.dart';

import '../domain/auth_use_case.dart' show AuthUser;
import 'login_state.dart';

/// Drives the login screen's state.
///
/// Uses [TokenAuthProvider] from the Services layer to persist authentication
/// tokens via the [StorageProvider].
///
/// TODO: Replace the stub [AuthToken] with real credentials returned by a
/// backend once a real login endpoint is wired up.
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authProvider) : super(const LoginInitial());

  final TokenAuthProvider _authProvider;

  Future<void> login({required String email, required String password}) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      emit(const LoginFailure('Email and password are required.'));
      return;
    }

    emit(const LoginLoading());
    await Future<void>.delayed(const Duration(milliseconds: 400));

    // TODO: Replace with a real network call via AuthRepository/AuthUseCase.
    // For now, the provider is called directly with a stub token so that
    // AppRouter's auth guard detects a signed-in state.
    _authProvider.authenticate(
      const AuthToken(accessToken: 'stub-access-token', refreshToken: null),
    );

    emit(LoginSuccess(AuthUser(id: 'stub-user', email: trimmedEmail)));
  }

  /// Signs the current user out and resets to [LoginInitial].
  ///
  /// Calling this invalidates the stored [AuthToken] via [TokenAuthProvider].
  /// The GoRouter redirect in [AppRouter] will then redirect to the login route
  /// on the next navigation event (or immediately if a [refreshListenable] is
  /// wired to the auth provider).
  void logout() {
    _authProvider.signOut();
    emit(const LoginInitial());
  }

  /// Resets the state back to [LoginInitial], e.g. when the user dismisses
  /// an error banner and wants to retry.
  void reset() => emit(const LoginInitial());
}
