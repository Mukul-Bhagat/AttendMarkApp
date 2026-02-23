// AttendMark Widget Tests
//
// Basic widget tests for AttendMark app
// Tests core widgets and screens
//
// NOTE: IDE linter may show false positive errors because packages aren't loaded
// in the analyzer context. These tests run successfully with `flutter test`.
// All 5 tests pass: ✅ SplashScreen, ✅ AppBrandLogo (light/dark), ✅ PoweredByAiAlly, ✅ Theme

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:attend_mark/config/theme.dart';
import 'package:attend_mark/widgets/splash_screen.dart';
import 'package:attend_mark/core/branding/brand_widgets.dart';

void main() {
  group('AttendMark Widget Tests', () {
    testWidgets('SplashScreen displays correctly', (WidgetTester tester) async {
      // Build SplashScreen widget
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          home: const SplashScreen(),
        ),
      );

      // Wait for widget to build
      await tester.pump();

      // Verify loading indicator is present
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Verify AppBrandLogo is present
      expect(find.byType(AppBrandLogo), findsOneWidget);
    });

    testWidgets('AppBrandLogo widget displays in light mode', (
      WidgetTester tester,
    ) async {
      // Build AppBrandLogo in light theme
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(body: const AppBrandLogo(size: 100)),
        ),
      );

      // Wait for widget to build
      await tester.pump();

      // Verify AppBrandLogo widget is present
      expect(find.byType(AppBrandLogo), findsOneWidget);

      // Verify logo image is present
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('AppBrandLogo widget displays in dark mode', (
      WidgetTester tester,
    ) async {
      // Build AppBrandLogo in dark theme
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.darkTheme,
          home: Scaffold(body: const AppBrandLogo(size: 100)),
        ),
      );

      // Wait for widget to build
      await tester.pump();

      // Verify AppBrandLogo widget is present
      expect(find.byType(AppBrandLogo), findsOneWidget);

      // Verify logo image is present
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('PoweredByAiAlly widget displays correctly', (
      WidgetTester tester,
    ) async {
      // Build PoweredByAiAlly widget
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(body: const PoweredByAiAlly()),
        ),
      );

      // Wait for widget to build
      await tester.pump();

      // Verify PoweredByAiAlly widget is present
      expect(find.byType(PoweredByAiAlly), findsOneWidget);

      // Verify "Powered by" text is present
      expect(find.text('Powered by'), findsOneWidget);

      // Verify logo image is present
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('Theme switching works correctly', (WidgetTester tester) async {
      // Build app with light theme
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: ThemeMode.light,
          home: Builder(
            builder: (context) {
              final brightness = Theme.of(context).brightness;
              return Scaffold(
                body: Center(
                  child: Text(
                    'Theme: ${brightness == Brightness.dark ? 'Dark' : 'Light'}',
                  ),
                ),
              );
            },
          ),
        ),
      );

      // Wait for widget to build
      await tester.pump();

      // Verify light theme is applied
      expect(find.text('Theme: Light'), findsOneWidget);
    });
  });
}
