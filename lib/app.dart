import 'package:flutter/material.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/onboarding/onboarding_screen.dart';

class LinkedOutApp extends StatelessWidget {
  final bool startOnboarding;

  const LinkedOutApp({
    super.key, 
    required this.startOnboarding
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LinkedOut',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF00C853)),
        useMaterial3: true,
      ),
      // If user hasn't downloaded models yet, go to Onboarding
      // Otherwise, go straight to Home
      home: startOnboarding ? const OnboardingScreen() : const HomeScreen(),
    );
  }
}