import '../services/api_service.dart';

/// API Configuration
/// Single immutable base URL - DO NOT MODIFY
class ApiConfig {
  /// Base URL - IMMUTABLE - SINGLE SOURCE OF TRUTH
  static String get baseUrl => ApiService.baseUrl;
  
  // Request timeout configuration
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration sendTimeout = Duration(seconds: 30);
  
  // API Endpoints
  // Auth endpoints
  static const String login = '/auth/login';
  static const String selectOrganization = '/auth/select-organization';
  static const String getMe = '/auth/me';
  static const String logout = '/auth/logout';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  
  // Dashboard endpoints
  static const String dashboard = '/dashboard';
  
  // Session endpoints
  static const String sessions = '/sessions';
  static String sessionById(String id) => '/sessions/$id';
  
  // Attendance endpoints
  static const String attendanceScan = '/attendance/scan';
  static const String myAttendance = '/attendance/me';
  static String sessionAttendance(String sessionId) => '/attendance/session/$sessionId';
  
  // Leave endpoints
  static const String leaves = '/leaves';
  static String leaveById(String id) => '/leaves/$id';
  static const String applyLeave = '/leaves';
  
  // User endpoints
  static const String users = '/users';
  static String userById(String id) => '/users/$id';

  // App update endpoints
  static const String appUpdate = '/app/update';
}
