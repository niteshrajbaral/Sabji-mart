import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../config/api_config.dart';

/// Service class for handling authentication API calls and session management.
class AuthService {
  static const String _userKey = 'user_data';

  /// Logs in a user with email/phone and password.
  /// Returns UserModel on success, throws exception on failure.
  Future<UserModel> login({
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      // Use the full URL directly as provided by the user
      final url = Uri.parse('https://api.beta.order.rebuzzpos.com/api/auth/login');
      
      debugPrint('[AuthService] Logging in to: $url');
      debugPrint('[AuthService] Request body: emailOrPhone=$emailOrPhone, password=${'*' * password.length}');
      
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'app': 'customer', // Required by the API
        },
        body: jsonEncode({
          'emailOrPhone': emailOrPhone,
          'password': password,
        }),
      );

      debugPrint('[AuthService] Login response status: ${response.statusCode}');
      debugPrint('[AuthService] Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'success') {
          final user = UserModel.fromJson(data);
          
          // Store user data in shared preferences
          await _saveUser(user);
          
          debugPrint('[AuthService] Login successful for user: ${user.userId}');
          return user;
        } else {
          throw Exception(data['message'] ?? 'Login failed');
        }
      } else {
        // Try to parse error message from response
        String errorMessage = 'Login failed: ${response.statusCode}';
        try {
          final errorData = jsonDecode(response.body);
          if (errorData is Map) {
            errorMessage = errorData['message'] ?? errorData['error'] ?? errorMessage;
          }
        } catch (_) {
          // If we can't parse the error, use the raw body
          if (response.body.isNotEmpty) {
            errorMessage = response.body;
          }
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      debugPrint('[AuthService] Login error: $e');
      rethrow;
    }
  }

  /// Registers a new user.
  /// Note: This is a placeholder - adjust based on actual registration API
  Future<UserModel> register({
    required String name,
    required String emailOrPhone,
    required String password,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.authUrl}/auth/register');
      
      debugPrint('[AuthService] Registering from: $url');
      
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': name,
          'emailOrPhone': emailOrPhone,
          'password': password,
        }),
      );

      debugPrint('[AuthService] Register response status: ${response.statusCode}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        
        if (data['status'] == 'success') {
          final user = UserModel.fromJson(data);
          await _saveUser(user);
          return user;
        } else {
          throw Exception(data['message'] ?? 'Registration failed');
        }
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Registration failed: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[AuthService] Register error: $e');
      rethrow;
    }
  }

  /// Logs out the current user by clearing stored data.
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userKey);
      debugPrint('[AuthService] User logged out');
    } catch (e) {
      debugPrint('[AuthService] Logout error: $e');
      rethrow;
    }
  }

  /// Retrieves the stored user data if available.
  Future<UserModel?> getStoredUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      
      if (userData != null) {
        final data = jsonDecode(userData) as Map<String, dynamic>;
        return UserModel.fromStorage(data);
      }
      return null;
    } catch (e) {
      debugPrint('[AuthService] Get stored user error: $e');
      return null;
    }
  }

  /// Checks if a user is currently logged in.
  Future<bool> isLoggedIn() async {
    final user = await getStoredUser();
    return user != null;
  }

  /// Saves user data to shared preferences.
  Future<void> _saveUser(UserModel user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      debugPrint('[AuthService] User data saved');
    } catch (e) {
      debugPrint('[AuthService] Save user error: $e');
      rethrow;
    }
  }

  /// Updates the stored user data.
  Future<void> updateUser(UserModel user) async {
    await _saveUser(user);
  }

  /// Gets the current session token if user is logged in.
  Future<String?> getSessionToken() async {
    final user = await getStoredUser();
    return user?.sessionToken;
  }
}