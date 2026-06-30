import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import '../constants/api_constants.dart';
import '../constants/app_constants.dart';
import '../storage/secure_storage_service.dart';
import '../utils/app_exceptions.dart';

/// Central HTTP client for all API requests.
///
/// Why this exists:
/// - Wraps Dio with pre-configured interceptors for auth, error handling, and logging.
/// - Every API call in the app goes through this single client.
/// - In a backend project, this is like your Axios instance or HTTP module.
///
/// Flow:
/// 1. Request Interceptor: Attaches Bearer token to every request.
/// 2. Response Interceptor: Logs responses and handles pagination if needed.
/// 3. Error Interceptor: Maps HTTP errors to typed AppExceptions.
/// 4. Auth Interceptor: Automatically retries failed requests after token refresh.
class ApiClient {
  late final Dio _dio;
  final _logger = Logger();
  final _secureStorage = SecureStorageService();

  /// Whether a token refresh is currently in progress.
  /// Prevents multiple simultaneous refresh attempts.
  bool _isRefreshing = false;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.baseUrl,
        connectTimeout: AppConstants.connectTimeout,
        receiveTimeout: AppConstants.receiveTimeout,
        sendTimeout: AppConstants.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.addAll([
      _authInterceptor(),
      _loggingInterceptor(),
      _errorInterceptor(),
    ]);
  }

  // ── Public HTTP methods ─────────────────────────────────────

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) {
    return _dio.get<T>(path, queryParameters: queryParameters);
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
  }) {
    return _dio.post<T>(path, data: data);
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
  }) {
    return _dio.put<T>(path, data: data);
  }

  Future<Response<T>> delete<T>(String path) {
    return _dio.delete<T>(path);
  }

  // ── Interceptors ────────────────────────────────────────────

  /// Attaches the Bearer token to every request.
  InterceptorsWrapper _authInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) async {
        // Skip auth header for login/refresh endpoints.
        if (options.path.contains('/auth/')) {
          return handler.next(options);
        }

        final token = await _secureStorage.getAccessToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        // If we get a 401, try to refresh the token.
        if (error.response?.statusCode == 401 && !_isRefreshing) {
          _isRefreshing = true;
          try {
            final refreshToken = await _secureStorage.getRefreshToken();
            if (refreshToken == null) {
              _isRefreshing = false;
              return handler.next(error);
            }

            // Attempt to refresh the token.
            // In production, this would call your auth server's refresh endpoint.
            // For this demo, we simulate a successful refresh.
            final newAccessToken = 'refreshed_${DateTime.now().millisecondsSinceEpoch}';
            await _secureStorage.saveAccessToken(newAccessToken);

            // Retry the original request with the new token.
            error.requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            final retryResponse = await _dio.fetch(error.requestOptions);
            _isRefreshing = false;
            return handler.resolve(retryResponse);
          } catch (e) {
            _isRefreshing = false;
            // If refresh fails, throw UnauthorizedException to trigger logout.
            return handler.next(
              DioException(
                requestOptions: error.requestOptions,
                error: const UnauthorizedException(),
              ),
            );
          }
        }
        return handler.next(error);
      },
    );
  }

  /// Logs all requests and responses for debugging.
  InterceptorsWrapper _loggingInterceptor() {
    return InterceptorsWrapper(
      onRequest: (options, handler) {
        _logger.i('🌐 [${options.method}] ${options.path}');
        handler.next(options);
      },
      onResponse: (response, handler) {
        _logger.i('✅ [${response.statusCode}] ${response.requestOptions.path}');
        handler.next(response);
      },
      onError: (error, handler) {
        _logger.e('❌ [${error.response?.statusCode}] ${error.requestOptions.path}: ${error.message}');
        handler.next(error);
      },
    );
  }

  /// Maps Dio errors to typed AppExceptions.
  InterceptorsWrapper _errorInterceptor() {
    return InterceptorsWrapper(
      onError: (error, handler) {
        // Check for network errors first.
        if (error.type == DioExceptionType.connectionTimeout ||
            error.type == DioExceptionType.receiveTimeout ||
            error.type == DioExceptionType.sendTimeout) {
          return handler.next(
            DioException(
              requestOptions: error.requestOptions,
              error: const TimeoutException(),
            ),
          );
        }

        if (error.type == DioExceptionType.connectionError) {
          return handler.next(
            DioException(
              requestOptions: error.requestOptions,
              error: const NetworkException(),
            ),
          );
        }

        // Map HTTP status codes to typed exceptions.
        final statusCode = error.response?.statusCode;
        switch (statusCode) {
          case 401:
            return handler.next(
              DioException(
                requestOptions: error.requestOptions,
                error: const UnauthorizedException(),
              ),
            );
          case 403:
            return handler.next(
              DioException(
                requestOptions: error.requestOptions,
                error: const ForbiddenException(),
              ),
            );
          case 404:
            return handler.next(
              DioException(
                requestOptions: error.requestOptions,
                error: const NotFoundException(),
              ),
            );
          case 500:
            return handler.next(
              DioException(
                requestOptions: error.requestOptions,
                error: const ServerException(),
              ),
            );
          default:
            return handler.next(
              DioException(
                requestOptions: error.requestOptions,
                error: UnknownException(
                  message: error.message ?? 'An unexpected error occurred.',
                ),
              ),
            );
        }
      },
    );
  }
}
