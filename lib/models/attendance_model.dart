import 'session_model.dart';

/// Attendance Model
/// Represents an attendance record
class AttendanceModel {
  final String id;
  final String userId;
  final SessionModel? session; // Populated session or null
  final String? sessionId; // Session ID if session is null
  final DateTime checkInTime;
  final bool locationVerified;
  final bool isLate;
  final int? lateByMinutes;
  final AttendanceLocation userLocation;
  final String deviceId;
  final double? accuracy; // GPS accuracy in meters
  final double? distanceFromSession; // Distance from session location in meters
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  AttendanceModel({
    required this.id,
    required this.userId,
    this.session,
    this.sessionId,
    required this.checkInTime,
    this.locationVerified = false,
    this.isLate = false,
    this.lateByMinutes,
    required this.userLocation,
    required this.deviceId,
    this.accuracy,
    this.distanceFromSession,
    this.createdAt,
    this.updatedAt,
  });
  
  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? '',
      session: json['sessionId'] != null && json['sessionId'] is Map
          ? SessionModel.fromJson(json['sessionId'])
          : null,
      sessionId: json['sessionId'] is String 
          ? json['sessionId'] 
          : json['sessionId']?['_id'],
      checkInTime: json['checkInTime'] != null 
          ? DateTime.parse(json['checkInTime']) 
          : DateTime.now(),
      locationVerified: json['locationVerified'] ?? false,
      isLate: json['isLate'] ?? false,
      lateByMinutes: json['lateByMinutes'],
      userLocation: AttendanceLocation.fromJson(json['userLocation'] ?? {}),
      deviceId: json['deviceId'] ?? '',
      accuracy: json['accuracy']?.toDouble(),
      distanceFromSession: json['distanceFromSession']?.toDouble(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : null,
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt']) 
          : null,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'sessionId': sessionId ?? session?.id,
      'checkInTime': checkInTime.toIso8601String(),
      'locationVerified': locationVerified,
      'isLate': isLate,
      'lateByMinutes': lateByMinutes,
      'userLocation': userLocation.toJson(),
      'deviceId': deviceId,
      'accuracy': accuracy,
      'distanceFromSession': distanceFromSession,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
  
  /// Get status text
  String get statusText {
    if (isLate) {
      return 'Late (${lateByMinutes ?? 0} min)';
    }
    return locationVerified ? 'Present' : 'Present (Location not verified)';
  }
}

/// Attendance Location Model
class AttendanceLocation {
  final double latitude;
  final double longitude;
  
  AttendanceLocation({
    required this.latitude,
    required this.longitude,
  });
  
  factory AttendanceLocation.fromJson(Map<String, dynamic> json) {
    return AttendanceLocation(
      latitude: (json['latitude'] ?? 0.0).toDouble(),
      longitude: (json['longitude'] ?? 0.0).toDouble(),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}

/// Attendance Scan Request Model
class AttendanceScanRequest {
  final String sessionId;
  final AttendanceLocation userLocation;
  final String deviceId;
  final String userAgent;
  final double accuracy;
  final int timestamp;
  
  AttendanceScanRequest({
    required this.sessionId,
    required this.userLocation,
    required this.deviceId,
    required this.userAgent,
    required this.accuracy,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'userLocation': userLocation.toJson(),
      'deviceId': deviceId,
      'userAgent': userAgent,
      'accuracy': accuracy,
      'timestamp': timestamp,
    };
  }
}

