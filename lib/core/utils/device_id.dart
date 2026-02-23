import 'dart:math';
import '../storage/local_storage.dart';
import 'logger.dart';

/// Device ID Utility
/// Generates and stores a unique device ID
class DeviceId {
  static const String _deviceIdKey = 'app_device_id';
  static String? _cachedDeviceId;

  /// Get or create device ID
  /// Returns a unique device ID stored in SharedPreferences
  static Future<String> getOrCreateDeviceId() async {
    if (_cachedDeviceId != null) {
      return _cachedDeviceId!;
    }

    try {
      // Try to get existing device ID
      String? deviceId = LocalStorage.getString(_deviceIdKey);

      if (deviceId == null || deviceId.isEmpty) {
        // Generate new device ID (UUID-like format)
        deviceId = _generateDeviceId();

        // Save to storage
        await LocalStorage.saveString(_deviceIdKey, deviceId);
        Logger.i('DeviceId', 'Generated new device ID');
      } else {
        Logger.d('DeviceId', 'Retrieved existing device ID');
      }

      _cachedDeviceId = deviceId;
      return deviceId;
    } catch (e) {
      Logger.e('DeviceId', 'Failed to get/create device ID', e);
      // Return a fallback ID
      return _generateDeviceId();
    }
  }

  /// Get device ID synchronously (from cache)
  /// Returns null if not yet initialized
  static String? getDeviceIdSync() {
    return _cachedDeviceId ?? LocalStorage.getString(_deviceIdKey);
  }

  /// Generate a unique device ID
  static String _generateDeviceId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = random.nextInt(1000000);
    return 'flutter_${timestamp}_$randomPart';
  }

  /// Clear device ID (for testing/logout)
  static Future<void> clearDeviceId() async {
    await LocalStorage.remove(_deviceIdKey);
    _cachedDeviceId = null;
    Logger.i('DeviceId', 'Device ID cleared');
  }
}
