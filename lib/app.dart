import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/onboarding/getstarted_screen.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'services/auth/auth_provider.dart';
import 'data/models/auth_state.dart';

class LinkedOutApp extends StatelessWidget {
  const LinkedOutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LinkedOut',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1f6db4)),
        useMaterial3: true,
      ),
      home: Consumer<AuthProvider>(
        builder: (context, authProvider, _) {
          // Show loading screen while initializing
          if (authProvider.state == AuthState.initial ||
              authProvider.state == AuthState.loading) {
            return const Scaffold(
              backgroundColor: Colors.black,
              body: Center(
                child: CircularProgressIndicator(color: Colors.blue),
              ),
            );
          }

          // If authenticated, check onboarding status
          if (authProvider.isAuthenticated) {
            if (authProvider.hasCompletedOnboarding) {
              return const HomeScreen();
            } else {
              return const GetStartedScreen();
            }
          }

          // Not authenticated, show login
          return const LoginScreen();
        },
      ),
    );
  }
}
