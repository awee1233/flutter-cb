import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/chat_screen.dart';
import '../screens/search_screen.dart';
import '../screens/login_screen.dart';
import '../screens/admin_screen.dart';

class SideMenu extends StatelessWidget {
  final VoidCallback? onProviderManagementTap;

  const SideMenu({
    super.key,
    this.onProviderManagementTap,
  });

  Future<void> _handleLogout(BuildContext context) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldLogout == true && context.mounted) {
      await authProvider.logout();

      if (context.mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          final bool isAdmin = authProvider.isAdmin;

          return Column(
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withOpacity(0.1),
                ),
                currentAccountPicture: Image.asset(
                  'assets/images/logo.png',
                  width: 60,
                  height: 60,
                ),
                accountName: Text(
                  isAdmin ? 'Admin Dashboard' : 'User Dashboard',
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  authProvider.user?['email'] ?? '',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
              Expanded(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.chat),
                      title: const Text('Chat'),
                      onTap: () {
                        Navigator.pop(context); // Close drawer first
                        if (ModalRoute.of(context)?.settings.name != '/') {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const ChatScreen()),
                          );
                        }
                      },
                    ),
                    if (isAdmin) ...[
                      ListTile(
                        leading: const Icon(Icons.settings_applications),
                        title: const Text('Provider Management'),
                        onTap: () {
                          Navigator.pop(context); // Close drawer first
                          if (onProviderManagementTap != null) {
                            onProviderManagementTap!();
                          } else {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AdminScreen(),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                    ListTile(
                      leading: const Icon(Icons.search),
                      title: const Text('Search'),
                      onTap: () {
                        Navigator.pop(context); // Close drawer first
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const SearchScreen()),
                        );
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.settings),
                      title: const Text('Settings'),
                      onTap: () {
                        Navigator.pop(context); // Close drawer first
                        // TODO: Implement settings navigation
                      },
                    ),
                  ],
                ),
              ),
              Divider(color: Colors.grey[300]),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Log Out',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () => _handleLogout(context),
              ),
              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}
