import 'package:equatable/equatable.dart';

import '../domain/auth_use_case.dart';

/// States emitted by [LoginCubit].
sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

/// Initial, idle state before any login attempt has been made.
final class LoginInitial extends LoginState {
  const LoginInitial();
}

/// A login request is in flight.
final class LoginLoading extends LoginState {
  const LoginLoading();
}

/// Login succeeded; [user] is the authenticated user.
final class LoginSuccess extends LoginState {
  const LoginSuccess(this.user);

  final AuthUser user;

  @override
  List<Object?> get props => [user];
}

/// Login failed; [message] is a user-facing description of why.
final class LoginFailure extends LoginState {
  const LoginFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
