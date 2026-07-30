import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/storage/secure_storage.dart';
import '../domain/auth_use_case.dart';
import 'login_state.dart';

/// Drives the login screen's state.
///
/// This is a mock authentication flow: it only validates that the fields
/// are non-empty and persists a placeholder token via [SecureStorage] so
/// [AppRouter]'s auth gating picks up the signed-in state. No network call
/// is made; swap this out for [AuthUseCase] once a real backend is wired up.
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._secureStorage) : super(const LoginInitial());

  final SecureStorage _secureStorage;

  Future<void> login({required String email, required String password}) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || password.isEmpty) {
      emit(const LoginFailure('Email and password are required.'));
      return;
    }

    emit(const LoginLoading());
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await _secureStorage.writeAccessToken('mock-access-token');
    emit(LoginSuccess(AuthUser(id: 'mock-user', email: trimmedEmail)));
  }

  /// Resets the state back to [LoginInitial], e.g. when the user dismisses
  /// an error banner and wants to retry.
  void reset() => emit(const LoginInitial());
}
