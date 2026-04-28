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
  String? _infoMessage;
  bool _isAuthenticated = false;

  // Getters
  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get infoMessage => _infoMessage;
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

  /// Registers a new user. Returns true when the API accepted the registration
  /// (email verification still pending). The verification message from the API
  /// is exposed via [infoMessage].
  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _error = null;
    _infoMessage = null;
    notifyListeners();

    try {
      _infoMessage = await _authService.register(
        name: name,
        email: email,
        phone: phone,
        password: password,
        confirmPassword: confirmPassword,
      );
      // No user session yet — verification is required before login.
      _isAuthenticated = false;
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
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

  /// Updates the user's profile data (email, phone, birthday, bio, avatar,
  /// dietaryPreference) locally.
  Future<bool> updateProfile({
    String? email,
    String? phone,
    String? birthday,
    String? bio,
    String? avatar,
    String? dietaryPreference,
  }) async {
    if (_user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = _user!.copyWith(
        email: email ?? _user!.email,
        phone: phone ?? _user!.phone,
        birthday: birthday ?? _user!.birthday,
        bio: bio ?? _user!.bio,
        avatar: avatar ?? _user!.avatar,
        dietaryPreference: dietaryPreference ?? _user!.dietaryPreference,
      );

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

  /// Verifies email address with OTP token code.
  Future<bool> verifyEmail({
    required String email,
    required String token,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _authService.verifyEmail(
        email: email,
        token: token,
      );
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resend verification email code
  Future<bool> resendVerificationCode({
    required String email,
  }) async {
    _isLoading = true;
    _error = null;
    _infoMessage = null;
    notifyListeners();

    try {
      _infoMessage = await _authService.resendVerificationCode(
        email: email,
      );
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Resets the user's password using a token sent to their email.
  Future<bool> resetPassword({
    required String resetToken,
    required String newPassword,
    required String confirmPassword,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resetPassword(
        resetToken: resetToken,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      return true;
    } catch (e) {
      _error = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches latest user profile from API and updates local state
  Future<void> fetchUserProfile() async {
    if (_user == null) return;

    _isLoading = true;
    notifyListeners();

    try {
      _user = await _authService.fetchUserProfile();
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Gets the user's initials for avatar.
  String get userInitials => _user?.initials ?? 'U';
}
