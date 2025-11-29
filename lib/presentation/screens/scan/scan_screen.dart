import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:provider/provider.dart';
import '../../../services/ai/cactus_service.dart';
import '../../../services/location/location_service.dart';
import 'scan_result_screen.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  CameraController? cameraController;
  List<CameraDescription>? cameras;
  bool isScanning = false;
  bool flashOn = false;
  bool showTipsSheet = true;
  
  late AnimationController _animationController;
  final TextRecognizer textRecognizer = TextRecognizer(); // Google ML Kit

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
      cameras = await availableCameras();
      if (cameras != null && cameras!.isNotEmpty) {
        cameraController = CameraController(
          cameras![0],
          ResolutionPreset.high,
          enableAudio: false,
        );
        await cameraController!.initialize();
        if (mounted) {
          setState(() {});
          // Show tips after a short delay
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
    super.dispose();
  }

  Future<void> _captureAndProcessText() async {
    if (cameraController == null || !cameraController!.value.isInitialized || isScanning) {
      return;
    }

    setState(() => isScanning = true);

    try {
      // 1. Capture Image
      final XFile image = await cameraController!.takePicture();
      final InputImage inputImage = InputImage.fromFilePath(image.path);
      
      // 2. Google ML Kit Extraction (Fast & Accurate)
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      if (recognizedText.text.isNotEmpty) {
        // Show friend's UI for raw text review
        if (mounted) _showTextBottomSheet(recognizedText.text);
      } else {
        _showErrorSnackBar('No text detected. Please try again.');
      }
    } catch (e) {
      _showErrorSnackBar('Error processing image: $e');
    } finally {
      if (mounted) setState(() => isScanning = false);
    }
  }

  // --- UI: RAW TEXT REVIEW ---
  void _showTextBottomSheet(String rawText) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(Icons.text_fields, color: Colors.blue[700], size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Extracted Text', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                        Text('Review before AI processing', style: TextStyle(fontSize: 14, color: Colors.grey)),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            const Divider(height: 1),
            
            // Extracted text content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: SelectableText(
                    rawText,
                    style: const TextStyle(fontSize: 16, height: 1.6, color: Colors.black87),
                  ),
                ),
              ),
            ),
            
            // Action buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // AI Organization button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => _handleAIOrganization(rawText), // Trigger our Logic
                      icon: const Icon(Icons.auto_awesome, size: 22),
                      label: const Text(
                        'Organize with AI',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F6DB4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 2,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- LOGIC: BRIDGE TO YOUR ARCHITECTURE ---
  Future<void> _handleAIOrganization(String rawText) async {
    // 1. Close the BottomSheet
    Navigator.pop(context);

    // 2. Show Loading
    _showLoadingDialog();

    try {
      // 3. Parallel Execution: AI Parsing + GPS Location
      // We use your existing Services here.
      final aiFuture = CactusService.instance.parseCardText(rawText);
      final locFuture = LocationService.instance.getCurrentLocation();

      final results = await Future.wait([aiFuture, locFuture]);
      
      final parsedData = results[0] as Map<String, String?>;
      final position = results[1] as dynamic; // Cast later

      // 4. Resolve Address (Offline)
      String? address;
      double? lat, lng;
      
      if (position != null) {
        lat = position.latitude;
        lng = position.longitude;
        address = await LocationService.instance.getAddressLabel(lat!, lng!);
      }

      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      // 5. Navigate to your Save Form (ScanResultScreen)
      // We pass the data we just gathered.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ScanResultScreen(
            initialData: parsedData,
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
        _showErrorSnackBar("AI Error: $e");
      }
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF1F6DB4)),
                SizedBox(height: 16),
                Text("AI is structuring data..."),
                Text("Acquiring GPS...", style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- UI HELPERS (Friend's Code) ---

  void _showTipsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lightbulb_outline, size: 60, color: Color(0xFF1F6DB4)),
            const SizedBox(height: 16),
            const Text('Scan Tips', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
        Icon(icon, color: const Color(0xFF1F6DB4)),
        const SizedBox(width: 16),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text(desc, style: const TextStyle(color: Colors.grey)),
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

  void _toggleFlash() {
    if (cameraController != null) {
      flashOn = !flashOn;
      cameraController!.setFlashMode(flashOn ? FlashMode.torch : FlashMode.off);
      setState(() {});
    }
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
          
          // Overlay
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

          // Bottom Bar
          Positioned(
            bottom: 40, left: 24, right: 24,
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