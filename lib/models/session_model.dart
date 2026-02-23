/// Session Model
/// Represents a session in the system
/// QR visibility rules come from backend ONLY
class SessionModel {
  final String id;
  final String title; // Session name/title
  final String startTime; // HH:mm format
  final String endTime; // HH:mm format
  final bool? canShowQr; // From backend - whether QR can be shown
  final DateTime? qrExpiresAt; // From backend - when QR expires (ISO timestamp)
  
  // Additional fields (optional, for compatibility)
  final DateTime? startDate;
  final String? description;
  final String? location;
  final String? sessionType; // 'PHYSICAL', 'REMOTE', 'HYBRID'
  
  SessionModel({
    required this.id,
    required this.title,
    required this.startTime,
    required this.endTime,
    this.canShowQr,
    this.qrExpiresAt,
    this.startDate,
    this.description,
    this.location,
    this.sessionType,
  });
  
  static String _toStringOrEmpty(dynamic value) {
    if (value == null) return '';
    return value.toString();
  }

  static String? _toNullableString(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      final trimmed = value.trim();
      return trimmed.isEmpty ? null : trimmed;
    }
    final converted = value.toString().trim();
    return converted.isEmpty ? null : converted;
  }

  static DateTime? _tryParseDate(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) {
      return DateTime.tryParse(value);
    }
    return DateTime.tryParse(value.toString());
  }

  static String? _parseLocation(dynamic rawLocation, dynamic rawPhysicalLocation) {
    // Highest priority: explicit physical location string from backend.
    final physical = _toNullableString(rawPhysicalLocation);
    if (physical != null) return physical;

    if (rawLocation == null) return null;

    if (rawLocation is String) {
      return _toNullableString(rawLocation);
    }

    // Support backend object shape:
    // location: { type: 'LINK' | 'COORDS', link?: string, geolocation?: { latitude, longitude } }
    if (rawLocation is Map<String, dynamic>) {
      final link = _toNullableString(rawLocation['link']);
      if (link != null) return link;

      final geolocation = rawLocation['geolocation'];
      if (geolocation is Map<String, dynamic>) {
        final lat = geolocation['latitude'];
        final lng = geolocation['longitude'];
        if (lat != null && lng != null) {
          return '${lat.toString()}, ${lng.toString()}';
        }
      }

      // Legacy coordinate shape: location: { latitude, longitude }
      final lat = rawLocation['latitude'];
      final lng = rawLocation['longitude'];
      if (lat != null && lng != null) {
        return '${lat.toString()}, ${lng.toString()}';
      }
    }

    return _toNullableString(rawLocation);
  }

  /// Create SessionModel from JSON
  /// Backend provides canShowQr and qrExpiresAt
  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      id: _toStringOrEmpty(json['_id'] ?? json['id']),
      title: _toStringOrEmpty(json['title'] ?? json['name']),
      startTime: _toStringOrEmpty(json['startTime'] ?? '09:00'),
      endTime: _toStringOrEmpty(json['endTime'] ?? '17:00'),
      // QR fields come from backend - DO NOT calculate in Flutter
      canShowQr: json['canShowQr'] is bool ? json['canShowQr'] as bool : null,
      qrExpiresAt: _tryParseDate(json['qrExpiresAt']),
      startDate: _tryParseDate(json['startDate']),
      description: _toNullableString(json['description']),
      location: _parseLocation(json['location'], json['physicalLocation']),
      sessionType: _toNullableString(json['sessionType']),
    );
  }
  
  /// Convert SessionModel to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'title': title,
      'startTime': startTime,
      'endTime': endTime,
      'canShowQr': canShowQr,
      'qrExpiresAt': qrExpiresAt?.toIso8601String(),
      'startDate': startDate?.toIso8601String(),
      'description': description,
      'location': location,
      'sessionType': sessionType,
    };
  }
  
  /// Check if QR is currently available
  /// Uses backend-provided canShowQr and qrExpiresAt
  /// DO NOT calculate time logic in Flutter
  bool get isQrAvailable {
    if (canShowQr != true) return false;
    if (qrExpiresAt == null) return false;
    return DateTime.now().isBefore(qrExpiresAt!);
  }

  /// Backward-compatibility alias for older UI code.
  String get name => title;
}
