/// Leave Model
/// Represents a leave request
class LeaveModel {
  final String id;
  final String userId;
  final String
  leaveType; // 'PL' (Personal Leave), 'CL' (Casual Leave), 'SL' (Sick Leave)
  final String startDate; // YYYY-MM-DD (IST)
  final String endDate; // YYYY-MM-DD (IST)
  final int? daysCount;
  final String reason;
  final String status; // 'Pending', 'Approved', 'Rejected'
  final bool isBackdated;
  final String? backdatedLabel;
  final String? documentUrl;
  final String? documentPublicId;
  final String? rejectedReason;
  final String? approvedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LeaveModel({
    required this.id,
    required this.userId,
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    this.daysCount,
    required this.reason,
    this.status = 'Pending',
    this.isBackdated = false,
    this.backdatedLabel,
    this.documentUrl,
    this.documentPublicId,
    this.rejectedReason,
    this.approvedBy,
    this.createdAt,
    this.updatedAt,
  });

  static final RegExp _dateOnlyRegex = RegExp(r'^\\d{4}-\\d{2}-\\d{2}$');

  static String _toDateOnlyString(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  static String _normalizeDateOnly(dynamic value) {
    if (value == null) return '';
    if (value is DateTime) {
      final ist = value.toUtc().add(const Duration(hours: 5, minutes: 30));
      return _toDateOnlyString(ist);
    }
    final str = value.toString().trim();
    if (_dateOnlyRegex.hasMatch(str)) return str;
    final parsed = DateTime.tryParse(str);
    if (parsed == null) return str;
    final ist = parsed.toUtc().add(const Duration(hours: 5, minutes: 30));
    return _toDateOnlyString(ist);
  }

  static DateTime _parseDateOnly(String dateStr) {
    final parts = dateStr.split('-');
    if (parts.length != 3) return DateTime.utc(1970, 1, 1);
    final year = int.tryParse(parts[0]) ?? 1970;
    final month = int.tryParse(parts[1]) ?? 1;
    final day = int.tryParse(parts[2]) ?? 1;
    return DateTime.utc(year, month, day);
  }

  factory LeaveModel.fromJson(Map<String, dynamic> json) {
    final rawUserId = json['userId'];
    final parsedUserId = rawUserId is Map<String, dynamic>
        ? (rawUserId['_id'] ?? rawUserId['id'] ?? '').toString()
        : (rawUserId ?? '').toString();

    return LeaveModel(
      id: json['_id'] ?? json['id'] ?? '',
      userId: parsedUserId,
      leaveType: json['leaveType'] ?? 'CL',
      startDate: _normalizeDateOnly(json['startDate']),
      endDate: _normalizeDateOnly(json['endDate']),
      daysCount: json['daysCount'] is num
          ? (json['daysCount'] as num).round()
          : null,
      reason: json['reason'] ?? '',
      status: json['status'] ?? 'Pending',
      isBackdated: json['isBackdated'] == true,
      backdatedLabel: json['backdatedLabel'],
      documentUrl: json['documentUrl'] ?? json['attachmentUrl'] ?? json['attachment'],
      documentPublicId: json['documentPublicId'] ?? json['attachmentPublicId'],
      rejectedReason: json['rejectedReason'] ?? json['rejectionReason'],
      approvedBy: json['approvedBy'] is Map<String, dynamic>
          ? (json['approvedBy']['_id'] ?? json['approvedBy']['id'])?.toString()
          : json['approvedBy']?.toString(),
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
      'leaveType': leaveType,
      'startDate': startDate,
      'endDate': endDate,
      'daysCount': daysCount,
      'reason': reason,
      'status': status,
      'isBackdated': isBackdated,
      'backdatedLabel': backdatedLabel,
      'documentUrl': documentUrl,
      'documentPublicId': documentPublicId,
      'rejectedReason': rejectedReason,
      'approvedBy': approvedBy,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Get leave type display name
  String get leaveTypeName {
    final normalized = leaveType.trim().toUpperCase();
    switch (normalized) {
      case 'PL':
      case 'PERSONAL':
      case 'PERSONAL LEAVE':
        return 'Personal Leave';
      case 'CL':
      case 'CASUAL':
      case 'CASUAL LEAVE':
        return 'Casual Leave';
      case 'SL':
      case 'SICK':
      case 'SICK LEAVE':
        return 'Sick Leave';
      case 'EXTRA':
      case 'HOLIDAY':
        return 'Special Leave';
      default:
        return leaveType;
    }
  }

  /// Get number of days
  int get numberOfDays {
    if (daysCount != null && daysCount! > 0) {
      return daysCount!;
    }
    if (startDate.isEmpty || endDate.isEmpty) {
      return 0;
    }
    final start = _parseDateOnly(startDate);
    final end = _parseDateOnly(endDate);
    return end.difference(start).inDays + 1;
  }

  /// Check if leave is pending
  bool get isPending => status.trim().toUpperCase() == 'PENDING';

  /// Check if leave is approved
  bool get isApproved => status.trim().toUpperCase() == 'APPROVED';

  /// Check if leave is rejected
  bool get isRejected => status.trim().toUpperCase() == 'REJECTED';

  String get statusLabel {
    final normalized = status.trim().toUpperCase();
    if (normalized == 'APPROVED') return 'Approved';
    if (normalized == 'REJECTED') return 'Rejected';
    if (normalized == 'PENDING') return 'Pending';
    return status;
  }
}

/// Leave Quota Model
class LeaveQuota {
  final int pl; // Personal Leave
  final int cl; // Casual Leave
  final int sl; // Sick Leave

  LeaveQuota({required this.pl, required this.cl, required this.sl});

  factory LeaveQuota.fromJson(Map<String, dynamic> json) {
    return LeaveQuota(
      pl: json['pl'] ?? 0,
      cl: json['cl'] ?? 0,
      sl: json['sl'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'pl': pl, 'cl': cl, 'sl': sl};
  }

  /// Get quota for specific leave type
  int getQuota(String leaveType) {
    switch (leaveType) {
      case 'PL':
        return pl;
      case 'CL':
        return cl;
      case 'SL':
        return sl;
      default:
        return 0;
    }
  }
}

/// Apply Leave Request Model
class ApplyLeaveRequest {
  final String leaveType;
  final String startDate;
  final String endDate;
  final String reason;

  ApplyLeaveRequest({
    required this.leaveType,
    required this.startDate,
    required this.endDate,
    required this.reason,
  });

  Map<String, dynamic> toJson() {
    final normalizedType = leaveType.trim().toUpperCase();
    final backendType = switch (normalizedType) {
      'PL' || 'PERSONAL' || 'PERSONAL LEAVE' => 'Personal',
      'CL' || 'CASUAL' || 'CASUAL LEAVE' => 'Casual',
      'SL' || 'SICK' || 'SICK LEAVE' => 'Sick',
      'EXTRA' => 'Extra',
      _ => leaveType,
    };

    return {
      'leaveType': backendType,
      'startDate': startDate,
      'endDate': endDate,
      'reason': reason,
    };
  }
}
