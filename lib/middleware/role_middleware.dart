import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/admin_screen.dart';
import '../screens/user_dashboard.dart';
import '../screens/login_screen.dart';

class RoleMiddleware {
  static Widget checkRole(
      BuildContext context, Widget destination, List<String> allowedRoles) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (!authProvider.isAuthenticated) {
          return const LoginScreen();
        }

        final userRole = authProvider.isAdmin ? 'admin' : 'user';
        if (!allowedRoles.contains(userRole)) {
          return authProvider.isAdmin
              ? const AdminScreen()
              : const UserDashboard();
        }

        return destination;
      },
    );
  }
}
