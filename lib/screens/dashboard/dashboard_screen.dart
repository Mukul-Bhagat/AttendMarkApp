import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/branding/brand_widgets.dart';
import '../../core/utils/logger.dart';
import '../../models/session_model.dart';
import '../../models/user_model.dart';
import '../../providers/attendance_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/session_provider.dart';
import '../sessions/session_qr_screen.dart';

/// Dashboard Screen
/// Light-mode dashboard aligned to web UI
class DashboardScreen extends StatefulWidget {
  final ValueChanged<int>? onTabChangeRequested;

  const DashboardScreen({super.key, this.onTabChangeRequested});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const Color _pageBackground = Color(0xFFF9FAFB);
  static const Color _surface = Colors.white;
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _muted = Color(0xFF64748B);

  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadDashboardData();
    });
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  Future<void> _loadDashboardData() async {
    try {
      final sessionProvider = context.read<SessionProvider>();
      final attendanceProvider = context.read<AttendanceProvider>();
      await Future.wait([
        sessionProvider.getSessions(),
        attendanceProvider.getMyAttendance(),
      ]);
    } catch (e) {
      Logger.e('DashboardScreen', 'Failed to load dashboard data', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final sessionProvider = context.watch<SessionProvider>();
    final attendanceProvider = context.watch<AttendanceProvider>();
    final user = authProvider.user;

    final sessions = sessionProvider.sessions;
    final attendance = attendanceProvider.myAttendance;
    final todaySessions = _getTodaySessions(sessions);
    final upcomingSessions = _getUpcomingSessions(sessions);

    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: _surface,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 16,
        title: const AppBrandLogo(size: 34),
        actions: [
          IconButton(
            onPressed: _loadDashboardData,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: _buildUserBadge(user),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboardData,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
          children: [
            const Text(
              'Dashboard',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(height: 16),
            _buildWelcomeCard(user),
            const SizedBox(height: 16),
            if (sessionProvider.error != null && sessions.isEmpty)
              _buildErrorCard(sessionProvider.error!)
            else
              _buildStatsGrid(
                user: user,
                todaySessionsCount: todaySessions.length,
                attendanceRecords: attendance.length,
                lateDays: attendance.where((record) => record.isLate).length,
              ),
            const SizedBox(height: 16),
            _buildQuickScanCard(),
            const SizedBox(height: 16),
            _buildUpcomingSection(
              isLoading: sessionProvider.isLoading,
              sessions: upcomingSessions,
            ),
            const SizedBox(height: 16),
            _buildAttendanceSummary(attendance),
            if (user != null && _canShowAdminQr(user)) ...[
              const SizedBox(height: 16),
              _buildAdminQrSection(sessions),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildUserBadge(UserModel? user) {
    final initials = _getInitials(user?.name ?? user?.email ?? 'AU');
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: const Color(0xFFFFF1F2),
        shape: BoxShape.circle,
        border: Border.all(color: const Color(0xFFFFE4E6)),
      ),
      child: Center(
        child: Text(
          initials,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 11,
            color: Color(0xFFE11D48),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(UserModel? user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x110F172A),
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _getGreeting(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            user == null ? 'Welcome!' : 'Welcome back, ${user.name}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF334155),
            ),
          ),
          if (user != null) ...[
            const SizedBox(height: 6),
            Text(
              user.role,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _muted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsGrid({
    required UserModel? user,
    required int todaySessionsCount,
    required int attendanceRecords,
    required int lateDays,
  }) {
    final onTimeDays = attendanceRecords - lateDays;
    final onTimePercent = attendanceRecords == 0
        ? 0
        : ((onTimeDays / attendanceRecords) * 100).round();

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.25,
      children: [
        _buildStatCard(
          icon: Icons.domain,
          accent: const Color(0xFFE11D48),
          label: 'Organization',
          value: _organizationLabel(user),
        ),
        _buildStatCard(
          icon: Icons.groups_2_outlined,
          accent: const Color(0xFFF59E0B),
          label: 'Today Sessions',
          value: '$todaySessionsCount',
        ),
        _buildStatCard(
          icon: Icons.fact_check_outlined,
          accent: const Color(0xFFF59E0B),
          label: 'My Records',
          value: '$attendanceRecords',
        ),
        _buildStatCard(
          icon: Icons.check_circle_outline,
          accent: const Color(0xFFE11D48),
          label: 'On-Time',
          value: '$onTimePercent%',
          helper: attendanceRecords == 0 ? 'No records yet' : 'This period',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color accent,
    required String label,
    required String value,
    String? helper,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F0F172A),
            blurRadius: 14,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: accent, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: _muted,
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          if (helper != null) ...[
            const SizedBox(height: 2),
            Text(
              helper,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: _muted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildQuickScanCard() {
    return InkWell(
      onTap: () {
        Navigator.of(context).pushNamed('/scan');
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _border),
        ),
        child: Row(
          children: [
            Container(
              width: 54,
              height: 54,
              decoration: BoxDecoration(
                color: const Color(0xFFFFF1F2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                color: Color(0xFFE11D48),
                size: 30,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Scan',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Mark your attendance',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _muted,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 30, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingSection({
    required bool isLoading,
    required List<SessionModel> sessions,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Upcoming Sessions',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/sessions');
                },
                child: const Text('View All'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (isLoading && sessions.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (sessions.isEmpty)
            _buildInlineInfo('No upcoming sessions')
          else
            ...sessions.take(3).map(_buildUpcomingTile),
        ],
      ),
    );
  }

  Widget _buildUpcomingTile(SessionModel session) {
    final startsAt = _getSessionDateTime(session);
    final dateLabel = startsAt == null
        ? _fallbackSessionDateLabel(session)
        : DateFormat('d MMM y, hh:mm a').format(startsAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFFFFF1F2),
            ),
            child: const Icon(Icons.calendar_today, color: Color(0xFFE11D48)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.title.isEmpty ? 'Unnamed Session' : session.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  dateLabel,
                  style: const TextStyle(fontSize: 12, color: _muted),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Color(0xFFCBD5E1)),
        ],
      ),
    );
  }

  Widget _buildAttendanceSummary(List attendance) {
    final totalRecords = attendance.length;
    final lateDays = attendance.where((record) => record.isLate).length;
    final onTimeDays = totalRecords - lateDays;
    final onTimePercent = totalRecords == 0
        ? 0
        : ((onTimeDays / totalRecords) * 100).round();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Attendance Summary',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildSummaryChip(
                  label: 'Total',
                  value: '$totalRecords',
                  color: const Color(0xFF0EA5E9),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryChip(
                  label: 'On Time',
                  value: '$onTimeDays',
                  color: const Color(0xFF10B981),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildSummaryChip(
                  label: 'Late',
                  value: '$lateDays',
                  color: const Color(0xFFF59E0B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: totalRecords == 0 ? 0 : onTimeDays / totalRecords,
              minHeight: 8,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF10B981),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$onTimePercent% on-time performance',
            style: const TextStyle(
              fontSize: 12,
              color: _muted,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: _openAttendance,
              child: const Text('View My Attendance'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryChip({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminQrSection(List<SessionModel> allSessions) {
    final sessions = _getUpcomingTwoHourQrSessions(allSessions);
    if (sessions.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session QR (Live / Upcoming)',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'No live or upcoming sessions are available for QR display.',
              style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 12),
            ),
          ],
        ),
      );
    }

    final session = sessions.first;
    final startsAt = _getSessionDateTime(session);
    final expiresAt = session.qrExpiresAt;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Session QR (Live / Upcoming)',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          if (sessions.length > 1) ...[
            const SizedBox(height: 4),
            Text(
              '${sessions.length} sessions available',
              style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 11),
            ),
          ],
          const SizedBox(height: 6),
          Text(
            session.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (startsAt != null) ...[
            const SizedBox(height: 4),
            Text(
              'Starts: ${DateFormat('d MMM y, hh:mm a').format(startsAt)}',
              style: const TextStyle(color: Color(0xFFCBD5E1), fontSize: 12),
            ),
          ],
          if (expiresAt != null) ...[
            const SizedBox(height: 2),
            Text(
              'Expires in ${_formatRemaining(expiresAt)}',
              style: const TextStyle(
                color: Color(0xFFFDA4AF),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Center(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: QrImageView(
                data: session.id,
                size: 180,
                backgroundColor: Colors.white,
                errorCorrectionLevel: QrErrorCorrectLevel.H,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SessionQRScreen(session: session),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFF87171)),
              ),
              icon: const Icon(Icons.open_in_new),
              label: const Text('Open Full QR View'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorCard(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Could not load dashboard data',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFFB91C1C),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            message,
            style: const TextStyle(color: Color(0xFF991B1B), fontSize: 12),
          ),
          const SizedBox(height: 10),
          TextButton(onPressed: _loadDashboardData, child: const Text('Retry')),
        ],
      ),
    );
  }

  Widget _buildInlineInfo(String text) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFFF8FAFC),
        border: Border.all(color: _border),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: _muted,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _openAttendance() {
    if (widget.onTabChangeRequested != null) {
      widget.onTabChangeRequested!(2);
      return;
    }
    Navigator.of(context).pushNamed('/my-attendance');
  }

  bool _canShowAdminQr(UserModel user) {
    return user.isAdmin || user.isManager;
  }

  String _organizationLabel(UserModel? user) {
    if (user == null) return 'N/A';
    if (user.organizationName != null &&
        user.organizationName!.trim().isNotEmpty) {
      return user.organizationName!.trim();
    }
    if (user.organizationId != null && user.organizationId!.trim().isNotEmpty) {
      final orgId = user.organizationId!.trim();
      if (_looksLikeMongoObjectId(orgId)) {
        return 'Organization';
      }
      return orgId;
    }
    return 'Organization';
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getInitials(String input) {
    final tokens = input
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return 'AU';
    if (tokens.length == 1) {
      return tokens.first.substring(0, 1).toUpperCase();
    }
    final first = tokens[0].substring(0, 1);
    final second = tokens[1].substring(0, 1);
    return '$first$second'.toUpperCase();
  }

  List<SessionModel> _getTodaySessions(List<SessionModel> sessions) {
    final now = DateTime.now();
    return sessions.where((session) {
      final startsAt = _getSessionDateTime(session);
      if (startsAt == null) return false;
      return startsAt.year == now.year &&
          startsAt.month == now.month &&
          startsAt.day == now.day;
    }).toList();
  }

  List<SessionModel> _getUpcomingSessions(List<SessionModel> sessions) {
    final now = DateTime.now();
    final upcoming = sessions.where((session) {
      final startsAt = _getSessionDateTime(session);
      if (startsAt == null) return false;
      return startsAt.isAfter(now.subtract(const Duration(minutes: 1)));
    }).toList();

    upcoming.sort((a, b) {
      final aTime = _getSessionDateTime(a) ?? DateTime(2100);
      final bTime = _getSessionDateTime(b) ?? DateTime(2100);
      return aTime.compareTo(bTime);
    });
    return upcoming;
  }

  List<SessionModel> _getUpcomingTwoHourQrSessions(
    List<SessionModel> sessions,
  ) {
    final now = DateTime.now();
    final cutOff = now.add(const Duration(hours: 2));

    final available = sessions.where((session) {
      if (session.canShowQr != true) {
        return false;
      }
      if (session.qrExpiresAt != null && !session.qrExpiresAt!.isAfter(now)) {
        return false;
      }

      final startsAt = _getSessionDateTime(session);
      if (startsAt == null) {
        return true;
      }

      final endsAt = _getSessionEndDateTime(session, startsAt);
      final isLive = endsAt != null
          ? (!now.isBefore(startsAt) && !now.isAfter(endsAt))
          : !now.isBefore(startsAt);
      final isUpcoming = startsAt.isAfter(now) && !startsAt.isAfter(cutOff);
      return isLive || isUpcoming;
    }).toList();

    available.sort((a, b) {
      final aTime = _getSessionDateTime(a) ?? DateTime(2100);
      final bTime = _getSessionDateTime(b) ?? DateTime(2100);
      final aLive = _isSessionLive(a, now);
      final bLive = _isSessionLive(b, now);
      if (aLive != bLive) {
        return aLive ? -1 : 1;
      }
      return aTime.compareTo(bTime);
    });

    return available;
  }

  DateTime? _getSessionDateTime(SessionModel session) {
    final startDate = session.startDate;
    if (startDate == null) return null;

    final parsedTime = _parseTime(session.startTime);
    if (parsedTime == null) {
      return DateTime(startDate.year, startDate.month, startDate.day);
    }

    return DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
      parsedTime.hour,
      parsedTime.minute,
    );
  }

  TimeOfDay? _parseTime(String value) {
    final trimmed = value.trim();
    final match = RegExp(
      r'^(\d{1,2}):(\d{2})(?:\s*([AaPp][Mm]))?$',
    ).firstMatch(trimmed);
    if (match == null) return null;

    int hour = int.tryParse(match.group(1) ?? '') ?? -1;
    final minute = int.tryParse(match.group(2) ?? '') ?? -1;
    final meridiem = match.group(3)?.toUpperCase();

    if (hour < 0 || minute < 0 || minute > 59) return null;

    if (meridiem != null) {
      if (hour == 12) {
        hour = meridiem == 'AM' ? 0 : 12;
      } else if (meridiem == 'PM') {
        hour += 12;
      }
    }

    if (hour < 0 || hour > 23) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  DateTime? _getSessionEndDateTime(SessionModel session, DateTime startsAt) {
    final parsedEnd = _parseTime(session.endTime);
    if (parsedEnd == null) return null;
    var end = DateTime(
      startsAt.year,
      startsAt.month,
      startsAt.day,
      parsedEnd.hour,
      parsedEnd.minute,
    );
    if (end.isBefore(startsAt)) {
      end = end.add(const Duration(days: 1));
    }
    return end;
  }

  bool _isSessionLive(SessionModel session, DateTime now) {
    final startsAt = _getSessionDateTime(session);
    if (startsAt == null) return false;

    final endsAt = _getSessionEndDateTime(session, startsAt);
    if (endsAt == null) {
      return !now.isBefore(startsAt);
    }
    return !now.isBefore(startsAt) && !now.isAfter(endsAt);
  }

  bool _looksLikeMongoObjectId(String value) {
    return RegExp(r'^[a-fA-F0-9]{24}$').hasMatch(value);
  }

  String _fallbackSessionDateLabel(SessionModel session) {
    if (session.startDate != null) {
      final dateLabel = DateFormat('d MMM y').format(session.startDate!);
      return '$dateLabel, ${session.startTime}';
    }
    return '${session.startTime} - ${session.endTime}';
  }

  String _formatRemaining(DateTime expiresAt) {
    final difference = expiresAt.difference(DateTime.now());
    if (difference.isNegative) return 'Expired';

    final hours = difference.inHours;
    final minutes = difference.inMinutes.remainder(60);
    final seconds = difference.inSeconds.remainder(60);

    if (hours > 0) return '${hours}h ${minutes}m';
    if (minutes > 0) return '${minutes}m ${seconds}s';
    return '${seconds}s';
  }
}
