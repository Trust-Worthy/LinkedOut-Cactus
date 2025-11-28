import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../services/ai/cactus_service.dart';
import '../home/home_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  double _progress = 0.0;
  String _status = "Waiting to start...";
  bool _isDownloading = false;
  bool _isComplete = false;

  @override
  void initState() {
    super.initState();
    // Auto-start download when screen loads
    _startDownloadProcess();
  }

  Future<void> _startDownloadProcess() async {
    setState(() {
      _isDownloading = true;
      _status = "Connecting to Cactus AI...";
    });

    try {
      await CactusService.instance.downloadModel(
        onProgress: (progress, status) {
          setState(() {
            _progress = progress;
            _status = status;
          });
        },
      );

      setState(() {
        _isComplete = true;
        _status = "AI Ready! Setting up secure environment...";
      });

      // Mark onboarding as done so we don't show this screen again
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('has_onboarded', true);

      // Wait a moment for user to see "Success" then navigate
      await Future.delayed(const Duration(seconds: 1));
      
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      }

    } catch (e) {
      setState(() {
        _status = "Error: $e";
        _isDownloading = false; // Allow retry
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security, size: 80, color: Colors.green),
            const SizedBox(height: 24),
            const Text(
              "Setting up LinkedOut",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "We are downloading the privacy-first AI models to your device. This happens only once.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 48),
            
            // Progress Bar
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey[200],
              color: Colors.green,
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 16),
            Text(
              _status,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            
            // Retry Button (Only if failed)
            if (!_isDownloading && !_isComplete)
              Padding(
                padding: const EdgeInsets.only(top: 20),
                child: ElevatedButton(
                  onPressed: _startDownloadProcess,
                  child: const Text("Retry Download"),
                ),
              )
          ],
        ),
      ),
    );
  }
}