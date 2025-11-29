import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart'; 
import '../../../services/ai/cactus_service.dart';
import '../../../services/location/location_service.dart';
import 'scan_result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isProcessing = false;
  String _statusMessage = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _takePicture();
    });
  }

  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );

      if (photo != null) {
        await _processImage(photo.path);
      } else {
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      _showError("Camera Error: $e");
    }
  }

  Future<void> _processImage(String path) async {
    setState(() {
      _isProcessing = true;
      _statusMessage = "Analyzing card & finding location...";
    });

    try {
      // --- PARALLEL EXECUTION ---
      // We start both tasks at the same time to save seconds.
      
      // Task 1: Run On-Device Vision AI (OCR)
      final ocrFuture = CactusService.instance.scanBusinessCard(path);
      
      // Task 2: Get GPS Coordinates (Background)
      final locationFuture = LocationService.instance.getCurrentLocation();

      // Wait for both to finish
      final results = await Future.wait([ocrFuture, locationFuture]);
      
      final rawText = results[0] as String;
      final position = results[1] as Position?;

      if (mounted) {
        setState(() => _statusMessage = "Parsing contact info...");
      }

      // Task 3: Parse Text with LLM
      final parsedData = await CactusService.instance.parseCardText(rawText);

      // Task 4: Convert GPS to City Name (Using your Offline Geocoder)
      String? addressLabel;
      if (position != null) {
        addressLabel = await LocationService.instance.getAddressLabel(
          position.latitude, 
          position.longitude
        );
      }

      if (!mounted) return;

      // Pass everything to the result screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ScanResultScreen(
            initialData: parsedData,
            rawText: rawText,
            // Pass the auto-captured location data
            initialLatitude: position?.latitude,
            initialLongitude: position?.longitude,
            initialAddress: addressLabel,
          ),
        ),
      );
    } catch (e) {
      _showError("Processing Error: $e");
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_isProcessing) ...[
              const CircularProgressIndicator(color: Color(0xFF00C853)),
              const SizedBox(height: 20),
              Text(
                _statusMessage,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 8),
              const Text(
                "Running on-device AI + GPS...",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ] else
              const Text("Opening Camera...", style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }
}