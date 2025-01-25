import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/chat_provider.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/admin_screen.dart';
import 'screens/user_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProxyProvider<AuthProvider, ChatProviderModel>(
          create: (context) => ChatProviderModel(
            Provider.of<AuthProvider>(context, listen: false),
          ),
          update: (context, auth, previous) =>
              previous ?? ChatProviderModel(auth),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF2F80ED),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2F80ED),
          primary: const Color(0xFF2F80ED),
          secondary: const Color(0xFF4F4F4F),
          background: Colors.white,
        ),
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF333333),
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            color: Color(0xFF4F4F4F),
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            color: Color(0xFF4F4F4F),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2F80ED),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF4F4F4F),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            side: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF2F80ED), width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFF4F4F4F)),
        ),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return FutureBuilder(
            future: authProvider.init(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SplashScreen();
              }

              if (authProvider.isAuthenticated) {
                return authProvider.isAdmin
                    ? const AdminScreen()
                    : const UserDashboard();
              }

              return const LoginScreen();
            },
          );
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/admin': (context) => const AdminScreen(),
        '/dashboard': (context) => const UserDashboard(),
      },
    );
  }
}
