
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/attendance_model.dart';
import '../../providers/attendance_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loaders.dart';

class MyAttendanceScreen extends StatefulWidget {
  const MyAttendanceScreen({super.key});

  @override
  State<MyAttendanceScreen> createState() => _MyAttendanceScreenState();
}

class _MyAttendanceScreenState extends State<MyAttendanceScreen> {
  static const Color _bg = Color(0xFFF9FAFB);
  static const Color _card = Colors.white;
  static const Color _border = Color(0xFFF1F5F9);
  static const Color _primary = Color(0xFFF97316);
  static const Color _absent = Color(0xFFEF4444);
  static const Color _present = Color(0xFF22C55E);
  static const Color _muted = Color(0xFF64748B);

  final PageController _analyticsController = PageController();
  int _analyticsIndex = 0;
  final String _searchQuery = '';

  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadAttendance();
    });
  }

  @override
  void dispose() {
    _analyticsController.dispose();
    super.dispose();
  }

  Future<void> _loadAttendance() async {
    final attendanceProvider = context.read<AttendanceProvider>();
    final start = DateTime(_startDate.year, _startDate.month, _startDate.day);
    final end = DateTime(
      _endDate.year,
      _endDate.month,
      _endDate.day,
      23,
      59,
      59,
    );
    await attendanceProvider.getMyAttendance(startDate: start, endDate: end);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: _card,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        title: const Text(
          'My Attendance',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            color: Color(0xFF111827),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAttendance,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<AttendanceProvider>(
        builder: (context, attendanceProvider, child) {
          if (attendanceProvider.isLoading &&
              attendanceProvider.myAttendance.isEmpty) {
            return const CenterLoader();
          }

          if (attendanceProvider.error != null &&
              attendanceProvider.myAttendance.isEmpty) {
            return ErrorView(
              message: attendanceProvider.error!,
              onRetry: _loadAttendance,
              isLoading: attendanceProvider.isLoading,
            );
          }

          final records = List<AttendanceModel>.from(
            attendanceProvider.myAttendance,
          )..sort((a, b) => b.checkInTime.compareTo(a.checkInTime));

          final summary = _computeSummary(records);
          final weekly = _buildWeeklyBuckets(summary.dayStatusByDate);
          final logs = _filterLogs(records);

          return RefreshIndicator(
            onRefresh: _loadAttendance,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              children: [
                const Text(
                  'Track your presence, analytics and session history',
                  style: TextStyle(
                    color: _muted,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showSnack('Share is available on web dashboard.'),
                        icon: const Icon(Icons.share_outlined),
                        label: const Text('Share'),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1F2937),
                          side: const BorderSide(color: Color(0xFFE5E7EB)),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showSnack(
                          'Download report is available on web dashboard.',
                        ),
                        icon: const Icon(Icons.download_outlined),
                        label: const Text('Download'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF111827),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDateFilterCard(),
                const SizedBox(height: 16),
                SizedBox(
                  height: 360,
                  child: PageView(
                    controller: _analyticsController,
                    onPageChanged: (index) {
                      setState(() {
                        _analyticsIndex = index;
                      });
                    },
                    children: [
                      _buildDonutCard(summary),
                      _buildWeeklyGraphCard(weekly),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _pageDot(_analyticsIndex == 0),
                    const SizedBox(width: 6),
                    _pageDot(_analyticsIndex == 1),
                    const SizedBox(width: 12),
                    Text(
                      _analyticsIndex == 0
                          ? 'Swipe left to view graph'
                          : 'Swipe right to view donut',
                      style: const TextStyle(
                        fontSize: 11,
                        color: _muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildPerformanceSummary(summary),
                const SizedBox(height: 16),
                _buildLogsSection(logs),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateFilterCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.calendar_today_outlined, color: _primary, size: 18),
              SizedBox(width: 8),
              Text(
                'Select Date Range',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  label: 'Start Date',
                  value: _startDate,
                  onTap: () async {
                    final picked = await _pickDate(
                      _startDate,
                      DateTime(2020),
                      _endDate,
                    );
                    if (picked == null) return;
                    setState(() {
                      _startDate = picked;
                    });
                  },
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDateField(
                  label: 'End Date',
                  value: _endDate,
                  onTap: () async {
                    final picked = await _pickDate(
                      _endDate,
                      _startDate,
                      DateTime.now(),
                    );
                    if (picked == null) return;
                    setState(() {
                      _endDate = picked;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _loadAttendance,
              icon: const Icon(Icons.insights_outlined),
              label: const Text('View Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Color(0xFF9CA3AF),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              DateFormat('dd MMM yyyy').format(value),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1F2937),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<DateTime?> _pickDate(
    DateTime initial,
    DateTime first,
    DateTime last,
  ) async {
    return showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: last,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: _primary,
              onPrimary: Colors.white,
              onSurface: Color(0xFF1F2937),
            ),
          ),
          child: child!,
        );
      },
    );
  }

  _AttendanceSummary _computeSummary(List<AttendanceModel> records) {
    int present = 0;
    int late = 0;
    final Map<DateTime, String> dayStatus = {};

    for (final record in records) {
      if (record.isLate) {
        late++;
      } else {
        present++;
      }
      final date = DateTime(
        record.checkInTime.year,
        record.checkInTime.month,
        record.checkInTime.day,
      );
      dayStatus[date] = record.isLate ? 'Late' : 'Present';
    }

    return _AttendanceSummary(
      total: records.length,
      present: present,
      late: late,
      absent: 0,
      dayStatusByDate: dayStatus,
    );
  }

  List<_WeeklyData> _buildWeeklyBuckets(Map<DateTime, String> dayStatus) {
    final List<_WeeklyData> buckets = [];
    for (int i = 3; i >= 0; i--) {
      final weekStart = _endDate.subtract(
        Duration(days: (i * 7) + _endDate.weekday - 1),
      );
      int count = 0;
      for (int j = 0; j < 7; j++) {
        final day = weekStart.add(Duration(days: j));
        final dateKey = DateTime(day.year, day.month, day.day);
        if (dayStatus.containsKey(dateKey)) {
          count++;
        }
      }
      buckets.add(_WeeklyData(label: 'W${4 - i}', count: count));
    }
    return buckets;
  }

  List<AttendanceModel> _filterLogs(List<AttendanceModel> records) {
    if (_searchQuery.isEmpty) return records;
    return records;
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: _primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildDonutCard(_AttendanceSummary summary) {
    final total = summary.total == 0 ? 1 : summary.total;
    final presentPct = summary.present / total;
    final latePct = summary.late / total;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: [
          const Text(
            'Attendance Overview',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 150,
            width: 150,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: 1.0,
                  color: _bg,
                  strokeWidth: 12,
                ),
                CircularProgressIndicator(
                  value: presentPct + latePct,
                  color: _primary,
                  backgroundColor: Colors.transparent,
                  strokeWidth: 12,
                ),
                CircularProgressIndicator(
                  value: presentPct,
                  color: _present,
                  backgroundColor: Colors.transparent,
                  strokeWidth: 12,
                ),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${((presentPct + latePct) * 100).toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Present',
                        style: TextStyle(fontSize: 12, color: _muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _legendItem('Present', _present),
              _legendItem('Late', _primary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _legendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: _muted)),
      ],
    );
  }

  Widget _buildWeeklyGraphCard(List<_WeeklyData> weekly) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Trends',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weekly.map((data) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      width: 20,
                      height: (data.count * 20.0).clamp(10.0, 150.0),
                      decoration: BoxDecoration(
                        color: _primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      data.label,
                      style: const TextStyle(fontSize: 10, color: _muted),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _pageDot(bool isActive) {
    return Container(
      height: 6,
      width: isActive ? 20 : 6,
      decoration: BoxDecoration(
        color: isActive ? _primary : _border,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildPerformanceSummary(_AttendanceSummary summary) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _border),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _statItem('Total', summary.total.toString(), Colors.black),
          _statItem('Present', summary.present.toString(), _present),
          _statItem('Late', summary.late.toString(), _primary),
          _statItem('Absent', summary.absent.toString(), _absent),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(label, style: const TextStyle(fontSize: 11, color: _muted)),
      ],
    );
  }

  Widget _buildLogsSection(List<AttendanceModel> logs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...logs.take(10).map((log) => _buildLogItem(log)),
      ],
    );
  }

  Widget _buildLogItem(AttendanceModel log) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: log.isLate
                  ? _primary.withValues(alpha: 0.1)
                  : _present.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              log.isLate
                  ? Icons.access_time_rounded
                  : Icons.check_circle_outline,
              color: log.isLate ? _primary : _present,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('EEE, MMM d').format(log.checkInTime),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  DateFormat('h:mm a').format(log.checkInTime),
                  style: const TextStyle(color: _muted, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: log.isLate
                  ? _primary.withValues(alpha: 0.1)
                  : _present.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              log.isLate ? 'Late' : 'On Time',
              style: TextStyle(
                color: log.isLate ? _primary : _present,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AttendanceSummary {
  final int total;
  final int present;
  final int absent;
  final int late;
  final Map<DateTime, String> dayStatusByDate;

  _AttendanceSummary({
    required this.total,
    required this.present,
    required this.absent,
    required this.late,
    required this.dayStatusByDate,
  });
}

class _WeeklyData {
  final String label;
  final int count;

  _WeeklyData({required this.label, required this.count});
}

