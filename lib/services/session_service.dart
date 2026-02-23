import '../core/network/dio_client.dart';
import '../config/api_config.dart';
import '../models/session_model.dart';
import '../core/utils/logger.dart';

/// Session Service
/// Handles session-related API calls
class SessionService {
  final DioClient _dioClient;
  
  SessionService(this._dioClient);
  
  /// Get all sessions
  /// GET /api/sessions
  /// Backend returns sessions with canShowQr and qrExpiresAt
  Future<List<SessionModel>> getSessions() async {
    try {
      Logger.i('SessionService', 'Fetching sessions from /api/sessions');
      
      final response = await _dioClient.get(ApiConfig.sessions);
      
      // Handle different response formats
      final List<dynamic> sessionsJson = response.data is List
          ? response.data
          : response.data['sessions'] ?? [];
      
      final sessions = sessionsJson
          .map((json) => SessionModel.fromJson(json))
          .toList();
      
      Logger.i('SessionService', 'Fetched ${sessions.length} sessions');
      Logger.d('SessionService', 'Sessions with QR: ${sessions.where((s) => s.canShowQr == true).length}');
      
      return sessions;
    } catch (e) {
      Logger.e('SessionService', 'Failed to fetch sessions', e);
      rethrow;
    }
  }
}
