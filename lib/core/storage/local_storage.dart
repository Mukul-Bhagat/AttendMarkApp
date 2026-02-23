import 'package:shared_preferences/shared_preferences.dart';
import '../utils/logger.dart';

/// Local Storage Service
/// Handles secure storage using SharedPreferences
/// 
/// Primary use: Token management for authentication
class LocalStorage {
  static SharedPreferences? _prefs;
  static bool _isInitialized = false;
  
  /// Initialize SharedPreferences
  /// Must be called before using any storage methods
  static Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      Logger.i('LocalStorage', 'Initialized successfully');
    } catch (e) {
      Logger.e('LocalStorage', 'Failed to initialize', e);
      _isInitialized = false;
      rethrow;
    }
  }
  
  /// Check if storage is initialized
  static bool get isInitialized => _isInitialized;
  
  // ==================== TOKEN MANAGEMENT ====================
  
  /// Save authentication token
  /// Key: 'auth_token'
  static Future<bool> saveToken(String token) async {
    try {
      if (!_isInitialized) {
        Logger.w('LocalStorage', 'Not initialized. Call init() first.');
        return false;
      }
      final result = await _prefs?.setString('auth_token', token) ?? false;
      if (result) {
        Logger.i('LocalStorage', 'Token saved successfully');
      }
      return result;
    } catch (e) {
      Logger.e('LocalStorage', 'Failed to save token', e);
      return false;
    }
  }
  
  /// Read authentication token
  /// Returns null if token doesn't exist
  static String? getToken() {
    try {
      if (!_isInitialized) {
        Logger.w('LocalStorage', 'Not initialized. Call init() first.');
        return null;
      }
      final token = _prefs?.getString('auth_token');
      if (token != null) {
        Logger.d('LocalStorage', 'Token retrieved');
      }
      return token;
    } catch (e) {
      Logger.e('LocalStorage', 'Failed to get token', e);
      return null;
    }
  }
  
  /// Clear authentication token
  static Future<bool> clearToken() async {
    try {
      if (!_isInitialized) {
        Logger.w('LocalStorage', 'Not initialized. Call init() first.');
        return false;
      }
      final result = await _prefs?.remove('auth_token') ?? false;
      if (result) {
        Logger.i('LocalStorage', 'Token cleared');
      }
      return result;
    } catch (e) {
      Logger.e('LocalStorage', 'Failed to clear token', e);
      return false;
    }
  }
  
  /// Check if token exists
  static bool hasToken() {
    try {
      if (!_isInitialized) {
        return false;
      }
      return _prefs?.containsKey('auth_token') ?? false;
    } catch (e) {
      Logger.e('LocalStorage', 'Failed to check token', e);
      return false;
    }
  }
  
  // ==================== GENERIC STORAGE METHODS ====================
  
  /// Save string value
  static Future<bool> saveString(String key, String value) async {
    try {
      if (!_isInitialized) {
        Logger.w('LocalStorage', 'Not initialized. Call init() first.');
        return false;
      }
      return await _prefs?.setString(key, value) ?? false;
    } catch (e) {
      Logger.e('LocalStorage', 'Failed to save string: $key', e);
      return false;
    }
  }
  
  /// Get string value
  static String? getString(String key) {
    try {
      if (!_isInitialized) {
        Logger.w('LocalStorage', 'Not initialized. Call init() first.');
        return null;
      }
      return _prefs?.getString(key);
    } catch (e) {
      Logger.e('LocalStorage', 'Failed to get string: $key', e);
      return null;
    }
  }
  
  /// Save boolean value
  static Future<bool> saveBool(String key, bool value) async {
    try {
      if (!_isInitialized) {
        Logger.w('LocalStorage', 'Not initialized. Call init() first.');
        return false;
      }
      return await _prefs?.setBool(key, value) ?? false;
    } catch (e) {
      Logger.e('LocalStorage', 'Failed to save bool: $key', e);
      return false;
    }
  }
  
  /// Get boolean value
  static bool? getBool(String key) {
    try {
      if (!_isInitialized) {
        Logger.w('LocalStorage', 'Not initialized. Call init() first.');
        return null;
      }
      return _prefs?.getBool(key);
    } catch (e) {
      Logger.e('LocalStorage', 'Failed to get bool: $key', e);
      return null;
    }
  }
  
  /// Save integer value
  static Future<bool> saveInt(String key, int value) async {
    try {
      if (!_isInitialized) {
        Logger.w('LocalStorage', 'Not initialized. Call init() first.');
        return false;
      }
      return await _prefs?.setInt(key, value) ?? false;
    } catch (e) {
      Logger.e('LocalStorage', 'Failed to save int: $key', e);
      return false;
    }
  }
  
  /// Get integer value
  static int? getInt(String key) {
    try {
      if (!_isInitialized) {
        Logger.w('LocalStorage', 'Not initialized. Call init() first.');
        return null;
      }
      return _prefs?.getInt(key);
    } catch (e) {
      Logger.e('LocalStorage', 'Failed to get int: $key', e);
      return null;
    }
  }
  
  /// Remove value by key
  static Future<bool> remove(String key) async {
    try {
      if (!_isInitialized) {
        Logger.w('LocalStorage', 'Not initialized. Call init() first.');
        return false;
      }
      return await _prefs?.remove(key) ?? false;
    } catch (e) {
      Logger.e('LocalStorage', 'Failed to remove: $key', e);
      return false;
    }
  }
  
  /// Clear all stored data
  static Future<bool> clear() async {
    try {
      if (!_isInitialized) {
        Logger.w('LocalStorage', 'Not initialized. Call init() first.');
        return false;
      }
      final result = await _prefs?.clear() ?? false;
      if (result) {
        Logger.i('LocalStorage', 'All data cleared');
      }
      return result;
    } catch (e) {
      Logger.e('LocalStorage', 'Failed to clear storage', e);
      return false;
    }
  }
  
  /// Check if key exists
  static bool containsKey(String key) {
    try {
      if (!_isInitialized) {
        return false;
      }
      return _prefs?.containsKey(key) ?? false;
    } catch (e) {
      Logger.e('LocalStorage', 'Failed to check key: $key', e);
      return false;
    }
  }
}
