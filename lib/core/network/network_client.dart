import 'dart:developer' as developer;

import 'package:dio/dio.dart';

import '../storage/secure_storage.dart';
import 'api_error.dart';

/// Thin, testable wrapper around [Dio] that centralizes base configuration,
/// auth header injection, refresh-token handling, and error normalization.
///
/// Feature repositories should depend on [NetworkClient], never on [Dio]
/// directly, so the underlying HTTP stack can be swapped without touching
/// call sites.
class NetworkClient {
  NetworkClient({
    required String baseUrl,
    required SecureStorage secureStorage,
    Dio? dio,
    List<Interceptor> extraInterceptors = const [],
    bool enableLogging = false,
  }) : _secureStorage = secureStorage,
       _dio =
           dio ??
           Dio(
             BaseOptions(
               baseUrl: baseUrl,
               connectTimeout: const Duration(seconds: 15),
               sendTimeout: const Duration(seconds: 15),
               receiveTimeout: const Duration(seconds: 15),
               contentType: 'application/json',
               responseType: ResponseType.json,
             ),
           ) {
    _dio.interceptors.addAll([
      _AuthInterceptor(_secureStorage),
      ...extraInterceptors,
      if (enableLogging) _LoggingInterceptor(),
    ]);
  }

  final Dio _dio;
  final SecureStorage _secureStorage;

  /// Exposes the underlying [Dio] instance for advanced use cases (e.g.
  /// registering with third-party SDKs that need direct access).
  Dio get raw => _dio;

  Future<T> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic data)? decoder,
  }) => _request(
    () => _dio.get<dynamic>(
      path,
      queryParameters: queryParameters,
      options: options,
    ),
    decoder,
  );

  Future<T> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic data)? decoder,
  }) => _request(
    () => _dio.post<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    ),
    decoder,
  );

  Future<T> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic data)? decoder,
  }) => _request(
    () => _dio.put<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    ),
    decoder,
  );

  Future<T> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic data)? decoder,
  }) => _request(
    () => _dio.patch<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    ),
    decoder,
  );

  Future<T> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    T Function(dynamic data)? decoder,
  }) => _request(
    () => _dio.delete<dynamic>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    ),
    decoder,
  );

  Future<T> _request<T>(
    Future<Response<dynamic>> Function() call,
    T Function(dynamic data)? decoder,
  ) async {
    try {
      final response = await call();
      if (decoder != null) {
        try {
          return decoder(response.data);
        } catch (_) {
          throw const ParsingError();
        }
      }
      return response.data as T;
    } on ApiError {
      rethrow;
    } catch (error) {
      throw mapExceptionToApiError(error);
    }
  }
}

/// Attaches the current access token, if any, to every outgoing request.
class _AuthInterceptor extends Interceptor {
  _AuthInterceptor(this._secureStorage);

  final SecureStorage _secureStorage;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _secureStorage.readAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }
}

/// Lightweight request/response logger, intended for debug builds only.
class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    developer.log(
      '--> ${options.method} ${options.uri}',
      name: 'NetworkClient',
    );
    handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    developer.log(
      '<-- ${response.statusCode} ${response.requestOptions.uri}',
      name: 'NetworkClient',
    );
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    developer.log(
      '<-- ERROR ${err.response?.statusCode} ${err.requestOptions.uri}: ${err.message}',
      name: 'NetworkClient',
    );
    handler.next(err);
  }
}
