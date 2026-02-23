import 'package:dio/dio.dart';
import '../utils/logger.dart';

/// API Error Handler
/// Maps backend errors to user-friendly messages
/// 
/// Handles all DioException types and HTTP status codes
class ApiErrorHandler {
  // Error message constants
  static const String networkError = 'Network error. Please check your internet connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unauthorizedError = 'Session expired. Please login again.';
  static const String timeoutError = 'Request timeout. Please try again.';
  static const String unknownError = 'An unexpected error occurred.';
  
  /// Handle Dio error and return user-friendly message
  /// 
  /// Maps DioException types to readable error messages
  static String handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        Logger.w('ApiErrorHandler', 'Timeout error: ${error.type}');
        return timeoutError;
      
      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);
      
      case DioExceptionType.cancel:
        Logger.w('ApiErrorHandler', 'Request cancelled');
        return 'Request cancelled.';
      
      case DioExceptionType.connectionError:
        Logger.e('ApiErrorHandler', 'Connection error: ${error.message}');
        return networkError;
      
      case DioExceptionType.badCertificate:
        Logger.e('ApiErrorHandler', 'Bad certificate error');
        return 'Certificate error. Please contact support.';
      
      case DioExceptionType.unknown:
        return _handleUnknownError(error);
    }
  }
  
  /// Handle HTTP response errors
  /// 
  /// Extracts error messages from response body when available
  static String _handleResponseError(Response? response) {
    if (response == null) {
      Logger.e('ApiErrorHandler', 'Response is null');
      return serverError;
    }
    
    final statusCode = response.statusCode ?? 0;
    final data = response.data;
    
    // Try to extract error message from response
    String? errorMessage;
    if (data is Map<String, dynamic>) {
      // Backend may return error in different fields
      errorMessage = data['msg'] ?? 
                     data['message'] ?? 
                     data['error'] ?? 
                     data['errorMessage'];
      
      // Log extracted message
      if (errorMessage != null) {
        Logger.d('ApiErrorHandler', 'Extracted error message: $errorMessage');
      }
    }
    
    // Map status codes to user-friendly messages
    switch (statusCode) {
      case 400:
        Logger.w('ApiErrorHandler', 'Bad Request (400)');
        return errorMessage ?? 'Invalid request. Please check your input.';
      
      case 401:
        Logger.w('ApiErrorHandler', 'Unauthorized (401)');
        return errorMessage ?? unauthorizedError;
      
      case 403:
        Logger.w('ApiErrorHandler', 'Forbidden (403)');
        return errorMessage ?? 'Access denied.';
      
      case 404:
        Logger.w('ApiErrorHandler', 'Not Found (404)');
        return errorMessage ?? 'Resource not found.';
      
      case 422:
        Logger.w('ApiErrorHandler', 'Validation Error (422)');
        return errorMessage ?? 'Validation error. Please check your input.';
      
      case 500:
        Logger.e('ApiErrorHandler', 'Internal Server Error (500)');
        return errorMessage ?? serverError;
      
      case 502:
        Logger.e('ApiErrorHandler', 'Bad Gateway (502)');
        return errorMessage ?? serverError;
      
      case 503:
        Logger.e('ApiErrorHandler', 'Service Unavailable (503)');
        return errorMessage ?? 'Service temporarily unavailable. Please try again later.';
      
      default:
        Logger.w('ApiErrorHandler', 'Unknown status code: $statusCode');
        return errorMessage ?? 'An error occurred (Status: $statusCode)';
    }
  }
  
  /// Handle unknown errors
  static String _handleUnknownError(DioException error) {
    final message = error.message ?? '';
    
    // Check for common network-related errors
    if (message.contains('SocketException') || 
        message.contains('Network is unreachable') ||
        message.contains('Failed host lookup')) {
      Logger.e('ApiErrorHandler', 'Network error: $message');
      return networkError;
    }
    
    Logger.e('ApiErrorHandler', 'Unknown error: $message');
    return unknownError;
  }
  
  /// Check if error is authentication related (401)
  static bool isUnauthorized(DioException error) {
    return error.response?.statusCode == 401;
  }
  
  /// Check if error is network related
  static bool isNetworkError(DioException error) {
    return error.type == DioExceptionType.connectionError ||
           error.type == DioExceptionType.connectionTimeout ||
           error.type == DioExceptionType.sendTimeout ||
           error.type == DioExceptionType.receiveTimeout ||
           (error.type == DioExceptionType.unknown && 
            (error.message?.contains('SocketException') ?? false));
  }
  
  /// Check if error is server related (5xx)
  static bool isServerError(DioException error) {
    final statusCode = error.response?.statusCode;
    return statusCode != null && statusCode >= 500 && statusCode < 600;
  }
  
  /// Check if error is client related (4xx)
  static bool isClientError(DioException error) {
    final statusCode = error.response?.statusCode;
    return statusCode != null && statusCode >= 400 && statusCode < 500;
  }
}
