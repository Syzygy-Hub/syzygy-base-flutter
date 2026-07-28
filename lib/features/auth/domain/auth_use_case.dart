import 'package:equatable/equatable.dart';

/// Authenticated user, as understood by the presentation layer.
class AuthUser extends Equatable {
  const AuthUser({required this.id, required this.email, this.name});

  final String id;
  final String email;
  final String? name;

  @override
  List<Object?> get props => [id, email, name];
}

/// Contract for the auth data layer. Implemented by [AuthRepositoryImpl] in
/// the data layer; consumed by [AuthUseCase] and, in tests, by fakes.
abstract interface class AuthRepository {
  Future<AuthUser> login({required String email, required String password});
  Future<void> logout();
  Future<AuthUser?> currentUser();
}

/// Encapsulates the auth business rules (input validation, orchestration)
/// on top of [AuthRepository], keeping that logic out of the Cubit.
class AuthUseCase {
  AuthUseCase(this._repository);

  final AuthRepository _repository;

  /// Validates credentials and delegates to the repository.
  ///
  /// Throws an [ArgumentError] for client-side validation failures; network
  /// and server errors surface as [ApiError]s from the repository itself.
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty || !trimmedEmail.contains('@')) {
      throw ArgumentError('Please enter a valid email address.');
    }
    if (password.length < 8) {
      throw ArgumentError('Password must be at least 8 characters.');
    }

    return _repository.login(email: trimmedEmail, password: password);
  }

  Future<void> logout() => _repository.logout();

  Future<AuthUser?> currentUser() => _repository.currentUser();
}
