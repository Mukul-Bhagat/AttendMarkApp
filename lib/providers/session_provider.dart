import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../models/session_model.dart';
import '../services/session_service.dart';
import '../core/utils/logger.dart';

/// Session Provider
/// Manages session state and data
class SessionProvider with ChangeNotifier {
  final SessionService _sessionService;
  
  List<SessionModel> _sessions = [];
  bool _isLoading = false;
  String? _error;
  
  SessionProvider(this._sessionService);

  /// Avoid "setState/markNeedsBuild called during build" by deferring
  /// notifications if we are currently in the build phase.
  void _notifySafely() {
    if (!hasListeners) return;

    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (hasListeners) {
          notifyListeners();
        }
      });
      return;
    }

    notifyListeners();
  }
  
  // Getters
  List<SessionModel> get sessions => _sessions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  /// Get all sessions
  /// Fetches from backend - QR rules come from backend
  Future<void> getSessions() async {
    _isLoading = true;
    _error = null;
    _notifySafely();
    
    try {
      Logger.i('SessionProvider', 'Fetching sessions');
      
      _sessions = await _sessionService.getSessions();
      
      _isLoading = false;
      _notifySafely();
      
      Logger.i('SessionProvider', 'Fetched ${_sessions.length} sessions');
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      _notifySafely();
      Logger.e('SessionProvider', 'Failed to fetch sessions', e);
    }
  }
  
  /// Get today's sessions
  /// Filters by date (simple date comparison)
  List<SessionModel> getTodaySessions() {
    final today = DateTime.now();
    return _sessions.where((session) {
      if (session.startDate == null) return false;
      final sessionDate = session.startDate!;
      return sessionDate.year == today.year &&
             sessionDate.month == today.month &&
             sessionDate.day == today.day;
    }).toList();
  }
  
  /// Get upcoming sessions
  /// Filters sessions that are after today
  List<SessionModel> getUpcomingSessions() {
    final today = DateTime.now();
    return _sessions.where((session) {
      if (session.startDate == null) return false;
      final sessionDate = session.startDate!;
      // Upcoming = date is after today
      return sessionDate.isAfter(DateTime(today.year, today.month, today.day));
    }).toList()
      ..sort((a, b) => a.startDate!.compareTo(b.startDate!));
  }
  
  /// Get past sessions
  /// Filters sessions that are before today
  List<SessionModel> getPastSessions() {
    final today = DateTime.now();
    return _sessions.where((session) {
      if (session.startDate == null) return false;
      final sessionDate = session.startDate!;
      // Past = date is before today
      return sessionDate.isBefore(DateTime(today.year, today.month, today.day));
    }).toList()
      ..sort((a, b) => b.startDate!.compareTo(a.startDate!));
  }
  
  /// Clear error
  void clearError() {
    _error = null;
    _notifySafely();
  }
  
  /// Refresh sessions
  Future<void> refresh() async {
    await getSessions();
  }
}
