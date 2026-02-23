import 'package:flutter/material.dart';
import '../core/branding/brand_logo_paths.dart';

/// AppBrandLogo Widget
/// Primary AttendMark branding widget
/// 
/// Theme-aware widget that automatically detects current theme and displays
/// the appropriate logo:
/// - Light Mode → app_logo_black.png
/// - Dark Mode → app_logo_white.png
/// 
/// Usage:
/// - Login screen (top)
/// - Dashboard header (small)
/// - Profile header (optional)
/// 
/// Design Rules:
/// - Stateless widget
/// - Preserves original logo colors (no tinting)
/// - No hardcoded colors
/// - Theme-aware using Theme.of(context).brightness
class AppBrandLogo extends StatelessWidget {
  /// Logo size in pixels (default: 80px)
  final double? size;
  
  /// Optional width override
  final double? width;
  
  /// Optional height override (overrides size if provided)
  final double? height;
  
  /// Image fit behavior (default: BoxFit.contain)
  final BoxFit fit;
  
  const AppBrandLogo({
    super.key,
    this.size = 80,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
  });
  
  @override
  Widget build(BuildContext context) {
    // Detect theme using Theme.of(context).brightness
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    
    // Select logo based on theme
    // Light Mode → app_logo_black.png
    // Dark Mode → app_logo_white.png
    final logoPath = isDark
        ? BrandLogoPaths.attendMarkDark
        : BrandLogoPaths.attendMarkLight;
    
    // Calculate dimensions
    final logoWidth = width ?? size;
    final logoHeight = height ?? size;
    
    return Image.asset(
      logoPath,
      width: logoWidth,
      height: logoHeight,
      fit: fit,
      // Preserve original colors - no tinting
      color: null,
      errorBuilder: (context, error, stackTrace) {
        // Fallback to text if image fails to load
        final colorScheme = Theme.of(context).colorScheme;
        return Text(
          'AttendMark',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        );
      },
    );
  }
}

