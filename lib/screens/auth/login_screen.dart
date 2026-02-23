import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user_model.dart';
import '../../config/theme.dart';
import '../../core/utils/logger.dart';
import '../../core/branding/brand_widgets.dart';

/// Login Screen
/// Handles user authentication with email and password
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  List<OrganizationModel> _organizations = [];
  bool _showOrganizationSelection = false;
  String? _selectedPrefix;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Handle login with robust safety checks
  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // Step 1: Login
      _organizations = await authProvider.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      // CRITICAL SAFETY CHECK
      if (!mounted) return;

      if (_organizations.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('No organizations found for this user.'),
            backgroundColor: AppTheme.error,
          ),
        );
        return;
      }

      // Step 2: Handle Organizations
      if (_organizations.length == 1) {
        // AUTO-SELECT SINGLE ORGANIZATION
        final org = _organizations[0];
        // Use ID if available, otherwise fallback to name/prefix (though ID is preferred)
        final orgId = org.id ?? org.prefix; 
        
        await authProvider.selectOrganization(orgId);
        
        // CRITICAL SAFETY CHECK
        if (!mounted) return;
        
        // Navigate
        if (authProvider.isAuthenticated) {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        }
      } else {
        // SHOW SELECTION UI
        setState(() {
          _showOrganizationSelection = true;
        });
      }
    } catch (e) {
      if (!mounted) return;
      
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppTheme.error,
          duration: const Duration(seconds: 4),
        ),
      );
      Logger.e('LoginScreen', 'Login failed', e);
    }
  }

  /// Handle manual organization selection from UI
  Future<void> _onOrganizationSelected(String prefix) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.selectOrganization(prefix);

      if (!mounted) return;

      if (authProvider.isAuthenticated) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      }
    } catch (e) {
      if (!mounted) return;
      
      final errorMessage = e.toString().replaceAll('Exception: ', '');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppTheme.error,
          duration: const Duration(seconds: 4),
        ),
      );
      Logger.e('LoginScreen', 'Organization selection failed', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authProvider = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Use constraints.maxHeight directly (as requested)
            // Clamp to 0.0 to prevent any possibility of negative height
            final minHeight = constraints.maxHeight.clamp(0.0, double.infinity);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 32.0,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight:
                      minHeight, // Never negative, ensures keyboard-safe scrolling
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // TOP SECTION: Primary Brand (AttendMark Logo)
                      // Center aligned, size: 80-96px, MAIN brand
                      Center(
                        child: Column(
                          children: [
                            const AppBrandLogo(
                              size: 88, // Size: 80-96px range
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Sign in to continue',
                              style: Theme.of(context).textTheme.bodyLarge
                                  ?.copyWith(
                                    color: colorScheme.onSurface.withValues(alpha: 
                                      0.7,
                                    ),
                                  ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      // MIDDLE SECTION: Form (No logos inside)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Organization Selection (if multiple orgs)
                          if (_showOrganizationSelection &&
                              _organizations.isNotEmpty) ...[
                            Text(
                              'Select Organization',
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 16),
                            ..._organizations.map(
                              (org) => Card(
                                margin: const EdgeInsets.only(bottom: 12),
                                child: ListTile(
                                  title: Text(org.name),
                                  subtitle: Text(org.prefix.isNotEmpty ? org.prefix : (org.id ?? '')),
                                  trailing: _selectedPrefix == (org.id ?? org.prefix)
                                      ? Icon(
                                          Icons.check_circle,
                                          color: colorScheme.primary,
                                        )
                                      : null,
                                  onTap: () {
                                    setState(() {
                                      _selectedPrefix = org.id ?? org.prefix;
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: _selectedPrefix == null
                                  ? null
                                  : () => _onOrganizationSelected(_selectedPrefix!),
                              child: const Text('Continue'),
                            ),
                            const SizedBox(height: 24),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _showOrganizationSelection = false;
                                  _selectedPrefix = null;
                                });
                              },
                              child: const Text('Back'),
                            ),
                          ] else ...[
                            // Email Field
                            TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                              decoration: InputDecoration(
                                labelText: 'Email',
                                hintText: 'Enter your email',
                                prefixIcon: const Icon(Icons.email_outlined),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email';
                                }
                                if (!value.contains('@')) {
                                  return 'Please enter a valid email';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),

                            // Password Field
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.done,
                              onFieldSubmitted: (_) => _handleLogin(),
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'Enter your password',
                                prefixIcon: const Icon(Icons.lock_outlined),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 32),

                            // Login Button
                            ElevatedButton(
                              onPressed: authProvider.isLoading
                                  ? null
                                  : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                              child: authProvider.isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'Login',
                                      style: TextStyle(fontSize: 16),
                                    ),
                            ),
                          ],

                          // Error Message
                          if (authProvider.error != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.error.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.error.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: AppTheme.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      authProvider.error!,
                                      style: TextStyle(color: AppTheme.error),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),

                      // BOTTOM SECTION: Secondary Brand (Powered by Ai Ally)
                      // Small size, subtle appearance, center aligned
                      // Text: "Powered by [Ai Ally logo]"
                      // Must NOT distract from login action
                      Padding(
                        padding: const EdgeInsets.only(top: 32.0, bottom: 16.0),
                        child: const Center(
                          child: PoweredByAiAlly(
                            logoHeight: 15, // Small size (14-16px range)
                            alignment: MainAxisAlignment.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

