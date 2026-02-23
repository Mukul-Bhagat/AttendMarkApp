import 'package:flutter/foundation.dart';

/// Simple logger utility for debugging
/// Prints logs in debug mode only
class Logger {
  static void d(String tag, String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[$tag] $message');
      if (error != null) {
        debugPrint('[$tag] Error: $error');
        if (stackTrace != null) {
          debugPrint('[$tag] StackTrace: $stackTrace');
        }
      }
    }
  }
  
  static void i(String tag, String message) {
    if (kDebugMode) {
      debugPrint('[$tag] ℹ️ $message');
    }
  }
  
  static void w(String tag, String message) {
    if (kDebugMode) {
      debugPrint('[$tag] ⚠️ $message');
    }
  }
  
  static void e(String tag, String message, [Object? error, StackTrace? stackTrace]) {
    if (kDebugMode) {
      debugPrint('[$tag] ❌ $message');
      if (error != null) {
        debugPrint('[$tag] Error: $error');
        if (stackTrace != null) {
          debugPrint('[$tag] StackTrace: $stackTrace');
        }
      }
    }
  }
  
  // API specific logging
  static void apiRequest(String method, String url, [Map<String, dynamic>? data]) {
    if (kDebugMode) {
      debugPrint('[API] → $method $url');
      if (data != null) {
        debugPrint('[API] Data: $data');
      }
    }
  }
  
  static void apiResponse(String method, String url, int statusCode, [dynamic data]) {
    if (kDebugMode) {
      debugPrint('[API] ← $method $url [Status: $statusCode]');
      if (data != null) {
        debugPrint('[API] Response: $data');
      }
    }
  }
  
  static void apiError(String method, String url, String error) {
    if (kDebugMode) {
      debugPrint('[API] ✗ $method $url');
      debugPrint('[API] Error: $error');
    }
  }
}

