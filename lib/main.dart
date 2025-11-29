import 'package:flutter/material.dart';
import 'screens/getstarted_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LinkedOut',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1f6db4),
          primary: const Color(0xFF1f6db4),
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const GetStartedScreen(),
    );
  }
}
