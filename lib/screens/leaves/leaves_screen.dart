import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../models/leave_model.dart';
import '../../providers/leave_provider.dart';
import '../../widgets/error_view.dart';
import '../../widgets/loaders.dart';

/// Leaves Screen
/// Easy-access leave dashboard for mobile users.
class LeavesScreen extends StatefulWidget {
  const LeavesScreen({super.key});

  @override
  State<LeavesScreen> createState() => _LeavesScreenState();
}

class _LeavesScreenState extends State<LeavesScreen> {
  static const Color _pageBackground = Color(0xFFF9FAFB);
  static const Color _surface = Colors.white;
  static const Color _border = Color(0xFFE5E7EB);
  static const Color _muted = Color(0xFF64748B);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadData();
    });
  }

  Future<void> _loadData() async {
    final leaveProvider = context.read<LeaveProvider>();
    await leaveProvider.getMyLeaves();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      appBar: AppBar(
        backgroundColor: _surface,
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 16,
        title: const Text(
          'Leave Management',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0F172A),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _showApplyLeaveDialog,
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Apply Leave',
          ),
        ],
      ),
      body: Consumer<LeaveProvider>(
        builder: (context, leaveProvider, child) {
          if (leaveProvider.isLoading &&
              leaveProvider.myLeaves.isEmpty &&
              leaveProvider.leaveQuota == null) {
            return const CenterLoader();
          }

          if (leaveProvider.error != null &&
              leaveProvider.myLeaves.isEmpty &&
              leaveProvider.leaveQuota == null) {
            return ErrorView(
              message: leaveProvider.error!,
              onRetry: _loadData,
              isLoading: leaveProvider.isLoading,
            );
          }

          final pendingLeaves =
              leaveProvider.myLeaves.where((leave) => leave.isPending).toList()
                ..sort((a, b) => b.startDate.compareTo(a.startDate));

          final historyLeaves =
              leaveProvider.myLeaves.where((leave) => !leave.isPending).toList()
                ..sort((a, b) {
                  final aDate = a.updatedAt ?? a.createdAt;
                  final bDate = b.updatedAt ?? b.createdAt;
                  if (aDate != null && bDate != null) {
                    return bDate.compareTo(aDate);
                  }
                  if (aDate != null) return -1;
                  if (bDate != null) return 1;
                  return b.startDate.compareTo(a.startDate);
                });

          return RefreshIndicator(
            onRefresh: _loadData,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
              children: [
                _buildQuotaScroller(
                  leaveProvider.leaveQuota,
                  leaveProvider.myLeaves,
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: _showApplyLeaveDialog,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.add_box_outlined),
                    label: const Text(
                      'Apply Leave',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildSectionTitle(
                  'Pending Requests (${pendingLeaves.length})',
                ),
                const SizedBox(height: 10),
                if (pendingLeaves.isEmpty)
                  _buildEmptyContainer(
                    icon: Icons.hourglass_top,
                    message: 'No pending leave requests.',
                  )
                else
                  ...pendingLeaves.map(
                    (leave) => _buildLeaveCard(leave, showChevron: true),
                  ),
                const SizedBox(height: 20),
                _buildSectionTitle('Leave History'),
                const SizedBox(height: 10),
                if (historyLeaves.isEmpty)
                  _buildEmptyContainer(
                    icon: Icons.history,
                    message: 'No leave requests found.',
                  )
                else
                  ...historyLeaves.map(
                    (leave) => _buildLeaveCard(leave, showChevron: false),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildQuotaScroller(LeaveQuota? quota, List<LeaveModel> allLeaves) {
    if (quota == null) {
      return _buildEmptyContainer(
        icon: Icons.calendar_today_outlined,
        message: 'Leave quota not available yet.',
      );
    }

    final approvedLeaves = allLeaves
        .where((leave) => leave.isApproved)
        .toList();

    final cards = [
      _QuotaCardData(
        leaveType: 'PL',
        label: 'Personal Leave',
        icon: Icons.calendar_today,
        color: const Color(0xFFE11D48),
      ),
      _QuotaCardData(
        leaveType: 'CL',
        label: 'Casual Leave',
        icon: Icons.event_available,
        color: const Color(0xFFF59E0B),
      ),
      _QuotaCardData(
        leaveType: 'SL',
        label: 'Sick Leave',
        icon: Icons.local_hospital,
        color: const Color(0xFFEF4444),
      ),
    ];

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: cards.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final item = cards[index];
          final total = quota.getQuota(item.leaveType);
          final used = approvedLeaves
              .where(
                (leave) =>
                    _normalizeLeaveType(leave.leaveType) == item.leaveType,
              )
              .fold<int>(0, (sum, leave) => sum + leave.numberOfDays);
          final remaining = (total - used).clamp(0, total).toInt();

          return Container(
            width: 270,
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
                    Icon(item.icon, size: 18, color: item.color),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.label,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  'Remaining: $remaining / Total: $total',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$used used',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: _muted,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeaveCard(LeaveModel leave, {required bool showChevron}) {
    final statusMeta = _statusMeta(leave);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: statusMeta.color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Icon(statusMeta.icon, size: 18, color: statusMeta.color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  leave.leaveTypeName,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${_formatDate(leave.startDate)} - ${_formatDate(leave.endDate)}',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                if (leave.isBackdated) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF7ED),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(color: const Color(0xFFFED7AA)),
                    ),
                    child: Text(
                      leave.backdatedLabel ?? 'Backdated Entry',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF9A3412),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 1),
                Text(
                  '${leave.numberOfDays} ${leave.numberOfDays == 1 ? 'day' : 'days'}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: _muted,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (leave.reason.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    leave.reason,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: _muted),
                  ),
                ],
                if (leave.isRejected &&
                    leave.rejectedReason != null &&
                    leave.rejectedReason!.trim().isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Text(
                      'Rejected: ${leave.rejectedReason}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: Color(0xFFB91C1C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusMeta.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: statusMeta.color.withValues(alpha: 0.35),
                  ),
                ),
                child: Text(
                  leave.statusLabel,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: statusMeta.color,
                  ),
                ),
              ),
              if (showChevron) ...[
                const SizedBox(height: 8),
                const Icon(
                  Icons.chevron_right,
                  size: 20,
                  color: Color(0xFFCBD5E1),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyContainer({
    required IconData icon,
    required String message,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _border, style: BorderStyle.solid),
      ),
      child: Column(
        children: [
          Icon(icon, size: 34, color: const Color(0xFFCBD5E1)),
          const SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: _muted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showApplyLeaveDialog() async {
    final leaveProvider = context.read<LeaveProvider>();
    final navigator = Navigator.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final formKey = GlobalKey<FormState>();
    final reasonController = TextEditingController();

    String selectedType = 'PL';
    DateTime? startDate;
    DateTime? endDate;
    bool isSubmitting = false;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            Future<void> pickStartDate() async {
              final picked = await _pickDate(
                context,
                initialDate: startDate ?? DateTime.now(),
                firstDate: DateTime(2000, 1, 1),
              );
              if (picked == null) return;

              setModalState(() {
                startDate = picked;
                if (endDate != null && endDate!.isBefore(startDate!)) {
                  endDate = startDate;
                }
              });
            }

            Future<void> pickEndDate() async {
              final referenceStart = startDate ?? DateTime(2000, 1, 1);
              final picked = await _pickDate(
                context,
                initialDate: endDate ?? referenceStart,
                firstDate: referenceStart,
              );
              if (picked == null) return;

              setModalState(() {
                endDate = picked;
              });
            }

            Future<void> submit() async {
              if (!formKey.currentState!.validate()) {
                return;
              }
              if (startDate == null || endDate == null) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Please select start and end dates.'),
                  ),
                );
                return;
              }
              if (endDate!.isBefore(startDate!)) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('End date cannot be before start date.'),
                  ),
                );
                return;
              }

              setModalState(() {
                isSubmitting = true;
              });

              try {
                final startStr = _toDateOnlyString(startDate!);
                final endStr = _toDateOnlyString(endDate!);
                await leaveProvider.applyLeave(
                  ApplyLeaveRequest(
                    leaveType: selectedType,
                    startDate: startStr,
                    endDate: endStr,
                    reason: reasonController.text.trim(),
                  ),
                );

                if (!mounted) return;
                navigator.pop();
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('Leave request submitted successfully.'),
                  ),
                );
                await _loadData();
              } catch (e) {
                final text = e.toString().replaceAll('Exception: ', '').trim();
                if (sheetContext.mounted) {
                  setModalState(() {
                    isSubmitting = false;
                  });
                }
                messenger.showSnackBar(
                  SnackBar(
                    content: Text(
                      text.isEmpty ? 'Failed to submit leave request.' : text,
                    ),
                    backgroundColor: AppTheme.error,
                  ),
                );
              }
            }

            final keyboardBottomInset = MediaQuery.of(
              context,
            ).viewInsets.bottom;

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 18,
                bottom: keyboardBottomInset + 20,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Apply Leave',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<String>(
                        initialValue: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Leave Type',
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'PL',
                            child: Text('Personal Leave'),
                          ),
                          DropdownMenuItem(
                            value: 'CL',
                            child: Text('Casual Leave'),
                          ),
                          DropdownMenuItem(
                            value: 'SL',
                            child: Text('Sick Leave'),
                          ),
                        ],
                        onChanged: isSubmitting
                            ? null
                            : (value) {
                                if (value == null) return;
                                setModalState(() {
                                  selectedType = value;
                                });
                              },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildDateField(
                              label: 'Start Date',
                              value: startDate,
                              onTap: isSubmitting ? null : pickStartDate,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildDateField(
                              label: 'End Date',
                              value: endDate,
                              onTap: isSubmitting ? null : pickEndDate,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: reasonController,
                        maxLines: 3,
                        maxLength: 250,
                        enabled: !isSubmitting,
                        decoration: const InputDecoration(
                          labelText: 'Reason',
                          hintText: 'Brief reason for leave',
                        ),
                        validator: (value) {
                          final text = value?.trim() ?? '';
                          if (text.isEmpty) return 'Reason is required';
                          if (text.length < 3) return 'Reason is too short';
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: isSubmitting ? null : submit,
                          child: isSubmitting
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Submit Request'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    reasonController.dispose();
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(labelText: label),
        child: Text(
          value == null ? 'Select' : DateFormat('dd MMM yyyy').format(value),
          style: TextStyle(
            fontSize: 14,
            color: value == null
                ? const Color(0xFF94A3B8)
                : const Color(0xFF0F172A),
            fontWeight: value == null ? FontWeight.w500 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  String _toDateOnlyString(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }

  Future<DateTime?> _pickDate(
    BuildContext context, {
    required DateTime initialDate,
    required DateTime firstDate,
  }) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: DateTime(2100),
    );
  }

  _StatusMeta _statusMeta(LeaveModel leave) {
    if (leave.isApproved) {
      return const _StatusMeta(
        color: Color(0xFF10B981),
        icon: Icons.check_circle,
      );
    }
    if (leave.isRejected) {
      return const _StatusMeta(color: Color(0xFFEF4444), icon: Icons.cancel);
    }
    return const _StatusMeta(color: Color(0xFFF59E0B), icon: Icons.pending);
  }

  String _normalizeLeaveType(String leaveType) {
    final normalized = leaveType.trim().toUpperCase();
    if (normalized == 'PL' ||
        normalized == 'PERSONAL' ||
        normalized == 'PERSONAL LEAVE') {
      return 'PL';
    }
    if (normalized == 'SL' ||
        normalized == 'SICK' ||
        normalized == 'SICK LEAVE') {
      return 'SL';
    }
    return 'CL';
  }

  String _formatDate(String date) => date;
}

class _QuotaCardData {
  final String leaveType;
  final String label;
  final IconData icon;
  final Color color;

  const _QuotaCardData({
    required this.leaveType,
    required this.label,
    required this.icon,
    required this.color,
  });
}

class _StatusMeta {
  final Color color;
  final IconData icon;

  const _StatusMeta({required this.color, required this.icon});
}
