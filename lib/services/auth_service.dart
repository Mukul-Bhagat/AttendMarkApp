import '../core/network/dio_client.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';
import '../core/storage/local_storage.dart';
import '../core/utils/logger.dart';

/// Authentication Service
/// Handles all authentication-related API calls
class AuthService {
  final DioClient _dioClient;
  
  AuthService(this._dioClient);
  
  /// Login with email and password
  /// Returns tempToken and list of organizations
  /// 
  /// Response format:
  /// {
  ///   "tempToken": "string",
  ///   "organizations": [...]
  /// }
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      Logger.i('AuthService', 'Attempting login for: $email');
      
      final response = await _dioClient.post(
        ApiConfig.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      
      final responseData = response.data as Map<String, dynamic>;
      
      // Validate response structure
      if (responseData['tempToken'] == null) {
        throw Exception('Invalid login response: tempToken missing');
      }
      
      Logger.i('AuthService', 'Login successful. Organizations: ${responseData['organizations']?.length ?? 0}');
      
      return responseData;
    } catch (e) {
      Logger.e('AuthService', 'Login failed', e);
      rethrow;
    }
  }
  
  /// Select organization after login
  /// Returns final token and user data
  /// 
  /// Response format:
  /// {
  ///   "token": "string",
  ///   "user": {...}
  /// }
  Future<Map<String, dynamic>> selectOrganization(
    String tempToken,
    String prefix,
  ) async {
    try {
      Logger.i('AuthService', 'Selecting organization: $prefix');
      
      final response = await _dioClient.post(
        ApiConfig.selectOrganization,
        data: {
          'tempToken': tempToken,
          'organizationId': prefix, // We reuse 'prefix' arg name for now to minimize refactor, but send as organizationId logic
        },
      );
      
      final responseData = response.data as Map<String, dynamic>;
      
      // Validate response structure
      if (responseData['token'] == null) {
        throw Exception('Invalid response: token missing');
      }
      
      // Save token to storage
      await LocalStorage.saveToken(responseData['token']);
      Logger.i('AuthService', 'Token saved successfully');
      
      Logger.i('AuthService', 'Organization selected successfully');
      return responseData;
    } catch (e) {
      Logger.e('AuthService', 'Organization selection failed', e);
      rethrow;
    }
  }
  
  /// Get current user data
  Future<UserModel> getMe() async {
    try {
      Logger.i('AuthService', 'Fetching current user data');
      
      final response = await _dioClient.get(ApiConfig.getMe);
      
      final responseData = response.data as Map<String, dynamic>;
      
      // Handle different response formats
      final userData = responseData['user'] ?? responseData;
      
      Logger.i('AuthService', 'User data fetched successfully');
      return UserModel.fromJson(userData);
    } catch (e) {
      Logger.e('AuthService', 'Failed to fetch user data', e);
      rethrow;
    }
  }
  
  /// Logout (clear token on client side)
  /// Backend logout can be called if needed
  Future<void> logout() async {
    try {
      Logger.i('AuthService', 'Logging out');
      
      // Clear token from storage
      await LocalStorage.clearToken();
      
      Logger.i('AuthService', 'Logout successful');
    } catch (e) {
      Logger.e('AuthService', 'Logout failed', e);
      rethrow;
    }
  }
}
