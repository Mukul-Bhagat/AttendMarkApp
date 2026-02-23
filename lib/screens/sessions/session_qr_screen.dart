import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../models/session_model.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../../core/auth/roles.dart';
import 'dart:async';

/// Session QR Display Screen
/// Shows QR code for admins/managers (only if canShowQr is true)
class SessionQRScreen extends StatefulWidget {
  final SessionModel session;

  const SessionQRScreen({super.key, required this.session});

  @override
  State<SessionQRScreen> createState() => _SessionQRScreenState();
}

class _SessionQRScreenState extends State<SessionQRScreen> {
  Timer? _countdownTimer;
  Duration? _timeRemaining;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  /// Start countdown timer if QR expires
  void _startCountdown() {
    if (widget.session.qrExpiresAt == null) return;

    _updateTimeRemaining();

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        _updateTimeRemaining();

        // Auto-hide if expired
        if (_timeRemaining != null && _timeRemaining!.isNegative) {
          timer.cancel();
          if (mounted) {
            Navigator.of(context).pop();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('QR code has expired'),
                backgroundColor: AppTheme.error,
              ),
            );
          }
        }
      }
    });
  }

  /// Update remaining time
  void _updateTimeRemaining() {
    if (widget.session.qrExpiresAt == null) return;

    final now = DateTime.now();
    final expiresAt = widget.session.qrExpiresAt!;
    final remaining = expiresAt.difference(now);

    setState(() {
      _timeRemaining = remaining;
    });
  }

  /// Format countdown timer
  String _formatCountdown(Duration duration) {
    if (duration.isNegative) return 'Expired';

    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  /// Get QR code value (session ID or deep link)
  String _getQrValue() {
    // Use session ID as QR value (backend will validate)
    return widget.session.id;
  }

  /// Format date
  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // Check if user can show QR (Company Admin, Session Admin, Manager)
    final canShowQr =
        user != null &&
        _canManageQr(user.role) &&
        widget.session.canShowQr == true;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(title: const Text('Session QR Code')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Session Info Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.session.title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.calendar_today, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          widget.session.startDate != null
                              ? _formatDate(widget.session.startDate!)
                              : 'No date',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(width: 16),
                        const Icon(Icons.access_time, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          '${widget.session.startTime} - ${widget.session.endTime}',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),

            // QR Code Section
            if (!canShowQr)
              // Cannot show QR message
              Card(
                color: AppTheme.warningOrange.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 48,
                        color: AppTheme.warningOrange,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'QR Code Not Available',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(color: AppTheme.warningOrange),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.session.canShowQr == false
                            ? 'QR code can only be shown within 2 hours before session starts.'
                            : 'You do not have permission to view QR codes.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              )
            else
              // Show QR Code
              Column(
                children: [
                  // Countdown Timer
                  if (_timeRemaining != null)
                    Card(
                      color: AppTheme.primaryRed.withValues(alpha: 0.1),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.timer_outlined,
                              color: AppTheme.primaryRed,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Expires in: ${_formatCountdown(_timeRemaining!)}',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: AppTheme.primaryRed,
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // QR Code
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          QrImageView(
                            data: _getQrValue(),
                            version: QrVersions.auto,
                            size: 250.0,
                            backgroundColor: Colors.white,
                            errorCorrectionLevel: QrErrorCorrectLevel.H,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Session ID: ${widget.session.id}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(fontFamily: 'monospace'),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Scan this QR code to mark attendance',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 24),

            // Info Message
            Card(
              color: AppTheme.infoBlue.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: AppTheme.infoBlue,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Students can scan this QR code using the AttendMark mobile app to mark their attendance.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.infoBlue,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canManageQr(String roleValue) {
    final resolvedRole = tryResolveRole(roleValue);
    if (resolvedRole == null) return false;

    return resolvedRole.profile == RoleProfile.companyAdmin ||
        resolvedRole.profile == RoleProfile.superAdmin ||
        resolvedRole.profile == RoleProfile.manager ||
        resolvedRole.profile == RoleProfile.sessionAdmin;
  }
}

