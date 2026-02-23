class ApiService {
  /// Base URL from build-time environment variables
  /// Use: --dart-define=API_BASE_URL=https://api.attend-mark.onrender.com/api
  static const String _baseUrl = String.fromEnvironment('API_BASE_URL');

  static String get baseUrl {
    if (_baseUrl.isEmpty) {
      throw StateError(
        'API_BASE_URL is not set. Pass --dart-define=API_BASE_URL=https://api.attend-mark.onrender.com/api',
      );
    }
    return _baseUrl;
  }
}
