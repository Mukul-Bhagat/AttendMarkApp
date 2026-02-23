import '../core/network/dio_client.dart';
import '../config/api_config.dart';
import '../models/leave_model.dart';
import '../core/utils/logger.dart';

class LeaveDashboardData {
  final List<LeaveModel> leaves;
  final LeaveQuota? quota;

  LeaveDashboardData({required this.leaves, required this.quota});
}

/// Leave Service
/// Handles all leave-related API calls
class LeaveService {
  final DioClient _dioClient;
  
  LeaveService(this._dioClient);
  
  /// Apply for leave
  Future<LeaveModel> applyLeave(ApplyLeaveRequest request) async {
    try {
      Logger.i('LeaveService', 'Applying for leave');
      
      final response = await _dioClient.post(
        ApiConfig.applyLeave,
        data: request.toJson(),
      );
      
      Logger.i('LeaveService', 'Leave applied successfully');
      return LeaveModel.fromJson(
        response.data['leaveRequest'] ?? response.data['leave'] ?? response.data,
      );
    } catch (e) {
      Logger.e('LeaveService', 'Failed to apply leave', e);
      rethrow;
    }
  }

  /// Get my leaves and quota in one request
  /// Backend route: GET /api/leaves/my-leaves
  Future<LeaveDashboardData> getMyLeavesDashboardData() async {
    try {
      Logger.i('LeaveService', 'Fetching my leaves dashboard');

      final response = await _dioClient.get('${ApiConfig.leaves}/my-leaves');
      final data = response.data;

      final List<dynamic> leavesJson = data is Map<String, dynamic>
          ? (data['leaves'] ?? data['data'] ?? [])
          : (data is List ? data : []);

      final leaves = leavesJson
          .map((json) => LeaveModel.fromJson(json as Map<String, dynamic>))
          .toList();

      LeaveQuota? quota;
      if (data is Map<String, dynamic> && data['quota'] is Map<String, dynamic>) {
        quota = LeaveQuota.fromJson(data['quota'] as Map<String, dynamic>);
      }

      Logger.i(
        'LeaveService',
        'Fetched leave dashboard: ${leaves.length} leaves, quota: ${quota != null}',
      );
      return LeaveDashboardData(leaves: leaves, quota: quota);
    } catch (e) {
      Logger.e('LeaveService', 'Failed to fetch leave dashboard', e);
      rethrow;
    }
  }
  
  /// Get my leave requests
  Future<List<LeaveModel>> getMyLeaves() async {
    try {
      final dashboard = await getMyLeavesDashboardData();
      return dashboard.leaves;
    } catch (e) {
      Logger.e('LeaveService', 'Failed to fetch leaves', e);
      rethrow;
    }
  }
  
  /// Get leave by ID
  Future<LeaveModel> getLeaveById(String leaveId) async {
    try {
      Logger.i('LeaveService', 'Fetching leave: $leaveId');
      
      final response = await _dioClient.get(
        ApiConfig.leaveById(leaveId),
      );
      
      Logger.i('LeaveService', 'Leave fetched successfully');
      return LeaveModel.fromJson(response.data['leave'] ?? response.data);
    } catch (e) {
      Logger.e('LeaveService', 'Failed to fetch leave', e);
      rethrow;
    }
  }
  
  /// Get leave quota/balance
  Future<LeaveQuota> getLeaveQuota() async {
    try {
      final dashboard = await getMyLeavesDashboardData();
      if (dashboard.quota != null) {
        return dashboard.quota!;
      }
      Logger.w('LeaveService', 'Quota missing in response, defaulting to zeros');
      return LeaveQuota(pl: 0, cl: 0, sl: 0);
    } catch (e) {
      Logger.e('LeaveService', 'Failed to fetch leave quota', e);
      rethrow;
    }
  }
}

