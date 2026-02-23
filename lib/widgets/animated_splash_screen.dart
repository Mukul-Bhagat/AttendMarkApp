import 'package:flutter/material.dart';
import '../config/theme.dart';
import '../core/branding/brand_widgets.dart';

/// Premium Animated Splash Screen
/// Video-style brand animation for AttendMark
/// 
/// Animation Sequence:
/// - Scene 1 (0-1s): Logo scale-in + fade-in
/// - Scene 2 (1-2s): Logo stabilizes, subtle glow
/// - Scene 3 (2-2.8s): Red tick mark appears
/// - Scene 4 (2.8-3s): Fade out transition
/// 
/// Duration: ~3 seconds, smooth and professional
/// Theme-aware: Automatically switches logo based on light/dark mode
class AnimatedSplashScreen extends StatefulWidget {
  const AnimatedSplashScreen({super.key});
  
  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoGlow;
  late Animation<double> _tickOpacity;
  late Animation<double> _tickScale;
  late Animation<double> _tickStroke;
  late Animation<double> _fadeOut;
  
  @override
  void initState() {
    super.initState();
    
    // Animation controller: 3 seconds total
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );
    
    // Scene 1: Logo Entry (0s → 1s)
    _logoScale = Tween<double>(
      begin: 0.95,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.33, curve: Curves.easeOut),
      ),
    );
    
    _logoOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.33, curve: Curves.easeOut),
      ),
    );
    
    // Scene 2: Brand Emphasis (1s → 2s)
    _logoGlow = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.33, 0.67, curve: Curves.easeInOut),
      ),
    );
    
    // Scene 3: Red Tick Animation (2s → 2.8s)
    _tickOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.67, 0.93, curve: Curves.easeOut),
      ),
    );
    
    _tickScale = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.67, 0.93, curve: Curves.easeOut),
      ),
    );
    
    _tickStroke = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.67, 0.93, curve: Curves.easeOut),
      ),
    );
    
    // Scene 4: Exit Transition (2.8s → 3s)
    _fadeOut = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.93, 1.0, curve: Curves.easeIn),
      ),
    );
    
    // Start animation immediately
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final isDark = brightness == Brightness.dark;
    final backgroundColor = isDark 
        ? AppTheme.darkBackground 
        : AppTheme.lightBackground;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      body: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeOut.value,
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // AttendMark Logo
                  Transform.scale(
                    scale: _logoScale.value,
                    child: Opacity(
                      opacity: _logoOpacity.value,
                      child: Container(
                        decoration: BoxDecoration(
                          // Subtle glow effect (Scene 2)
                          boxShadow: _logoGlow.value > 0
                              ? [
                                  BoxShadow(
                                    color: AppTheme.primary.withValues(
                                      alpha: 0.1 * _logoGlow.value,
                                    ),
                                    blurRadius: 20 * _logoGlow.value,
                                    spreadRadius: 5 * _logoGlow.value,
                                  ),
                                ]
                              : null,
                        ),
                        child: const AppBrandLogo(
                          size: 140, // Large, prominent size
                        ),
                      ),
                    ),
                  ),
                  
                  // Red Tick Mark (Scene 3)
                  // Positioned at top-right corner of logo
                  // Represents "Attendance Marked" - verification, completion, trust
                  if (_tickOpacity.value > 0)
                    Positioned(
                      top: -25, // Above logo center
                      right: -25, // Right of logo center
                      child: Transform.scale(
                        scale: _tickScale.value,
                        child: Opacity(
                          opacity: _tickOpacity.value,
                          child: _RedTickMark(
                            strokeProgress: _tickStroke.value,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Red Tick Mark Widget
/// Custom drawn tick mark with stroke animation
/// Color: #f04129 (Primary Red)
/// Represents: Attendance, Verification, Completion, Trust
class _RedTickMark extends StatelessWidget {
  final double strokeProgress;
  
  const _RedTickMark({
    required this.strokeProgress,
  });
  
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(40, 40),
      painter: _TickPainter(
        strokeProgress: strokeProgress,
        color: AppTheme.primary, // #f04129
      ),
    );
  }
}

/// Custom Painter for Tick Mark
/// Draws a checkmark with stroke animation
class _TickPainter extends CustomPainter {
  final double strokeProgress;
  final Color color;
  
  _TickPainter({
    required this.strokeProgress,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    
    // Tick mark path (checkmark) - smooth, confident stroke
    // Starting from bottom-left, curving up and right
    final path = Path();
    
    // Start point (bottom-left of tick)
    final startX = size.width * 0.15;
    final startY = size.height * 0.65;
    
    // Middle point (curve point)
    final midX = size.width * 0.45;
    final midY = size.height * 0.3;
    
    // End point (top-right of tick)
    final endX = size.width * 0.85;
    final endY = size.height * 0.15;
    
    // Draw tick mark path with smooth curve
    path.moveTo(startX, startY);
    path.quadraticBezierTo(
      (startX + midX) / 2,
      (startY + midY) / 2,
      midX,
      midY,
    );
    path.quadraticBezierTo(
      (midX + endX) / 2,
      (midY + endY) / 2,
      endX,
      endY,
    );
    
    // Animate stroke drawing (draws from start to end)
    if (strokeProgress > 0) {
      try {
        final pathMetrics = path.computeMetrics();
        if (pathMetrics.isNotEmpty) {
          final pathMetric = pathMetrics.first;
          final length = pathMetric.length;
          final animatedLength = length * strokeProgress;
          
          final animatedPath = pathMetric.extractPath(
            0.0,
            animatedLength,
          );
          
          canvas.drawPath(animatedPath, paint);
        }
      } catch (e) {
        // Silently handle path computation errors
        // This prevents "Bad state: No element" errors
      }
    }
  }
  
  @override
  bool shouldRepaint(_TickPainter oldDelegate) {
    return oldDelegate.strokeProgress != strokeProgress;
  }
}

