import 'package:flutter/material.dart';
import '../../models/session_model.dart';
import '../../config/theme.dart';

/// Session Details Screen
/// READ-ONLY view of session information
/// No edit, delete, or admin actions
class SessionDetailsScreen extends StatelessWidget {
  final SessionModel session;

  const SessionDetailsScreen({super.key, required this.session});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(title: const Text('Session Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Session Title Card
            _buildTitleCard(context, session),
            const SizedBox(height: 16),

            // Date & Time Card
            _buildDateTimeCard(context, session),
            const SizedBox(height: 16),

            // Session Type Card
            _buildSessionTypeCard(context, session),
            const SizedBox(height: 16),

            // Location Card (if available)
            if (session.location != null && session.location!.isNotEmpty)
              _buildLocationCard(context, session),
            if (session.location != null && session.location!.isNotEmpty)
              const SizedBox(height: 16),

            // Description Card (if available)
            if (session.description != null && session.description!.isNotEmpty)
              _buildDescriptionCard(context, session),
            if (session.description != null && session.description!.isNotEmpty)
              const SizedBox(height: 16),

            // QR Availability Status Card
            _buildQRAvailabilityCard(context, session),
          ],
        ),
      ),
    );
  }

  /// Session Title Card
  Widget _buildTitleCard(BuildContext context, SessionModel session) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session Title',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              session.title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Date & Time Card
  Widget _buildDateTimeCard(BuildContext context, SessionModel session) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date & Time',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Date
            if (session.startDate != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    size: 20,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Date',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatDate(session.startDate!),
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: colorScheme.onSurface),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],

            // Time
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 20,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Time',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${session.startTime} - ${session.endTime}',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Session Type Card
  Widget _buildSessionTypeCard(BuildContext context, SessionModel session) {
    final colorScheme = Theme.of(context).colorScheme;

    // Get session type from model (from backend)
    // If not available, infer from location
    String sessionTypeText;
    IconData typeIcon;
    Color typeColor;

    if (session.sessionType != null) {
      // Use backend-provided session type
      switch (session.sessionType!.toUpperCase()) {
        case 'PHYSICAL':
          sessionTypeText = 'Physical';
          typeIcon = Icons.location_on;
          typeColor = AppTheme.primary;
          break;
        case 'REMOTE':
          sessionTypeText = 'Remote';
          typeIcon = Icons.video_call;
          typeColor = AppTheme.info;
          break;
        case 'HYBRID':
          sessionTypeText = 'Hybrid';
          typeIcon = Icons.devices;
          typeColor = AppTheme.warning;
          break;
        default:
          sessionTypeText = session.sessionType!;
          typeIcon = Icons.event;
          typeColor = colorScheme.onSurface.withValues(alpha: 0.7);
      }
    } else {
      // Infer from location (fallback)
      if (session.location != null && session.location!.isNotEmpty) {
        sessionTypeText = 'Physical';
        typeIcon = Icons.location_on;
        typeColor = AppTheme.primary;
      } else {
        sessionTypeText = 'Remote';
        typeIcon = Icons.video_call;
        typeColor = AppTheme.info;
      }
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(typeIcon, size: 24, color: typeColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Session Type',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sessionTypeText,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Location Card
  Widget _buildLocationCard(BuildContext context, SessionModel session) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 20,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 12),
                Text(
                  'Location',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              session.location!,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  /// Description Card
  Widget _buildDescriptionCard(BuildContext context, SessionModel session) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description_outlined,
                  size: 20,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                const SizedBox(width: 12),
                Text(
                  'Description',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              session.description!,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  /// QR Availability Status Card
  Widget _buildQRAvailabilityCard(BuildContext context, SessionModel session) {
    final colorScheme = Theme.of(context).colorScheme;

    // Determine QR status from backend values
    String statusText;
    IconData statusIcon;
    Color statusColor;

    if (session.canShowQr == true && session.isQrAvailable) {
      statusText = 'QR Code Available';
      statusIcon = Icons.check_circle;
      statusColor = AppTheme.success;
    } else if (session.canShowQr == true && !session.isQrAvailable) {
      statusText = 'QR Code Expired';
      statusIcon = Icons.timer_off;
      statusColor = AppTheme.warning;
    } else if (session.canShowQr == false) {
      statusText = 'QR Code Not Available';
      statusIcon = Icons.info_outline;
      statusColor = AppTheme.info;
    } else {
      statusText = 'QR Code Status Unknown';
      statusIcon = Icons.help_outline;
      statusColor = colorScheme.onSurface.withValues(alpha: 0.7);
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          children: [
            Icon(statusIcon, size: 24, color: statusColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'QR Availability',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    statusText,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: statusColor,
                    ),
                  ),
                  if (session.qrExpiresAt != null && session.isQrAvailable) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Expires: ${_formatDateTime(session.qrExpiresAt!)}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Format date
  String _formatDate(DateTime date) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return '${weekdays[date.weekday - 1]}, ${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  /// Format date and time
  String _formatDateTime(DateTime dateTime) {
    final date = _formatDate(dateTime);
    final time =
        '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    return '$date at $time';
  }
}

