import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../../services/ai/cactus_service.dart';
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
    // Auto-open camera when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _takePicture();
    });
  }

  Future<void> _takePicture() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85, // Compress slightly for speed
      );

      if (photo != null) {
        await _processImage(photo.path);
      } else {
        // User canceled, go back
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      _showError("Camera Error: $e");
    }
  }

  Future<void> _processImage(String path) async {
    setState(() {
      _isProcessing = true;
      _statusMessage = "Reading text...";
    });

    try {
      // 1. Run Vision AI (OCR)
      final rawText = await CactusService.instance.scanBusinessCard(path);
      
      if (mounted) {
        setState(() => _statusMessage = "Parsing contact info...");
      }

      // 2. Run LLM (Parsing)
      final parsedData = await CactusService.instance.parseCardText(rawText);

      if (!mounted) return;

      // 3. Navigate to Result Screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ScanResultScreen(
            initialData: parsedData,
            rawText: rawText,
          ),
        ),
      );
    } catch (e) {
      _showError("AI Processing Error: $e");
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
                "Running on-device AI...",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ] else
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text("Open Camera"),
                onPressed: _takePicture,
              ),
          ],
        ),
      ),
    );
  }
}