import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../config/theme.dart';
import '../../core/branding/brand_widgets.dart';
import '../../core/utils/logger.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../services/app_update_service.dart';
import '../../widgets/web_only_hint.dart';

/// Profile Screen
/// Shows user profile, settings, and logout
/// No profile edit or password change (web-only features)
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AppUpdateService _appUpdateService;
  late Future<_AboutVersionInfo> _aboutVersionFuture;

  @override
  void initState() {
    super.initState();
    _appUpdateService = AppUpdateService();
    _aboutVersionFuture = _loadAboutVersionInfo();
  }

  Future<_AboutVersionInfo> _loadAboutVersionInfo() async {
    var packageVersion = 'Unknown';
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final version = packageInfo.version.trim();
      if (version.isNotEmpty) {
        packageVersion = version;
      }
    } catch (e) {
      Logger.w('ProfileScreen', 'Failed to read package version: $e');
    }

    try {
      final decision = await _appUpdateService.checkForUpdate();
      final currentVersion = decision.currentVersion.trim().isNotEmpty
          ? decision.currentVersion.trim()
          : packageVersion;
      final latestVersion = decision.info?.latestVersion.trim() ?? '';
      final nextVersion = latestVersion.isNotEmpty
          ? latestVersion
          : currentVersion;

      return _AboutVersionInfo(
        currentVersion: currentVersion,
        nextVersion: nextVersion,
        statusMessage: nextVersion == currentVersion
            ? 'You are on the latest version.'
            : 'A newer version is available.',
      );
    } catch (e) {
      Logger.w('ProfileScreen', 'Update check failed: $e');
      return _AboutVersionInfo(
        currentVersion: packageVersion,
        nextVersion: packageVersion,
        statusMessage: 'Latest version is currently unavailable.',
      );
    }
  }

  void _refreshAboutVersion() {
    setState(() {
      _aboutVersionFuture = _loadAboutVersionInfo();
    });
  }

  void _showAboutDialog(BuildContext context, _AboutVersionInfo info) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('About AttendMark'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Version',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                info.currentVersion,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Next Version',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                info.nextVersion,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                info.statusMessage,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _refreshAboutVersion();
              },
              child: const Text('Check Again'),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    if (user == null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: AppBar(title: const Text('Profile')),
        body: Center(
          child: Text(
            'User not found',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: const [
            AppBrandLogo(size: 24),
            SizedBox(width: 12),
            Text('Profile'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(context, user),
            const SizedBox(height: 24),
            _buildUserInfo(context, user),
            const SizedBox(height: 24),
            _buildSettings(context),
            const SizedBox(height: 24),
            _buildWebOnlyFeatures(context),
            const SizedBox(height: 24),
            _buildLogoutButton(context, authProvider),
            const SizedBox(height: 40),
            const Center(
              child: PoweredByAiAlly(
                logoHeight: 15,
                alignment: MainAxisAlignment.center,
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  /// Profile Header
  Widget _buildProfileHeader(BuildContext context, dynamic user) {
    final colorScheme = Theme.of(context).colorScheme;
    final initials = user.name.isNotEmpty
        ? user.name
              .split(' ')
              .map((name) => name[0])
              .take(2)
              .join()
              .toUpperCase()
        : user.email[0].toUpperCase();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: AppTheme.primary,
              child: Text(
                initials,
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primary.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                user.role,
                style: const TextStyle(
                  fontSize: 12,
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// User Information Card
  Widget _buildUserInfo(BuildContext context, dynamic user) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Information',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.email_outlined,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            title: Text(
              'Email',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            subtitle: Text(
              user.email,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
            ),
          ),
          if (user.organizationId != null) ...[
            const Divider(height: 1),
            ListTile(
              leading: Icon(
                Icons.business_outlined,
                color: colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              title: Text(
                'Organization',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
              subtitle: Text(
                user.organizationId!,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
              ),
            ),
          ],
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.badge_outlined,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            title: Text(
              'Role',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            subtitle: Text(
              user.role,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  /// Settings Card
  Widget _buildSettings(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Settings',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
          ),
          const Divider(height: 1),
          Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return ListTile(
                leading: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                title: Text(
                  'Theme',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                subtitle: Text(
                  themeProvider.isDarkMode ? 'Dark Mode' : 'Light Mode',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                trailing: Switch(
                  value: themeProvider.isDarkMode,
                  onChanged: (value) {
                    themeProvider.toggleTheme();
                  },
                  activeThumbColor: AppTheme.primary,
                ),
              );
            },
          ),
          const Divider(height: 1),
          FutureBuilder<_AboutVersionInfo>(
            future: _aboutVersionFuture,
            builder: (context, snapshot) {
              final isLoading =
                  snapshot.connectionState == ConnectionState.waiting;
              final info =
                  snapshot.data ??
                  const _AboutVersionInfo(
                    currentVersion: 'Unknown',
                    nextVersion: 'Unknown',
                    statusMessage: 'Version information is not available.',
                  );

              final subtitle = isLoading
                  ? 'Checking app versions...'
                  : 'Current: ${info.currentVersion} | Next: ${info.nextVersion}';

              return ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                title: Text(
                  'About',
                  style: TextStyle(color: colorScheme.onSurface),
                ),
                subtitle: Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                trailing: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        Icons.chevron_right,
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                      ),
                onTap: isLoading ? null : () => _showAboutDialog(context, info),
              );
            },
          ),
        ],
      ),
    );
  }

  /// Web-Only Features Hint
  Widget _buildWebOnlyFeatures(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              Icons.edit_outlined,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            title: Text(
              'Edit Profile',
              style: TextStyle(color: colorScheme.onSurface),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            onTap: () {},
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: WebOnlyHint(),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              Icons.lock_outlined,
              color: colorScheme.onSurface.withValues(alpha: 0.7),
            ),
            title: Text(
              'Change Password',
              style: TextStyle(color: colorScheme.onSurface),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: colorScheme.onSurface.withValues(alpha: 0.5),
            ),
            onTap: () {},
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: WebOnlyHint(),
          ),
        ],
      ),
    );
  }

  /// Logout Button
  Widget _buildLogoutButton(BuildContext context, AuthProvider authProvider) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.error),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );

          if (confirm == true) {
            try {
              await authProvider.logout();
              if (context.mounted) {
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            } catch (e) {
              Logger.e('ProfileScreen', 'Logout failed', e);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Logout failed: ${e.toString()}'),
                    backgroundColor: AppTheme.error,
                  ),
                );
              }
            }
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.error,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Logout', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}

class _AboutVersionInfo {
  final String currentVersion;
  final String nextVersion;
  final String statusMessage;

  const _AboutVersionInfo({
    required this.currentVersion,
    required this.nextVersion,
    required this.statusMessage,
  });
}
