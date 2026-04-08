import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

/// Authentication state management provider.
/// Manages user authentication state, login/logout, and session persistence.
class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  
  UserModel? _user;
  bool _isLoading = false;
  String? _error;
  bool _isAuthenticated = false;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _isAuthenticated;

  /// Initializes the auth provider by checking for stored user session.
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.getStoredUser();
      _isAuthenticated = _user != null;
      _error = null;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logs in a user with email/phone and password.
  Future<bool> login({
    required String emailOrPhone,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.login(
        emailOrPhone: emailOrPhone,
        password: password,
      );
      _isAuthenticated = true;
      return true;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Registers a new user.
  Future<bool> register({
    required String name,
    required String emailOrPhone,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authService.register(
        name: name,
        emailOrPhone: emailOrPhone,
        password: password,
      );
      _isAuthenticated = true;
      return true;
    } catch (e) {
      _error = e.toString();
      _isAuthenticated = false;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Logs out the current user.
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
      _user = null;
      _isAuthenticated = false;
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Updates the user's profile data (email, phone, birthday) locally.
  Future<bool> updateProfile({
    String? email,
    String? phone,
    String? birthday,
  }) async {
    if (_user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Create updated user with new data
      _user = _user!.copyWith(
        email: email ?? _user!.email,
        phone: phone ?? _user!.phone,
        birthday: birthday ?? _user!.birthday,
      );

      // Save updated user to storage
      await _authService.updateUser(_user!);
      return true;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Clears any error messages.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Gets the current session token.
  Future<String?> getSessionToken() async {
    return await _authService.getSessionToken();
  }

  /// Checks if a user is logged in (without loading from storage).
  bool get isLoggedIn => _isAuthenticated && _user != null;

  /// Gets the user's display name.
  String get displayName => _user?.displayName ?? 'User';

  /// Gets the user's initials for avatar.
  String get userInitials => _user?.initials ?? 'U';
}
