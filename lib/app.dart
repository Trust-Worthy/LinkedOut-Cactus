import 'package:flutter/material.dart';
import 'presentation/screens/home/home_screen.dart';
// Change the import to the new screen
import 'presentation/screens/onboarding/getstarted_screen.dart'; 

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
        // Using your friend's blue as the seed color if you prefer, or keep green
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1f6db4)),
        useMaterial3: true,
      ),
      // Logic: If user is new, show GetStartedScreen. Otherwise, Home.
      home: startOnboarding ? const GetStartedScreen() : const HomeScreen(),
    );
  }
}