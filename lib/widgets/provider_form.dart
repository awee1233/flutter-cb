import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/chat_provider.dart';
import '../providers/chat_provider.dart';

class ProviderForm extends StatefulWidget {
  final ChatProvider? provider;
  final VoidCallback onSave;

  const ProviderForm({
    super.key,
    this.provider,
    required this.onSave,
  });

  @override
  State<ProviderForm> createState() => _ProviderFormState();
}

class _ProviderFormState extends State<ProviderForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _apiKeyController = TextEditingController();
  final _endpointController = TextEditingController();
  final _configController = TextEditingController();
  bool _isActive = true;
  bool _showPassword = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.provider != null) {
      _nameController.text = widget.provider!.name;
      _endpointController.text = widget.provider!.endpoint;
      _configController.text = _formatJson(widget.provider!.config);
      _isActive = widget.provider!.isActive;
    } else {
      _setDefaultConfig();
    }
  }

  String _formatJson(Map<String, dynamic> json) {
    return const JsonEncoder.withIndent('  ').convert(json);
  }

  void _setDefaultConfig() {
    final defaultConfig = {
      'model': 'gpt-3.5-turbo',
      'temperature': 0.7,
      'max_tokens': 1000,
    };
    _configController.text = _formatJson(defaultConfig);
  }

  Future<void> _saveProvider() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final configJson = json.decode(_configController.text);
      if (configJson is! Map<String, dynamic>) {
        throw const FormatException('Configuration must be a JSON object');
      }

      final chatProvider =
          Provider.of<ChatProviderModel>(context, listen: false);
      final Map<String, dynamic> providerData = {
        'name': _nameController.text.trim(),
        'endpoint': _endpointController.text.trim(),
        'config': configJson,
        'is_active': _isActive,
      };

      if (_apiKeyController.text.isNotEmpty) {
        providerData['api_key'] = _apiKeyController.text.trim();
      }

      bool success;
      if (widget.provider != null) {
        success = await chatProvider.updateProvider(
          widget.provider!.id,
          providerData,
        );
      } else {
        success = await chatProvider.createProvider(providerData);
      }

      if (!mounted) return;

      if (success) {
        widget.onSave();
        Navigator.of(context).pop();
        _showSnackBar(
          widget.provider != null
              ? 'Provider updated successfully'
              : 'Provider created successfully',
          Colors.green,
        );
      } else {
        _showSnackBar(
          chatProvider.error ?? 'Failed to save provider',
          Colors.red,
        );
      }
    } catch (e) {
      _showSnackBar('Error: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(16.0),
        constraints: const BoxConstraints(maxWidth: 500),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      widget.provider != null
                          ? 'Edit Provider'
                          : 'Add New Provider',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Provider Name',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.label),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _apiKeyController,
                  decoration: InputDecoration(
                    labelText: 'API Key',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.key),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _showPassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                  ),
                  obscureText: !_showPassword,
                  validator: (value) {
                    if (widget.provider == null &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Please enter an API key';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _endpointController,
                  decoration: const InputDecoration(
                    labelText: 'API Endpoint',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.link),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter an endpoint';
                    }
                    if (!Uri.tryParse(value)!.isAbsolute) {
                      return 'Please enter a valid URL';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _configController,
                  decoration: const InputDecoration(
                    labelText: 'Configuration (JSON)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.code),
                    helperText: 'Enter a valid JSON configuration object',
                  ),
                  maxLines: 8,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter configuration';
                    }
                    try {
                      final decoded = json.decode(value);
                      if (decoded is! Map<String, dynamic>) {
                        return 'Configuration must be a JSON object';
                      }
                      return null;
                    } catch (e) {
                      return 'Please enter valid JSON';
                    }
                  },
                ),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Active'),
                  subtitle: Text(
                    _isActive
                        ? 'Provider will be available for chat'
                        : 'Provider will be disabled for chat',
                  ),
                  value: _isActive,
                  activeColor: Colors.green,
                  onChanged: (value) {
                    setState(() {
                      _isActive = value;
                    });
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _saveProvider,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(widget.provider != null
                                    ? Icons.save
                                    : Icons.add),
                                const SizedBox(width: 8),
                                Text(widget.provider != null
                                    ? 'Update'
                                    : 'Create'),
                              ],
                            ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _apiKeyController.dispose();
    _endpointController.dispose();
    _configController.dispose();
    super.dispose();
  }
}
