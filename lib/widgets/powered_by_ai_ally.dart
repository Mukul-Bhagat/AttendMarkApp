import 'package:flutter/material.dart';
import '../core/branding/brand_logo_paths.dart';

/// PoweredByAiAlly Widget
/// Secondary branding widget - subtle and professional
/// 
/// Displays "Powered by" text with Ai Ally logo
/// Automatically switches logo based on theme:
/// - Light Mode â†’ aiallyblacklogo.png
/// - Dark Mode â†’ aiallywhitelogo.png
/// 
/// IMPORTANT:
/// - This widget is NOT global
/// - Used ONLY on selected screens (Login, Profile)
/// - Low visual priority - does NOT overpower AttendMark logo
/// 
/// Usage:
/// - Login screen (bottom)
/// - Profile screen (footer)
/// 
/// Design Rules:
/// - Small font size
/// - Logo height ~14-16px (default: 15px)
/// - Secondary text color (low opacity)
/// - Preserves original logo colors (no tinting)
/// - No hardcoded colors
/// - Stateless widget
class PoweredByAiAlly extends StatelessWidget {
  /// Logo height in pixels (default: 15px, range: 14-16px)
  final double logoHeight;
  
  /// Horizontal alignment (default: center)
  final MainAxisAlignment alignment;
  
  /// Text style override (optional)
  final TextStyle? textStyle;
  
  const PoweredByAiAlly({
    super.key,
    this.logoHeight = 15,
    this.alignment = MainAxisAlignment.center,
    this.textStyle,
  });
  
  @override
  Widget build(BuildContext context) {
    // Detect theme using Theme.of(context).brightness
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    
    // Select logo based on theme
    // Light Mode â†’ aiallyblacklogo.png
    // Dark Mode â†’ aiallywhitelogo.png
    final logoPath = isDark
        ? BrandLogoPaths.aiAllyDark
        : BrandLogoPaths.aiAllyLight;
    
    // Default text style: small font, secondary text color, low visual priority
    final defaultTextStyle = Theme.of(context).textTheme.bodySmall?.copyWith(
      color: colorScheme.onSurface.withValues(alpha: 0.5), // Secondary text color
      fontSize: 11, // Small font size
    );
    
    return Row(
      mainAxisAlignment: alignment,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Powered by',
          style: textStyle ?? defaultTextStyle,
        ),
        const SizedBox(width: 6),
        Image.asset(
          logoPath,
          height: logoHeight,
          fit: BoxFit.contain,
          // Do not tint - preserve original colors
          color: null,
          errorBuilder: (context, error, stackTrace) {
            // Fallback to text if image fails to load
            return Text(
              'Ai Ally',
              style: textStyle ?? defaultTextStyle?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            );
          },
        ),
      ],
    );
  }
}


