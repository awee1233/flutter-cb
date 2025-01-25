import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/chat_screen.dart';
import '../screens/search_screen.dart';
import '../screens/login_screen.dart';
import '../models/chat_provider.dart';

class UserDashboard extends StatefulWidget {
  const UserDashboard({super.key});

  @override
  _UserDashboardState createState() => _UserDashboardState();
}

class _UserDashboardState extends State<UserDashboard> {
  int _selectedIndex = 0;
  ChatProvider? _selectedProvider;
  final List<ChatProvider> _availableProviders = []; // Load from API

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const ChatScreen(),
      const SearchScreen(),
      _buildProfileTab(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          _selectedIndex == 0
              ? 'Chat'
              : _selectedIndex == 1
                  ? 'Search'
                  : 'Profile',
          style: const TextStyle(color: Colors.black),
        ),
        actions: [
          if (_selectedIndex == 0) ...[
            PopupMenuButton<ChatProvider>(
              icon: const Icon(Icons.swap_horiz, color: Colors.black),
              tooltip: 'Select Provider',
              onSelected: (ChatProvider provider) {
                setState(() {
                  _selectedProvider = provider;
                });
              },
              itemBuilder: (BuildContext context) {
                return _availableProviders
                    .where((p) => p.isActive)
                    .map((ChatProvider provider) {
                  return PopupMenuItem<ChatProvider>(
                    value: provider,
                    child: Text(provider.name),
                  );
                }).toList();
              },
            ),
            IconButton(
              icon: const Icon(Icons.search, color: Colors.black),
              onPressed: () {
                setState(() {
                  _selectedIndex = 1;
                });
              },
            ),
          ],
        ],
      ),
      body: pages[_selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Search',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 50,
            backgroundColor: Color(0xFF2F80ED),
            child: Icon(Icons.person, size: 50, color: Colors.white),
          ),
          const SizedBox(height: 24),
          Text(
            user?['name'] ?? 'User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            user?['email'] ?? '',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 32),
          _buildProfileMenuItem(
            icon: Icons.person_outline,
            title: 'Edit Profile',
            onTap: () {
              // TODO: Implement edit profile
            },
          ),
          _buildProfileMenuItem(
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            onTap: () {
              // TODO: Implement notifications
            },
          ),
          _buildProfileMenuItem(
            icon: Icons.security_outlined,
            title: 'Security',
            onTap: () {
              // TODO: Implement security settings
            },
          ),
          _buildProfileMenuItem(
            icon: Icons.help_outline,
            title: 'Help & Support',
            onTap: () {
              // TODO: Implement help & support
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                final bool? shouldLogout = await showDialog<bool>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Confirm Logout'),
                    content: const Text('Are you sure you want to logout?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text(
                          'Logout',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                );

                if (shouldLogout == true) {
                  await authProvider.logout();
                  if (!mounted) return;
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                    (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFF2F80ED)),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
