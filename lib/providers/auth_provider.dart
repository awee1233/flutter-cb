import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class AuthProvider with ChangeNotifier {
  static const String _baseUrl = 'http://192.168.56.1:8000/api';

  String? _token;
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  String? _error;

  // Getters
  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _token != null;
  bool get isAdmin => _user != null && _user!['email'] == 'admin@admin.com';
  String get role => isAdmin ? 'admin' : 'user';

  // Initialize the provider
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      final userStr = prefs.getString('user');

      if (userStr != null) {
        _user = json.decode(userStr);
        if (!await _validateToken()) {
          await _clearAuthData();
        }
      }
    } catch (e) {
      debugPrint('Init error: $e');
      _error = 'Failed to initialize: $e';
      await _clearAuthData();
    }
    notifyListeners();
  }

  // Validate the token
  Future<bool> _validateToken() async {
    if (_token == null) return false;

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/chat'),
        headers: {
          'Authorization': 'Bearer $_token',
          'Accept': 'application/json',
        },
      );

      debugPrint('Validate token response: ${response.statusCode}');
      debugPrint('Validate token body: ${response.body}');

      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Validate token error: $e');
      return false;
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      debugPrint('Login response status: ${response.statusCode}');
      debugPrint('Login response body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['token'] != null) {
        _token = data['token'];
        _user = data['user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        await prefs.setString('user', json.encode(_user));

        _error = null;
        notifyListeners();
        return true;
      } else {
        _error = data['message'] ?? 'Authentication failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('Login error: $e');
      _error = 'Failed to login: $e';
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      if (_token != null) {
        await http.post(
          Uri.parse('$_baseUrl/logout'),
          headers: {
            'Authorization': 'Bearer $_token',
            'Accept': 'application/json',
          },
        );
      }
    } catch (e) {
      debugPrint('Logout error: $e');
    } finally {
      await _clearAuthData();
      notifyListeners();
    }
  }

  // Clear authentication data
  Future<void> _clearAuthData() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('user');
  }
}
