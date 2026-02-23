import 'package:flutter/material.dart';
import '../models/leave_model.dart';
import '../services/leave_service.dart';
import '../core/utils/logger.dart';

/// Leave Provider
/// Manages leave state and data
class LeaveProvider with ChangeNotifier {
  final LeaveService _leaveService;

  List<LeaveModel> _myLeaves = [];
  LeaveQuota? _leaveQuota;
  bool _isLoading = false;
  String? _error;

  LeaveProvider(this._leaveService);

  // Getters
  List<LeaveModel> get myLeaves => _myLeaves;
  LeaveQuota? get leaveQuota => _leaveQuota;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Get my leave requests
  Future<void> getMyLeaves() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Logger.i('LeaveProvider', 'Fetching my leaves');
      final dashboard = await _leaveService.getMyLeavesDashboardData();
      _myLeaves = dashboard.leaves;
      if (dashboard.quota != null) {
        _leaveQuota = dashboard.quota;
      }
      _myLeaves.sort(_sortLeavesByNewest);

      _isLoading = false;
      notifyListeners();

      Logger.i('LeaveProvider', 'Fetched ${_myLeaves.length} leave requests');
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      Logger.e('LeaveProvider', 'Failed to fetch leaves', e);
    }
  }

  /// Get leave quota
  Future<void> getLeaveQuota() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Logger.i('LeaveProvider', 'Fetching leave quota');
      final dashboard = await _leaveService.getMyLeavesDashboardData();
      _leaveQuota = dashboard.quota ?? LeaveQuota(pl: 0, cl: 0, sl: 0);
      _myLeaves = dashboard.leaves;
      _myLeaves.sort(_sortLeavesByNewest);

      _isLoading = false;
      notifyListeners();

      Logger.i('LeaveProvider', 'Leave quota fetched successfully');
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      Logger.e('LeaveProvider', 'Failed to fetch leave quota', e);
    }
  }

  /// Apply for leave
  Future<LeaveModel> applyLeave(ApplyLeaveRequest request) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Logger.i('LeaveProvider', 'Applying for leave');

      final leave = await _leaveService.applyLeave(request);

      // Refresh leave list + quota from server after creation.
      final dashboard = await _leaveService.getMyLeavesDashboardData();
      _myLeaves = dashboard.leaves;
      _myLeaves.sort(_sortLeavesByNewest);
      _leaveQuota = dashboard.quota ?? _leaveQuota;

      _isLoading = false;
      notifyListeners();

      Logger.i('LeaveProvider', 'Leave applied successfully');
      return leave;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      Logger.e('LeaveProvider', 'Failed to apply leave', e);
      rethrow;
    }
  }

  /// Get pending leaves
  List<LeaveModel> getPendingLeaves() {
    return _myLeaves.where((l) => l.isPending).toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  /// Get approved leaves
  List<LeaveModel> getApprovedLeaves() {
    return _myLeaves.where((l) => l.isApproved).toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  /// Get rejected leaves
  List<LeaveModel> getRejectedLeaves() {
    return _myLeaves.where((l) => l.isRejected).toList()
      ..sort((a, b) => b.startDate.compareTo(a.startDate));
  }

  /// Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Refresh leaves
  Future<void> refresh() async {
    await getMyLeaves();
  }

  int _sortLeavesByNewest(LeaveModel a, LeaveModel b) {
    final aCreated = a.createdAt?.millisecondsSinceEpoch;
    final bCreated = b.createdAt?.millisecondsSinceEpoch;
    if (aCreated != null && bCreated != null) {
      return bCreated.compareTo(aCreated);
    }
    if (aCreated != null) return -1;
    if (bCreated != null) return 1;
    return b.startDate.compareTo(a.startDate);
  }
}
