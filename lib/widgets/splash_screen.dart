import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../core/branding/brand_widgets.dart';

/// Splash Screen
/// Simple loading screen shown during app initialization
/// Shows AttendMark logo and loading indicator
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App Logo
            const AppBrandLogo(size: 120),
            const SizedBox(height: 32),
            // Loading indicator
            CircularProgressIndicator(color: AppTheme.primary),
          ],
        ),
      ),
    );
  }
}
