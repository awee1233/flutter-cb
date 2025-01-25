import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/side_menu.dart';
import '../widgets/provider_form.dart';
import '../models/chat_provider.dart';
import '../providers/chat_provider.dart';
import 'chat_screen.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedIndex = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProviders();
  }

  Future<void> _loadProviders() async {
    if (!mounted) return;
    final chatProvider = Provider.of<ChatProviderModel>(context, listen: false);
    await chatProvider.loadProviders();
    setState(() {
      _isLoading = false;
    });
  }

  void _navigateToProviderManagement() {
    setState(() {
      _selectedIndex = 1;
    });
  }

  Future<void> _deleteProvider(BuildContext context, int providerId) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text(
            'Are you sure you want to delete this provider? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      final chatProvider =
          Provider.of<ChatProviderModel>(context, listen: false);
      final success = await chatProvider.deleteProvider(providerId);

      if (!mounted) return;

      final message = chatProvider.error ?? 'Failed to delete provider';
      final isWarning = message.contains('has existing chat history');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
              success ? Colors.green : (isWarning ? Colors.orange : Colors.red),
          action: isWarning
              ? SnackBarAction(
                  label: 'Archive Instead',
                  textColor: Colors.white,
                  onPressed: () async {
                    // Here you would call the toggle provider method instead
                    final success =
                        await chatProvider.toggleProvider(providerId);
                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          success
                              ? 'Provider archived successfully'
                              : 'Failed to archive provider',
                        ),
                        backgroundColor: success ? Colors.green : Colors.red,
                      ),
                    );
                  },
                )
              : null,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.background,
        elevation: 0,
        title: Text(
          _selectedIndex == 0 ? 'Chat' : 'Provider Management',
          style: TextStyle(color: Theme.of(context).colorScheme.onBackground),
        ),
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.onBackground),
        actions: [
          if (_selectedIndex == 1)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () => _showProviderForm(context),
            ),
        ],
      ),
      drawer: SideMenu(
        onProviderManagementTap: _navigateToProviderManagement,
      ),
      body: _selectedIndex == 0
          ? const ChatScreen(showAppBar: false)
          : _buildProviderManagement(),
    );
  }

  Widget _buildProviderManagement() {
    return Consumer<ChatProviderModel>(
      builder: (context, chatProvider, child) {
        if (_isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (chatProvider.error != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Error: ${chatProvider.error}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadProviders,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (chatProvider.providers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text('No providers found'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => _showProviderForm(context),
                  icon: const Icon(Icons.add),
                  label: const Text('Add Provider'),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: _loadProviders,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (chatProvider.activeProviders.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Text(
                    'Active Providers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...chatProvider.activeProviders
                    .map((provider) => _buildProviderCard(
                          provider,
                          chatProvider,
                          isActive: true,
                        )),
              ],
              if (chatProvider.inactiveProviders.isNotEmpty) ...[
                Padding(
                  padding: EdgeInsets.only(
                    top: chatProvider.activeProviders.isNotEmpty ? 24 : 8,
                    bottom: 8,
                  ),
                  child: const Text(
                    'Inactive Providers',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...chatProvider.inactiveProviders
                    .map((provider) => _buildProviderCard(
                          provider,
                          chatProvider,
                          isActive: false,
                        )),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildProviderCard(
    Map<String, dynamic> provider,
    ChatProviderModel chatProvider, {
    required bool isActive,
  }) {
    final config = (provider['config'] as Map<String, dynamic>?) ?? {};

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            color: isActive
                ? Colors.green.withOpacity(0.5)
                : Colors.grey.withOpacity(0.3),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            ListTile(
              title: Row(
                children: [
                  Expanded(
                    child: Text(
                      provider['name'] as String? ?? 'Unnamed Provider',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.green.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isActive
                            ? Colors.green.withOpacity(0.5)
                            : Colors.grey.withOpacity(0.5),
                      ),
                    ),
                    child: Text(
                      isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        fontSize: 12,
                        color: isActive ? Colors.green : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.link, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          provider['endpoint'] as String? ?? 'No endpoint',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.settings, size: 16, color: Colors.grey),
                      const SizedBox(width: 4),
                      Text(
                        'Model: ${config['model'] ?? 'Not specified'}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit),
                    color: Colors.blue,
                    onPressed: () => _showProviderForm(
                      context,
                      provider: ChatProvider.fromJson(provider),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    color: Theme.of(context).colorScheme.error,
                    onPressed: () => _deleteProvider(
                      context,
                      provider['id'] as int,
                    ),
                  ),
                ],
              ),
              isThreeLine: true,
            ),
          ],
        ),
      ),
    );
  }

  void _showProviderForm(BuildContext context, {ChatProvider? provider}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => ProviderForm(
        provider: provider,
        onSave: () {
          _loadProviders();
        },
      ),
    );
  }
}
