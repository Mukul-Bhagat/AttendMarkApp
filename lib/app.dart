import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/theme.dart';
import 'core/network/dio_client.dart';
import 'core/storage/local_storage.dart';
import 'core/utils/logger.dart';
import 'providers/attendance_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/leave_provider.dart';
import 'providers/session_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/attendance/qr_scan_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/navigation/main_navigation_screen.dart';
import 'screens/sessions/sessions_list_screen.dart';
import 'services/attendance_service.dart';
import 'services/auth_service.dart';
import 'services/leave_service.dart';
import 'services/session_service.dart';
import 'widgets/animated_splash_screen.dart';

/// Main App Widget
/// Sets up providers, handles authentication flow, and navigation
class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool _isStorageInitialized = false;
  String? _initError;

  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  DioClient? _dioClient;
  AuthService? _authService;
  SessionService? _sessionService;
  AttendanceService? _attendanceService;
  LeaveService? _leaveService;

  AuthProvider? _authProvider;
  SessionProvider? _sessionProvider;
  AttendanceProvider? _attendanceProvider;
  LeaveProvider? _leaveProvider;
  ThemeProvider? _themeProvider;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// Initialize app (storage, services, providers)
  Future<void> _initializeApp() async {
    String? initError;
    try {
      await LocalStorage.init();
      Logger.i('App', 'LocalStorage initialized');

      _dioClient = DioClient();
      _authService = AuthService(_dioClient!);
      _sessionService = SessionService(_dioClient!);
      _attendanceService = AttendanceService(_dioClient!);
      _leaveService = LeaveService(_dioClient!);

      _themeProvider = ThemeProvider();
      _authProvider = AuthProvider(_authService!);
      _sessionProvider = SessionProvider(_sessionService!);
      _attendanceProvider = AttendanceProvider(_attendanceService!);
      _leaveProvider = LeaveProvider(_leaveService!);

      Logger.i('App', 'App initialized successfully');
    } catch (e) {
      Logger.e('App', 'Failed to initialize app', e);
      initError = 'App configuration failed. Please check API settings.';
    }

    if (!mounted) return;
    setState(() {
      _isStorageInitialized = true;
      _initError = initError;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_initError != null) {
      return MaterialApp(
        title: 'AttendMark',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        navigatorKey: _navigatorKey,
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(_initError!, textAlign: TextAlign.center),
            ),
          ),
        ),
      );
    }

    if (!_isStorageInitialized ||
        _authProvider == null ||
        _themeProvider == null ||
        _sessionProvider == null ||
        _attendanceProvider == null ||
        _leaveProvider == null) {
      return MaterialApp(
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routes: _appRoutes(),
        home: const AnimatedSplashScreen(),
        debugShowCheckedModeBanner: false,
        navigatorKey: _navigatorKey,
      );
    }

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(value: _themeProvider!),
        ChangeNotifierProvider<AuthProvider>.value(value: _authProvider!),
        ChangeNotifierProvider<SessionProvider>.value(value: _sessionProvider!),
        ChangeNotifierProvider<AttendanceProvider>.value(
          value: _attendanceProvider!,
        ),
        ChangeNotifierProvider<LeaveProvider>.value(value: _leaveProvider!),
      ],
      child: Consumer2<ThemeProvider, AuthProvider>(
        builder: (context, themeProvider, authProvider, child) {
          if (!authProvider.isInitialized) {
            return MaterialApp(
              title: 'AttendMark',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme,
              darkTheme: AppTheme.darkTheme,
              themeMode: themeProvider.themeMode,
              routes: _appRoutes(),
              home: const AnimatedSplashScreen(),
              navigatorKey: _navigatorKey,
            );
          }

          return MaterialApp(
            title: 'AttendMark',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
            routes: _appRoutes(),
            home: authProvider.isAuthenticated
                ? const MainNavigationScreen()
                : const LoginScreen(),
            navigatorKey: _navigatorKey,
          );
        },
      ),
    );
  }

  Map<String, WidgetBuilder> _appRoutes() {
    return {
      '/login': (context) => const LoginScreen(),
      '/dashboard': (context) => const MainNavigationScreen(initialIndex: 0),
      '/leaves': (context) => const MainNavigationScreen(initialIndex: 1),
      '/scan': (context) => const QRScanScreen(),
      '/my-attendance': (context) =>
          const MainNavigationScreen(initialIndex: 2),
      '/profile': (context) => const MainNavigationScreen(initialIndex: 3),
      '/sessions': (context) => const SessionsListScreen(),
    };
  }
}
