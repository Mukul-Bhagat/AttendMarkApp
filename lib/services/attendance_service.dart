import '../core/network/dio_client.dart';
import '../config/api_config.dart';
import '../models/attendance_model.dart';
import '../core/utils/logger.dart';

/// Attendance Service
/// Handles attendance-related API calls
class AttendanceService {
  final DioClient _dioClient;
  
  AttendanceService(this._dioClient);
  
  /// Mark attendance by scanning QR code
  /// POST /api/attendance/scan
  /// 
  /// Request body:
  /// {
  ///   "sessionId": "string",
  ///   "userLocation": { "latitude": number, "longitude": number },
  ///   "deviceId": "string",
  ///   "userAgent": "string",
  ///   "accuracy": number,
  ///   "timestamp": number
  /// }
  Future<Map<String, dynamic>> markAttendance(
    AttendanceScanRequest request,
  ) async {
    try {
      Logger.i('AttendanceService', 'Marking attendance for session: ${request.sessionId}');
      Logger.d('AttendanceService', 'Location: ${request.userLocation.latitude}, ${request.userLocation.longitude}');
      Logger.d('AttendanceService', 'Device ID: ${request.deviceId}');
      Logger.d('AttendanceService', 'Accuracy: ${request.accuracy}m');
      
      final response = await _dioClient.post(
        ApiConfig.attendanceScan,
        data: request.toJson(),
      );
      
      Logger.i('AttendanceService', 'Attendance marked successfully');
      return response.data as Map<String, dynamic>;
    } catch (e) {
      Logger.e('AttendanceService', 'Failed to mark attendance', e);
      rethrow;
    }
  }
  
  /// Get my attendance records
  /// GET /api/attendance/me
  Future<List<AttendanceModel>> getMyAttendance({
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Logger.i('AttendanceService', 'Fetching my attendance');
      
      final queryParams = <String, dynamic>{};
      if (startDate != null) {
        queryParams['startDate'] = startDate.toIso8601String();
      }
      if (endDate != null) {
        queryParams['endDate'] = endDate.toIso8601String();
      }
      
      final response = await _dioClient.get(
        ApiConfig.myAttendance,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      
      final List<dynamic> attendanceJson = response.data is List
          ? response.data
          : response.data['attendance'] ?? [];
      
      final attendance = attendanceJson
          .map((json) => AttendanceModel.fromJson(json))
          .toList();
      
      Logger.i('AttendanceService', 'Fetched ${attendance.length} attendance records');
      return attendance;
    } catch (e) {
      Logger.e('AttendanceService', 'Failed to fetch attendance', e);
      rethrow;
    }
  }
}
