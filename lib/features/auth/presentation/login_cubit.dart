import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/api_error.dart';
import '../domain/auth_use_case.dart';
import 'login_state.dart';

/// Drives the login screen's state via [AuthUseCase].
class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authUseCase) : super(const LoginInitial());

  final AuthUseCase _authUseCase;

  Future<void> login({required String email, required String password}) async {
    emit(const LoginLoading());
    try {
      final user = await _authUseCase.login(email: email, password: password);
      emit(LoginSuccess(user));
    } on ArgumentError catch (e) {
      emit(LoginFailure(e.message.toString()));
    } on ApiError catch (e) {
      emit(LoginFailure(e.message));
    } catch (e) {
      emit(LoginFailure('Something went wrong. Please try again.'));
    }
  }

  /// Resets the state back to [LoginInitial], e.g. when the user dismisses
  /// an error banner and wants to retry.
  void reset() => emit(const LoginInitial());
}
