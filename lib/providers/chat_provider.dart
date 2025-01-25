import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'auth_provider.dart';

class ChatProviderModel with ChangeNotifier {
  static const String _baseUrl = 'http://192.168.56.1:8000/api';

  final AuthProvider _authProvider;
  List<Map<String, dynamic>> _providers = [];
  Map<String, dynamic>? _selectedProvider;
  bool _isLoading = false;
  String? _error;

  ChatProviderModel(this._authProvider);

  // Getters
  List<Map<String, dynamic>> get providers => _providers;
  List<Map<String, dynamic>> get activeProviders =>
      _providers.where((p) => p['is_active'] == true).toList();
  List<Map<String, dynamic>> get inactiveProviders =>
      _providers.where((p) => p['is_active'] == false).toList();
  Map<String, dynamic>? get selectedProvider => _selectedProvider;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Load providers
  Future<void> loadProviders() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.get(
        Uri.parse('$_baseUrl/chat/providers'),
        headers: {
          'Authorization': 'Bearer ${_authProvider.token}',
          'Accept': 'application/json',
        },
      );

      debugPrint('Load providers response: ${response.statusCode}');
      debugPrint('Load providers body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          _providers = List<Map<String, dynamic>>.from(data['providers']);

          // Update selected provider
          if (_selectedProvider == null) {
            // If no provider is selected, select first active provider
            if (activeProviders.isNotEmpty) {
              _selectedProvider = activeProviders.first;
            }
          } else {
            // If a provider is selected, update its data or select new one if it was removed
            final currentProvider = _providers.firstWhere(
              (p) => p['id'] == _selectedProvider!['id'],
              orElse: () => activeProviders.isNotEmpty
                  ? activeProviders.first
                  : _providers.first,
            );
            _selectedProvider = currentProvider;
          }

          _error = null;
        } else {
          _error = data['message'] ?? 'Failed to load providers';
        }
      } else {
        final errorData = json.decode(response.body);
        _error = errorData['message'] ?? 'Failed to load providers';
      }
    } catch (e) {
      debugPrint('Error loading providers: $e');
      _error = 'Error: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Create provider
  Future<bool> createProvider(Map<String, dynamic> provider) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      debugPrint('Creating provider with data: ${json.encode(provider)}');

      final response = await http.post(
        Uri.parse('$_baseUrl/providers'),
        headers: {
          'Authorization': 'Bearer ${_authProvider.token}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(provider),
      );

      debugPrint('Create provider response: ${response.statusCode}');
      debugPrint('Create provider body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        await loadProviders();
        return true;
      }

      _error = data['message'] ?? 'Failed to create provider';
      return false;
    } catch (e) {
      debugPrint('Error creating provider: $e');
      _error = 'Error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update provider
  Future<bool> updateProvider(int id, Map<String, dynamic> provider) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.put(
        Uri.parse('$_baseUrl/providers/$id'),
        headers: {
          'Authorization': 'Bearer ${_authProvider.token}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode(provider),
      );

      debugPrint('Update provider response: ${response.statusCode}');
      debugPrint('Update provider body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        await loadProviders();
        return true;
      }

      _error = data['message'] ?? 'Failed to update provider';
      return false;
    } catch (e) {
      debugPrint('Error updating provider: $e');
      _error = 'Error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete provider
  Future<bool> deleteProvider(int id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.delete(
        Uri.parse('$_baseUrl/providers/$id'),
        headers: {
          'Authorization': 'Bearer ${_authProvider.token}',
          'Accept': 'application/json',
        },
      );

      debugPrint('Delete provider response: ${response.statusCode}');
      debugPrint('Delete provider body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 409) {
        _error =
            data['message'] ?? 'Cannot delete provider with existing chats';
        return false;
      }

      if (response.statusCode == 200 && data['success'] == true) {
        if (_selectedProvider != null && _selectedProvider!['id'] == id) {
          _selectedProvider = null;
        }
        await loadProviders();
        return true;
      }

      _error = data['message'] ?? 'Failed to delete provider';
      return false;
    } catch (e) {
      debugPrint('Error deleting provider: $e');
      _error = 'Error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Toggle provider status
  Future<bool> toggleProvider(int id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      final response = await http.patch(
        Uri.parse('$_baseUrl/providers/$id/toggle'),
        headers: {
          'Authorization': 'Bearer ${_authProvider.token}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      );

      debugPrint('Toggle provider response: ${response.statusCode}');
      debugPrint('Toggle provider body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        // If we're deactivating the currently selected provider,
        // try to select another active provider
        if (_selectedProvider != null && _selectedProvider!['id'] == id) {
          await loadProviders();
          if (activeProviders.isNotEmpty) {
            _selectedProvider = activeProviders.first;
          } else {
            _selectedProvider = null;
          }
        } else {
          await loadProviders();
        }
        return true;
      }

      _error = data['message'] ?? 'Failed to toggle provider';
      return false;
    } catch (e) {
      debugPrint('Error toggling provider: $e');
      _error = 'Error: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Send chat message
  Future<Map<String, dynamic>> sendMessage(String message) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      if (_selectedProvider == null) {
        throw Exception('No provider selected');
      }

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/send'),
        headers: {
          'Authorization': 'Bearer ${_authProvider.token}',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'message': message,
          'provider_id': _selectedProvider!['id'],
        }),
      );

      debugPrint('Send message response: ${response.statusCode}');
      debugPrint('Send message body: ${response.body}');

      final data = json.decode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        return data;
      }

      _error = data['message'] ?? 'Failed to send message';
      throw Exception(_error);
    } catch (e) {
      debugPrint('Error sending message: $e');
      _error = 'Error: $e';
      throw Exception(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper methods
  void selectProvider(Map<String, dynamic> provider) {
    if (provider['is_active'] == true) {
      _selectedProvider = provider;
      notifyListeners();
    } else {
      _error = 'Cannot select inactive provider';
      notifyListeners();
    }
  }

  bool providerExists(String name) {
    return _providers.any((provider) =>
        provider['name'].toString().toLowerCase() == name.toLowerCase());
  }

  Map<String, dynamic>? getProviderById(int id) {
    try {
      return _providers.firstWhere((provider) => provider['id'] == id);
    } catch (e) {
      return null;
    }
  }

  String? validateProviderData(Map<String, dynamic> provider) {
    if (provider['name']?.isEmpty ?? true) {
      return 'Provider name is required';
    }
    if (provider['api_key']?.isEmpty ?? true) {
      return 'API key is required';
    }
    if (provider['endpoint']?.isEmpty ?? true) {
      return 'Endpoint URL is required';
    }

    // Validate config if provided
    if (provider['config'] != null) {
      try {
        if (provider['config'] is String) {
          json.decode(provider['config']);
        }
      } catch (e) {
        return 'Invalid JSON configuration';
      }
    }

    return null;
  }
}
