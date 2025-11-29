import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import '../../../services/ai/cactus_service.dart';
import '../../../services/location/location_service.dart';
import '../../../core/utils/business_card_extractor.dart';
import 'scan_result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  CameraController? cameraController;
  bool isScanning = false;
  bool flashOn = false;
  bool showTipsSheet = true; // Flag to control tips display
  late AnimationController _animationController;
  final TextRecognizer textRecognizer = TextRecognizer(); 

  // Live status notifier for the loading dialog
  final ValueNotifier<String> _loadingStatus = ValueNotifier("Initializing...");

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        cameraController = CameraController(
          cameras[0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await cameraController!.initialize();
        if (mounted) {
          setState(() {});
          // Show tips after a short delay so the camera view is visible first
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted && showTipsSheet) {
              _showTipsBottomSheet();
            }
          });
        }
      }
    } catch (e) {
      debugPrint("Camera init error: $e");
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    textRecognizer.close();
    _animationController.dispose();
    _loadingStatus.dispose();
    super.dispose();
  }

  void _toggleFlash() {
    if (cameraController != null) {
      flashOn = !flashOn;
      cameraController!.setFlashMode(flashOn ? FlashMode.torch : FlashMode.off);
      setState(() {});
    }
  }

  Future<void> _captureAndProcessText() async {
    if (cameraController == null || !cameraController!.value.isInitialized || isScanning) return;

    setState(() => isScanning = true);

    try {
      final XFile image = await cameraController!.takePicture();
      final InputImage inputImage = InputImage.fromFilePath(image.path);
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      if (recognizedText.text.isNotEmpty) {
        if (mounted) _handleAIOrganization(recognizedText.text);
      } else {
        _showErrorSnackBar('No text detected.');
      }
    } catch (e) {
      _showErrorSnackBar('Error: $e');
    } finally {
      if (mounted) setState(() => isScanning = false);
    }
  }

  // --- LOGIC: Regex + AI + GPS (With Status Updates) ---
  Future<void> _handleAIOrganization(String rawText) async {
    _showLoadingDialog();

    try {
      // 1. Regex (Instant)
      _loadingStatus.value = "Pattern Matching...";
      final regexData = BusinessCardExtractor.extract(rawText);

      // 2. GPS (With Timeout)
      _loadingStatus.value = "Acquiring GPS...";
      dynamic position;
      try {
        // Give GPS 2.5 seconds max, otherwise proceed without it
        position = await LocationService.instance.getCurrentLocation()
            .timeout(const Duration(milliseconds: 2500), onTimeout: () => null);
      } catch (e) {
        debugPrint("GPS Timeout/Error: $e");
      }

      // 3. AI Parsing (Heavy Lift)
      _loadingStatus.value = "Waking up AI Brain...";
      final aiData = await CactusService.instance.parseCardText(rawText);

      _loadingStatus.value = "Merging Data...";

      // 4. Merge Data
      final mergedData = {
        'name': aiData['name'] ?? regexData.name,
        'company': aiData['company'] ?? regexData.company,
        'title': aiData['title'] ?? regexData.title,
        'email': regexData.email ?? aiData['email'],
        'phone': regexData.phone ?? aiData['phone'],
        'linkedin': regexData.linkedin ?? aiData['linkedin'],
        'notes': (aiData['notes'] ?? "") + "\n\nRaw Scan:\n" + rawText, 
      };

      // 5. Resolve Address (Offline)
      String? address = regexData.address;
      double? lat, lng;
      
      if (position != null) {
        lat = position.latitude;
        lng = position.longitude;
        // Lookup offline city name
        final gpsAddress = await LocationService.instance.getAddressLabel(lat!, lng!);
        if (gpsAddress != null) {
          address = gpsAddress;
        }
      }

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // 6. Navigate to Save Form
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ScanResultScreen(
            initialData: mergedData,
            rawText: rawText,
            initialLatitude: lat,
            initialLongitude: lng,
            initialAddress: address,
          ),
        ),
      );

    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Close loading
        _showErrorSnackBar("Processing Failed: $e");
      }
    }
  }

  // --- UPDATED LOADING DIALOG (Live Status) ---
  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 40),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(color: Color(0xFF1F6DB4)),
                const SizedBox(height: 20),
                const Text(
                  "Processing",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 8),
                // Live status update widget
                ValueListenableBuilder<String>(
                  valueListenable: _loadingStatus,
                  builder: (context, value, child) {
                    return Text(
                      value,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                      textAlign: TextAlign.center,
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI HELPERS ---

  void _showTipsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lightbulb_outline, size: 60, color: Colors.white),
            const SizedBox(height: 16),
            const Text('Scan Tips', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            _buildTipItem(Icons.crop_free, 'Frame it', 'Keep text inside the box'),
            const SizedBox(height: 12),
            _buildTipItem(Icons.wb_sunny, 'Lighting', 'Avoid shadows and glare'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() => showTipsSheet = false);
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F6DB4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Got it!'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String title, String desc) {
    return Row(
      children: [
        Icon(icon, color: Colors.white),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
            Text(desc, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          ],
        )
      ],
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (cameraController == null || !cameraController!.value.isInitialized) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Color(0xFF1F6DB4))),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera Preview
          Positioned.fill(child: CameraPreview(cameraController!)),
          
          // Custom Overlay (Friend's Style)
          CustomPaint(
            painter: ScannerOverlay(
              scanWindow: Rect.fromCenter(
                center: Offset(MediaQuery.of(context).size.width / 2, MediaQuery.of(context).size.height / 2),
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.width * 0.55,
              ),
            ),
            child: const SizedBox.expand(),
          ),

          // Top Bar
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    IconButton(
                      icon: Icon(flashOn ? Icons.flash_on : Icons.flash_off, color: Colors.white),
                      onPressed: _toggleFlash,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Scanning animation line
          if (!isScanning)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.28,
              left: MediaQuery.of(context).size.width * 0.075,
              right: MediaQuery.of(context).size.width * 0.075,
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      0,
                      _animationController.value * MediaQuery.of(context).size.width * 0.55,
                    ),
                    child: Container(
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.transparent, Colors.white, Colors.transparent],
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.white.withOpacity(0.8), blurRadius: 10, spreadRadius: 2),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          // Bottom Bar
          Positioned(
            bottom: 40, left: 24, right: 24,
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isScanning ? null : _captureAndProcessText,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1F6DB4),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: isScanning 
                      ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.white))
                      : const Text("Capture Card", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Overlay Painter (Friend's visual style)
class ScannerOverlay extends CustomPainter {
  final Rect scanWindow;
  ScannerOverlay({required this.scanWindow});

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()..addRRect(RRect.fromRectAndRadius(scanWindow, const Radius.circular(20)));

    final backgroundPaint = Paint()..color = Colors.black.withOpacity(0.5)..style = PaintingStyle.fill;

    canvas.drawPath(
      Path.combine(PathOperation.difference, backgroundPath, cutoutPath),
      backgroundPaint,
    );

    final borderPaint = Paint()..color = Colors.white..strokeWidth = 4..style = PaintingStyle.stroke;
    canvas.drawRRect(RRect.fromRectAndRadius(scanWindow, const Radius.circular(20)), borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}