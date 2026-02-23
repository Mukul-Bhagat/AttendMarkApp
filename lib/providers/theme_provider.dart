import 'package:flutter/material.dart';
import '../core/storage/local_storage.dart';
import '../core/utils/logger.dart';

/// Theme Provider
/// Manages app theme (light/dark/system) with persistence
class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;
  
  ThemeProvider() {
    _loadTheme();
  }
  
  // Getters
  ThemeMode get themeMode => _themeMode;
  bool get isInitialized => _isInitialized;
  
  /// Check if dark mode is active
  /// For system mode, returns false (default to light)
  /// Can be enhanced with MediaQuery.of(context).platformBrightness
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // System mode - default to light, or use platform brightness in widget context
      return false;
    }
    return _themeMode == ThemeMode.dark;
  }
  
  /// Load saved theme preference from storage
  Future<void> _loadTheme() async {
    if (_isInitialized) return;
    
    try {
      final savedTheme = LocalStorage.getString('theme_mode');
      if (savedTheme != null) {
        switch (savedTheme) {
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          case 'system':
            _themeMode = ThemeMode.system;
            break;
        }
        Logger.i('ThemeProvider', 'Loaded theme: $savedTheme');
      } else {
        // Default to system theme
        _themeMode = ThemeMode.system;
        Logger.i('ThemeProvider', 'Using default system theme');
      }
      _isInitialized = true;
      notifyListeners();
    } catch (e) {
      Logger.e('ThemeProvider', 'Failed to load theme', e);
      // Default to system on error
      _themeMode = ThemeMode.system;
      _isInitialized = true;
      notifyListeners();
    }
  }
  
  /// Set theme mode explicitly
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    notifyListeners();
    
    try {
      String themeString;
      switch (mode) {
        case ThemeMode.light:
          themeString = 'light';
          break;
        case ThemeMode.dark:
          themeString = 'dark';
          break;
        case ThemeMode.system:
          themeString = 'system';
          break;
      }
      await LocalStorage.saveString('theme_mode', themeString);
      Logger.i('ThemeProvider', 'Theme saved: $themeString');
    } catch (e) {
      Logger.e('ThemeProvider', 'Failed to save theme', e);
    }
  }
  
  /// Toggle between light and dark mode
  /// If currently system, switches to dark
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      await setThemeMode(ThemeMode.light);
    } else {
      // System mode - switch to dark
      await setThemeMode(ThemeMode.dark);
    }
  }
  
  /// Set light theme
  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }
  
  /// Set dark theme
  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }
  
  /// Set system theme
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }
}
