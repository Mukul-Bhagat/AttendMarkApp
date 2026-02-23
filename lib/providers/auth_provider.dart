import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';
import '../core/storage/local_storage.dart';
import '../core/utils/logger.dart';

/// Authentication Provider
/// Manages authentication state and user data
class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final Map<String, String> _organizationNameByKey = {};

  UserModel? _user;
  String? _token;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;
  bool _isAuthenticated = false;

  AuthProvider(this._authService) {
    _loadUserFromStorage();
  }

  // Getters
  UserModel? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  /// Load user from storage on app start
  Future<void> _loadUserFromStorage() async {
    _isLoading = true;
    notifyListeners();

    try {
      final storedToken = LocalStorage.getToken();
      if (storedToken != null && storedToken.isNotEmpty) {
        _token = storedToken;

        // Try to fetch user data
        try {
          _user = await _authService.getMe();
          if (_user != null &&
              (_user!.organizationName == null ||
                  _user!.organizationName!.trim().isEmpty)) {
            final storedOrgName = LocalStorage.getString('selected_org_name');
            if (storedOrgName != null && storedOrgName.trim().isNotEmpty) {
              _user = _user!.copyWith(organizationName: storedOrgName.trim());
            }
          }

          // Filter out Platform Owner - they cannot use mobile app
          if (_user!.isPlatformOwner) {
            Logger.w('AuthProvider', 'Platform Owner detected. Logging out.');
            await logout();
            _error =
                'Platform Owner role is not supported on mobile app. Please use web dashboard.';
            return;
          }

          _isAuthenticated = true;
          Logger.i('AuthProvider', 'User loaded from storage: ${_user!.email}');
        } catch (e) {
          // Token might be invalid, clear it
          Logger.w('AuthProvider', 'Failed to fetch user. Clearing token.');
          await LocalStorage.clearToken();
          _token = null;
        }
      }
    } catch (e) {
      Logger.e('AuthProvider', 'Failed to load user from storage', e);
      _error = 'Failed to load user data';
    } finally {
      _isLoading = false;
      _isInitialized = true;
      notifyListeners();
    }
  }

  /// Login with email and password
  /// Returns list of organizations (filtered - Platform Owner excluded)
  Future<List<OrganizationModel>> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Logger.i('AuthProvider', 'Login attempt for: $email');

      final response = await _authService.login(email, password);

      // Extract organizations from response
      final List<dynamic> orgsJson = response['organizations'] ?? [];
      final allOrganizations = orgsJson
          .map((json) => OrganizationModel.fromJson(json))
          .toList();

      // Filter out Platform Owner organizations
      final filteredOrganizations = allOrganizations
          .where(
            (org) =>
                org.prefix != 'platform_owner' &&
                !org.name.toLowerCase().contains('platform'),
          )
          .toList();
      _cacheOrganizationNames(filteredOrganizations);

      // Check if user only has Platform Owner access
      if (allOrganizations.isNotEmpty && filteredOrganizations.isEmpty) {
        _isLoading = false;
        _error =
            'Platform Owner role is not supported on mobile app. Please use web dashboard.';
        notifyListeners();
        throw Exception(_error);
      }

      // Store tempToken temporarily (will be replaced after org selection)
      if (response['tempToken'] != null) {
        await LocalStorage.saveString('temp_token', response['tempToken']);
      }

      _isLoading = false;
      notifyListeners();

      Logger.i(
        'AuthProvider',
        'Login successful. Organizations: ${filteredOrganizations.length}',
      );
      return filteredOrganizations;
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      notifyListeners();
      Logger.e('AuthProvider', 'Login failed', e);
      rethrow;
    }
  }

  /// Select organization and complete login
  Future<void> selectOrganization(String prefix) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      Logger.i('AuthProvider', 'Selecting organization: $prefix');

      final tempToken = LocalStorage.getString('temp_token');
      if (tempToken == null) {
        throw Exception('Temporary token not found. Please login again.');
      }

      final response = await _authService.selectOrganization(tempToken, prefix);

      // Extract token and user data
      _token = response['token'];
      if (_token != null) {
        await LocalStorage.saveToken(_token!);
      }

      // Parse user data
      if (response['user'] != null) {
        _user = UserModel.fromJson(response['user']);

        final resolvedOrgName = _resolveOrganizationName(
          prefix,
          _user?.organizationId,
        );
        if (resolvedOrgName != null &&
            (_user!.organizationName == null ||
                _user!.organizationName!.trim().isEmpty)) {
          _user = _user!.copyWith(organizationName: resolvedOrgName);
        }
        if (resolvedOrgName != null) {
          await LocalStorage.saveString('selected_org_name', resolvedOrgName);
        }

        // Final check: Filter out Platform Owner
        if (_user!.isPlatformOwner) {
          Logger.w(
            'AuthProvider',
            'Platform Owner detected after org selection. Logging out.',
          );
          await logout();
          _error =
              'Platform Owner role is not supported on mobile app. Please use web dashboard.';
          throw Exception(_error);
        }
      }

      // Clear temp token
      await LocalStorage.remove('temp_token');

      _isAuthenticated = true;
      _isLoading = false;
      notifyListeners();

      Logger.i(
        'AuthProvider',
        'Login completed successfully for: ${_user?.email}',
      );
    } catch (e) {
      _error = e.toString().replaceAll('Exception: ', '');
      _isLoading = false;
      _isAuthenticated = false;
      notifyListeners();
      Logger.e('AuthProvider', 'Organization selection failed', e);
      rethrow;
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      Logger.i('AuthProvider', 'Logging out user');

      _isLoading = true;
      notifyListeners();

      // Clear token and user data
      await _authService.logout();

      _user = null;
      _token = null;
      _isAuthenticated = false;
      _error = null;

      // Clear temp token if exists
      await LocalStorage.remove('temp_token');
      await LocalStorage.remove('selected_org_name');

      _isLoading = false;
      notifyListeners();

      Logger.i('AuthProvider', 'Logout successful');
    } catch (e) {
      Logger.e('AuthProvider', 'Logout failed', e);
      // Clear local state anyway
      _user = null;
      _token = null;
      _isAuthenticated = false;
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _cacheOrganizationNames(List<OrganizationModel> organizations) {
    _organizationNameByKey.clear();
    for (final org in organizations) {
      final name = org.name.trim();
      if (name.isEmpty) continue;

      final id = org.id?.trim();
      if (id != null && id.isNotEmpty) {
        _organizationNameByKey[id] = name;
      }

      final prefix = org.prefix.trim();
      if (prefix.isNotEmpty) {
        _organizationNameByKey[prefix] = name;
      }
    }
  }

  String? _resolveOrganizationName(String? selectedOrgId, String? userOrgId) {
    final selected = selectedOrgId?.trim();
    if (selected != null && selected.isNotEmpty) {
      final name = _organizationNameByKey[selected];
      if (name != null && name.isNotEmpty) return name;
    }

    final userId = userOrgId?.trim();
    if (userId != null && userId.isNotEmpty) {
      final name = _organizationNameByKey[userId];
      if (name != null && name.isNotEmpty) return name;
    }

    return null;
  }
}
