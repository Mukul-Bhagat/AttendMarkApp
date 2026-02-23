import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../models/attendance_model.dart';
import '../services/attendance_service.dart';
import '../core/utils/logger.dart';

/// Attendance Provider
/// Manages attendance state and data
class AttendanceProvider with ChangeNotifier {
  final AttendanceService _attendanceService;
  
  List<AttendanceModel> _myAttendance = [];
  bool _isLoading = false;
  String? _error;
  Position? _currentPosition;
  bool _isGettingLocation = false;
  
  AttendanceProvider(this._attendanceService);
  
  // Getters
  List<AttendanceModel> get myAttendance => _myAttendance;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Position? get currentPosition => _currentPosition;
  bool get isGettingLocation => _isGettingLocation;
  
  /// Get my attendance records
  Future<void> getMyAttendance({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      Logger.i('AttendanceProvider', 'Fetching my attendance');
      
      _myAttendance = await _attendanceService.getMyAttendance(
        startDate: startDate,
        endDate: endDate,
      );
      
      _isLoading = false;
      notifyListeners();
      
      Logger.i('AttendanceProvider', 'Fetched ${_myAttendance.length} attendance records');
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      Logger.e('AttendanceProvider', 'Failed to fetch attendance', e);
    }
  }
  
  /// Get current GPS location
  /// Handles permission requests and errors
  Future<Position?> getCurrentLocation() async {
    _isGettingLocation = true;
    _error = null;
    notifyListeners();
    
    try {
      Logger.i('AttendanceProvider', 'Getting current location');
      
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled. Please enable GPS in your device settings.');
      }
      
      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        Logger.d('AttendanceProvider', 'Location permission denied, requesting...');
        permission = await Geolocator.requestPermission();
        
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied. Please grant location permission to mark attendance.');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied. Please enable location access in app settings.');
      }
      
      // Get position with high accuracy
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );
      
      Logger.i('AttendanceProvider', 'Location obtained: ${_currentPosition!.latitude}, ${_currentPosition!.longitude}');
      Logger.d('AttendanceProvider', 'Accuracy: ${_currentPosition!.accuracy}m');
      
      _isGettingLocation = false;
      notifyListeners();
      
      return _currentPosition;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isGettingLocation = false;
      notifyListeners();
      Logger.e('AttendanceProvider', 'Failed to get location', e);
      rethrow;
    }
  }
  
  /// Mark attendance by scanning QR code
  /// Requires sessionId, deviceId, userAgent
  /// Automatically gets GPS location
  Future<Map<String, dynamic>> markAttendance({
    required String sessionId,
    required String deviceId,
    required String userAgent,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      Logger.i('AttendanceProvider', 'Marking attendance for session: $sessionId');
      
      // Get current location first
      final position = await getCurrentLocation();
      if (position == null) {
        throw Exception('Unable to get location. Please enable GPS and try again.');
      }
      
      // Validate GPS accuracy (optional frontend check)
      if (position.accuracy > 50) {
        Logger.w('AttendanceProvider', 'GPS accuracy is low: ${position.accuracy}m');
        // Continue anyway - backend will validate
      }
      
      // Create attendance scan request
      final request = AttendanceScanRequest(
        sessionId: sessionId,
        userLocation: AttendanceLocation(
          latitude: position.latitude,
          longitude: position.longitude,
        ),
        deviceId: deviceId,
        userAgent: userAgent,
        accuracy: position.accuracy,
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );
      
      // Mark attendance
      final response = await _attendanceService.markAttendance(request);
      
      // Refresh attendance list
      await getMyAttendance();
      
      _isLoading = false;
      notifyListeners();
      
      Logger.i('AttendanceProvider', 'Attendance marked successfully');
      return response;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      Logger.e('AttendanceProvider', 'Failed to mark attendance', e);
      rethrow;
    }
  }
  
  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  /// Refresh attendance
  Future<void> refresh() async {
    await getMyAttendance();
  }
}
