/// App-wide constants
class AppConstants {
  // Storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';
  static const String deviceIdKey = 'device_id';
  static const String organizationPrefixKey = 'org_prefix';
  
  // Hive box names
  static const String userBox = 'user_box';
  static const String cacheBox = 'cache_box';
  
  // Default values
  static const double defaultLocationRadius = 100.0; // meters
  static const int defaultLateLimit = 30; // minutes
  static const double minGpsAccuracy = 50.0; // meters
  
  // UI constants
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 12.0;
  static const double cardElevation = 2.0;
  
  // Error messages
  static const String networkError = 'Network error. Please check your connection.';
  static const String serverError = 'Server error. Please try again later.';
  static const String unauthorizedError = 'Session expired. Please login again.';
  static const String locationError = 'Unable to get location. Please enable GPS.';
  static const String cameraError = 'Unable to access camera. Please grant camera permission.';
  
  // Success messages
  static const String attendanceMarked = 'Attendance marked successfully!';
  static const String leaveApplied = 'Leave request submitted successfully!';
}

