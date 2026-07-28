import 'package:dio/dio.dart';

/// Base class for all network-related failures surfaced to the app layer.
///
/// Every error path in [NetworkClient] is normalized into one of these
/// subtypes so that callers never need to inspect a raw [DioException].
sealed class ApiError implements Exception {
  const ApiError(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() =>
      '$runtimeType(statusCode: $statusCode, message: $message)';
}

/// The device has no active network connection.
final class NoInternetError extends ApiError {
  const NoInternetError([
    super.message = 'No internet connection. Please check your network.',
  ]);
}

/// The request took too long to complete (connect, send, or receive timeout).
final class TimeoutError extends ApiError {
  const TimeoutError([
    super.message = 'The request timed out. Please try again.',
  ]);
}

/// The server responded with a 4xx status code.
final class BadRequestError extends ApiError {
  const BadRequestError(super.message, {required int super.statusCode});
}

/// The server responded with a 401, indicating the caller is not authenticated.
final class UnauthorizedError extends ApiError {
  const UnauthorizedError([
    super.message = 'Session expired. Please sign in again.',
  ]) : super(statusCode: 401);
}

/// The server responded with a 403, indicating the caller lacks permission.
final class ForbiddenError extends ApiError {
  const ForbiddenError([
    super.message = 'You do not have permission to perform this action.',
  ]) : super(statusCode: 403);
}

/// The server responded with a 404.
final class NotFoundError extends ApiError {
  const NotFoundError([super.message = 'The requested resource was not found.'])
    : super(statusCode: 404);
}

/// The server responded with a 5xx status code.
final class ServerError extends ApiError {
  const ServerError(super.message, {required int super.statusCode});
}

/// The request was cancelled, typically by the caller.
final class CancelledError extends ApiError {
  const CancelledError([super.message = 'The request was cancelled.']);
}

/// The response body could not be parsed into the expected shape.
final class ParsingError extends ApiError {
  const ParsingError([super.message = 'Failed to parse the server response.']);
}

/// Catch-all for anything that doesn't map to a more specific error.
final class UnknownApiError extends ApiError {
  const UnknownApiError([
    super.message = 'An unexpected error occurred.',
    int? statusCode,
  ]) : super(statusCode: statusCode);
}

/// Maps a [DioException] (or any other thrown error) to a typed [ApiError].
ApiError mapExceptionToApiError(Object error) {
  if (error is ApiError) return error;

  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.transformTimeout:
        return const TimeoutError();
      case DioExceptionType.connectionError:
        return const NoInternetError();
      case DioExceptionType.cancel:
        return const CancelledError();
      case DioExceptionType.badCertificate:
        return const UnknownApiError(
          'Invalid or untrusted server certificate.',
        );
      case DioExceptionType.badResponse:
        return _mapStatusCode(error);
      case DioExceptionType.unknown:
        return error.error is Exception && error.message != null
            ? UnknownApiError(error.message!)
            : const NoInternetError();
    }
  }

  return UnknownApiError(error.toString());
}

ApiError _mapStatusCode(DioException error) {
  final statusCode = error.response?.statusCode ?? -1;
  final message =
      _extractMessage(error.response?.data) ??
      error.message ??
      'Request failed.';

  return switch (statusCode) {
    401 => UnauthorizedError(message),
    403 => ForbiddenError(message),
    404 => NotFoundError(message),
    >= 400 && < 500 => BadRequestError(message, statusCode: statusCode),
    >= 500 => ServerError(message, statusCode: statusCode),
    _ => UnknownApiError(message, statusCode),
  };
}

String? _extractMessage(dynamic data) {
  if (data is Map<String, dynamic>) {
    final message = data['message'] ?? data['error'] ?? data['detail'];
    if (message is String) return message;
  }
  return null;
}
