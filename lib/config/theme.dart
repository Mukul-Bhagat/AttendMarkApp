import 'package:flutter/material.dart';

/// App Theme Configuration
/// Material 3 theme matching web app EXACTLY
class AppTheme {
  // Primary color (used in both modes)
  static const Color primary = Color(0xFFf04129); // #f04129
  static const Color primaryHover = Color(0xFFd63a25); // #d63a25

  // Light mode colors (EXACT web app values)
  static const Color lightBackground = Color(0xFFf8f7f5); // #f8f7f5
  static const Color lightSurface = Color(0xFFFFFFFF); // #ffffff
  static const Color lightTextPrimary = Color(0xFF181511); // #181511
  static const Color lightBorder = Color(0xFFe6e2db); // #e6e2db

  // Dark mode colors (EXACT web app values)
  static const Color darkBackground = Color(0xFF0f172a); // #0f172a
  static const Color darkSurface = Color(0xFF1e293b); // #1e293b
  static const Color darkTextPrimary = Color(0xFFf1f5f9); // #f1f5f9
  static const Color darkBorder = Color(0xFF334155); // #334155

  // Accent colors
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Compatibility aliases (for existing code)
  static const Color primaryRed = primary;
  static const Color errorRed = error;
  static const Color successGreen = success;
  static const Color warningOrange = warning;
  static const Color infoBlue = info;
  static const Color darkTextSecondary = Color(0xFFcbd5e1); // Slate-300

  /// Get Light Theme (Material 3)
  /// Matches web app light mode exactly
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.light(
      primary: primary,
      onPrimary: Colors.white,
      secondary: primaryHover,
      onSecondary: Colors.white,
      surface: lightSurface,
      onSurface: lightTextPrimary,
      error: error,
      onError: Colors.white,
      outline: lightBorder,
      outlineVariant: lightBorder.withValues(alpha: 0.5),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.6)),
        hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outline),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface.withValues(alpha: 0.7)),
    );
  }

  /// Get Dark Theme (Material 3)
  /// Matches web app dark mode exactly
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: primary,
      onPrimary: Colors.white,
      secondary: primaryHover,
      onSecondary: Colors.white,
      surface: darkSurface,
      onSurface: darkTextPrimary,
      error: error,
      onError: Colors.white,
      outline: darkBorder,
      outlineVariant: darkBorder.withValues(alpha: 0.5),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: colorScheme.onSurface),
        titleTextStyle: TextStyle(
          color: colorScheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: colorScheme.surface,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colorScheme.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        labelStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
        hintStyle: TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colorScheme.primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          side: BorderSide(color: colorScheme.outline),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: colorScheme.outline,
        thickness: 1,
        space: 1,
      ),
      iconTheme: IconThemeData(color: colorScheme.onSurface.withValues(alpha: 0.7)),
    );
  }
}

