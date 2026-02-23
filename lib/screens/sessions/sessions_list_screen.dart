import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/session_provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/theme.dart';
import '../../models/session_model.dart';
import '../../core/auth/roles.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/error_view.dart';
import 'session_qr_screen.dart';
import 'session_details_screen.dart';

/// Sessions List Screen
/// Shows sessions in Today / Upcoming / Past tabs
/// Shows "Show QR" button ONLY if canShowQr == true (from backend)
class SessionsListScreen extends StatefulWidget {
  const SessionsListScreen({super.key});

  @override
  State<SessionsListScreen> createState() => _SessionsListScreenState();
}

class _SessionsListScreenState extends State<SessionsListScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _loadSessions();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Load sessions
  Future<void> _loadSessions() async {
    final sessionProvider = Provider.of<SessionProvider>(
      context,
      listen: false,
    );
    await sessionProvider.getSessions();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    // Check if user can show QR (Admin/Manager only)
    final canShowQrButton = user != null && _canManageQr(user.role);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('Sessions'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Today'),
            Tab(text: 'Upcoming'),
            Tab(text: 'Past'),
          ],
        ),
      ),
      body: Consumer<SessionProvider>(
        builder: (context, sessionProvider, child) {
          if (sessionProvider.isLoading) {
            return Center(
              child: CircularProgressIndicator(color: AppTheme.primary),
            );
          }

          if (sessionProvider.error != null) {
            return ErrorView(
              message: sessionProvider.error!,
              onRetry: _loadSessions,
              isLoading: sessionProvider.isLoading,
            );
          }

          return RefreshIndicator(
            onRefresh: _loadSessions,
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildSessionsList(
                  sessionProvider.getTodaySessions(),
                  canShowQrButton,
                ),
                _buildSessionsList(
                  sessionProvider.getUpcomingSessions(),
                  canShowQrButton,
                ),
                _buildSessionsList(
                  sessionProvider.getPastSessions(),
                  canShowQrButton,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Build sessions list
  Widget _buildSessionsList(List<SessionModel> sessions, bool canShowQrButton) {
    if (sessions.isEmpty) {
      return const EmptyState(
        icon: Icons.event_busy,
        title: 'No sessions found',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16.0),
      itemCount: sessions.length,
      itemBuilder: (context, index) {
        final session = sessions[index];
        return _buildSessionCard(session, canShowQrButton);
      },
    );
  }

  /// Build session card
  Widget _buildSessionCard(SessionModel session, bool canShowQrButton) {
    final colorScheme = Theme.of(context).colorScheme;
    final now = DateTime.now();

    // Show QR button ONLY if:
    // 1. User is Admin/Manager (canShowQrButton == true)
    // 2. Backend says canShowQr == true
    // 3. QR window is still open (if expiry is provided)
    final qrWindowOpen =
        session.canShowQr == true &&
        (session.qrExpiresAt == null || session.qrExpiresAt!.isAfter(now));
    final showQrButton = canShowQrButton && qrWindowOpen;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () {
          // Navigate to session details
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SessionDetailsScreen(session: session),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Session Title
              Text(
                session.title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),

              // Time
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${session.startTime} - ${session.endTime}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),

              // Date (if available)
              if (session.startDate != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(session.startDate!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ],

              // Location (if available)
              if (session.location != null && session.location!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        session.location!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Show QR Button (ONLY if backend says canShowQr == true)
              if (showQrButton) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              SessionQRScreen(session: session),
                        ),
                      );
                    },
                    icon: const Icon(Icons.qr_code),
                    label: const Text('Show QR Code'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: BorderSide(color: AppTheme.primary),
                    ),
                  ),
                ),
              ],

              // Show info if QR is not available (for admins/managers)
              if (!showQrButton && canShowQrButton && !qrWindowOpen) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: AppTheme.info),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          session.canShowQr == true
                              ? 'QR code is expired'
                              : 'QR code not available',
                          style: Theme.of(
                            context,
                          ).textTheme.bodySmall?.copyWith(color: AppTheme.info),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
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

