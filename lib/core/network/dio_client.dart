import 'package:dio/dio.dart';
import '../../config/api_config.dart';
import '../storage/local_storage.dart';
import '../utils/logger.dart';
import 'api_error_handler.dart';
import '../../services/api_service.dart';

/// Dio HTTP Client
/// Production-ready HTTP client with interceptors for:
/// - Authentication (JWT token)
/// - Request/Response logging
/// - Error handling
/// - Auto logout on 401
class DioClient {
  late Dio _dio;



  DioClient() {
    final baseUrl = ApiService.baseUrl;

    // Single log line
    Logger.i('API CONFIG', 'Using baseUrl: $baseUrl');

    // Initialize Dio with baseUrl directly - no manipulation
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        sendTimeout: ApiConfig.sendTimeout,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          return status != null && status >= 200 && status < 300;
        },
      ),
    );

    _setupInterceptors();
  }

  /// Setup request and response interceptors
  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          _logRequest(options);
          _addAuthToken(options);
          return handler.next(options);
        },
        onResponse: (response, handler) {
          _logResponse(response);
          return handler.next(response);
        },
        onError: (error, handler) {
          _logError(error);
          _handleUnauthorized(error);
          return handler.next(error);
        },
      ),
    );
  }

  /// Log request details
  void _logRequest(RequestOptions options) {
    Logger.apiRequest(
      options.method,
      '${options.baseUrl}${options.path}',
      options.data,
    );

    // Log query parameters if present
    if (options.queryParameters.isNotEmpty) {
      Logger.d('DioClient', 'Query params: ${options.queryParameters}');
    }

    // Log headers (excluding sensitive data)
    final headers = Map<String, dynamic>.from(options.headers);
    if (headers.containsKey('Authorization')) {
      headers['Authorization'] = 'Bearer ***';
    }
    Logger.d('DioClient', 'Headers: $headers');
  }

  /// Log response details
  void _logResponse(Response response) {
    Logger.apiResponse(
      response.requestOptions.method,
      '${response.requestOptions.baseUrl}${response.requestOptions.path}',
      response.statusCode ?? 0,
      response.data,
    );
  }

  /// Log error details
  void _logError(DioException error) {
    final errorMessage = ApiErrorHandler.handleError(error);
    Logger.apiError(
      error.requestOptions.method,
      '${error.requestOptions.baseUrl}${error.requestOptions.path}',
      errorMessage,
    );

    // Log additional error details
    Logger.d('DioClient', 'Error type: ${error.type}');
    Logger.d('DioClient', 'Status code: ${error.response?.statusCode}');
    if (error.response?.data != null) {
      Logger.d('DioClient', 'Error data: ${error.response?.data}');
    }
  }

  /// Add JWT token to request headers
  void _addAuthToken(RequestOptions options) {
    try {
      final token = LocalStorage.getToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
        Logger.d('DioClient', 'Auth token added to request');
      } else {
        Logger.d('DioClient', 'No auth token available');
      }
    } catch (e) {
      Logger.e('DioClient', 'Failed to add auth token', e);
    }
  }

  /// Handle unauthorized (401) - Clear token
  void _handleUnauthorized(DioException error) {
    if (ApiErrorHandler.isUnauthorized(error)) {
      Logger.w(
        'DioClient',
        'Unauthorized (401) detected. Clearing auth token.',
      );
      LocalStorage.clearToken();
      // Note: Navigation to login will be handled by AuthProvider
    }
  }

  // ==================== HTTP METHODS ====================

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// DELETE request
  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Handle Dio error and convert to user-friendly exception
  Exception _handleDioError(DioException error) {
    final message = ApiErrorHandler.handleError(error);
    return Exception(message);
  }

  /// Get raw Dio instance (for advanced usage)
  /// Use with caution - bypasses error handling
  Dio get dio => _dio;
}
