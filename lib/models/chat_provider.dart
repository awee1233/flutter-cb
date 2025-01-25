import 'dart:convert';

class ChatProvider {
  final int id;
  final String name;
  final String endpoint;
  final bool isActive;
  final Map<String, dynamic> config;

  ChatProvider({
    required this.id,
    required this.name,
    required this.endpoint,
    required this.isActive,
    required this.config,
  });

  factory ChatProvider.fromJson(Map<String, dynamic> json) {
    var configData = json['config'];
    Map<String, dynamic> configMap = {};

    if (configData != null) {
      if (configData is List) {
        // Convert List directly to a map structure
        configMap = {
          'model': configData.isNotEmpty ? configData[0] : 'default-model',
          'temperature': 0.7,
          'max_tokens': 1000,
        };
      } else if (configData is Map) {
        configMap = Map<String, dynamic>.from(configData);
      } else if (configData is String) {
        try {
          var decoded = jsonDecode(configData);
          if (decoded is List) {
            configMap = {
              'model': decoded.isNotEmpty ? decoded[0] : 'default-model',
              'temperature': 0.7,
              'max_tokens': 1000,
            };
          } else if (decoded is Map) {
            configMap = Map<String, dynamic>.from(decoded);
          }
        } catch (e) {
          print('Error parsing config: $e');
          configMap = {
            'model': 'default-model',
            'temperature': 0.7,
            'max_tokens': 1000,
          };
        }
      }
    }

    // Ensure required fields exist
    if (!configMap.containsKey('model')) {
      configMap['model'] = 'default-model';
    }
    if (!configMap.containsKey('temperature')) {
      configMap['temperature'] = 0.7;
    }
    if (!configMap.containsKey('max_tokens')) {
      configMap['max_tokens'] = 1000;
    }

    return ChatProvider(
      id: json['id'] as int,
      name: json['name'] as String,
      endpoint: json['endpoint'] as String,
      isActive: json['is_active'] as bool? ?? true,
      config: configMap,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'endpoint': endpoint,
    'is_active': isActive,
    'config': config,
  };
}