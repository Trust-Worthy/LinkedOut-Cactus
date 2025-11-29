import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:cactus/cactus.dart';

// Contact information model
class ContactInfo {
  final String? name;
  final String? occupation;
  final String? location;
  final String? phone;
  final String? email;
  final List<String> socials;

  ContactInfo({
    this.name,
    this.occupation,
    this.location,
    this.phone,
    this.email,
    this.socials = const [],
  });

  bool get hasAnyInfo => 
    name != null || occupation != null || location != null || 
    phone != null || email != null || socials.isNotEmpty;
}

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> with SingleTickerProviderStateMixin {
  CameraController? cameraController;
  List<CameraDescription>? cameras;
  bool isScanning = false;
  bool flashOn = false;
  bool showTipsSheet = true;
  late AnimationController _animationController;
  final TextRecognizer textRecognizer = TextRecognizer();
  final CactusLM _cactusLM = CactusLM();
  bool _isModelInitialized = false;
  bool _isDownloadingModel = false;
  double _downloadProgress = 0.0;
  String _downloadStatus = '';

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _initializeCamera();
    _initializeAI();
  }

  Future<void> _initializeCamera() async {
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
  }

  Future<void> _initializeAI() async {
    try {
      // Download and initialize Qwen3 600M for better performance
      if (!_cactusLM.isLoaded()) {
        setState(() {
          _isDownloadingModel = true;
          _downloadStatus = 'Preparing AI model...';
        });
        
        await _cactusLM.downloadModel(
          model: "qwen3-0.6",
          downloadProcessCallback: (progress, status, isError) {
            if (mounted) {
              setState(() {
                if (isError) {
                  _downloadStatus = 'Error: $status';
                  debugPrint("Model download error: $status");
                } else {
                  _downloadProgress = progress ?? 0.0;
                  _downloadStatus = status;
                  debugPrint("$status ${progress != null ? '(${(progress * 100).toStringAsFixed(0)}%)' : ''}");
                }
              });
            }
          },
        );
        
        if (mounted) {
          setState(() {
            _downloadStatus = 'Initializing AI model...';
          });
        }
        
        await _cactusLM.initializeModel(
          params: CactusInitParams(model: "qwen3-0.6")
        );
        
        if (mounted) {
          setState(() {
            _isModelInitialized = true;
            _isDownloadingModel = false;
          });
        }
        debugPrint("AI model initialized successfully");
      }
    } catch (e) {
      debugPrint("Error initializing AI: $e");
      if (mounted) {
        setState(() {
          _isDownloadingModel = false;
          _downloadStatus = 'Failed to initialize AI';
        });
      }
    }
  }

  @override
  void dispose() {
    cameraController?.dispose();
    textRecognizer.close();
    _animationController.dispose();
    _cactusLM.unload();
    super.dispose();
  }

  Future<ContactInfo?> _processTextWithAI(String rawText) async {
    if (!_isModelInitialized) {
      debugPrint("AI model not initialized yet");
      return null;
    }

    try {
      debugPrint("Starting AI processing...");
      debugPrint("Raw text length: ${rawText.length}");
      debugPrint("Raw text: $rawText");
      
      final prompt = """Extract contact information from this text and return ONLY valid JSON with these fields: name, job, location, phone, email.

Text: $rawText

Return only the JSON object, no explanation:""";;

      debugPrint("Calling AI model...");
      final result = await _cactusLM.generateCompletion(
        messages: [
          ChatMessage(content: prompt, role: "user"),
        ],
        params: CactusCompletionParams(
          maxTokens: 150,
          temperature: 0.2,
        ),
      ).timeout(
        const Duration(seconds: 60),
        onTimeout: () {
          debugPrint("AI processing timeout after 60 seconds!");
          return CactusCompletionResult(
            success: false,
            response: '',
            timeToFirstTokenMs: 0,
            totalTimeMs: 0,
            tokensPerSecond: 0,
            prefillTokens: 0,
            decodeTokens: 0,
            totalTokens: 0,
          );
        },
      );
      
      debugPrint("AI result success: ${result.success}");
      debugPrint("AI response length: ${result.response.length}");
      debugPrint("AI response: ${result.response}");

      if (result.success && result.response.isNotEmpty) {
        debugPrint("Parsing JSON response...");
        try {
          // Clean up response
          String jsonStr = result.response.trim();
          
          // Remove markdown code blocks
          jsonStr = jsonStr.replaceAll(RegExp(r'```json\s*'), '');
          jsonStr = jsonStr.replaceAll(RegExp(r'```\s*'), '');
          
          // Remove thinking tags and end tokens
          jsonStr = jsonStr.replaceAll(RegExp(r'<think>.*?</think>', dotAll: true), '');
          jsonStr = jsonStr.replaceAll(RegExp(r'<end_of_turn>.*', multiLine: true), '');
          jsonStr = jsonStr.trim();
          
          // Extract JSON object
          final jsonMatch = RegExp(r'\{[^}]+\}').firstMatch(jsonStr);
          if (jsonMatch != null) {
            jsonStr = jsonMatch.group(0)!;
            debugPrint("Found JSON: $jsonStr");
            
            // Parse fields
            final nameMatch = RegExp(r'"name"\s*:\s*"([^"]*)"').firstMatch(jsonStr);
            final jobMatch = RegExp(r'"job"\s*:\s*"([^"]*)"').firstMatch(jsonStr);
            final locationMatch = RegExp(r'"location"\s*:\s*"([^"]*)"').firstMatch(jsonStr);
            final phoneMatch = RegExp(r'"phone"\s*:\s*"([^"]*)"').firstMatch(jsonStr);
            final emailMatch = RegExp(r'"email"\s*:\s*"([^"]*)"').firstMatch(jsonStr);
            
            return ContactInfo(
              name: nameMatch?.group(1),
              occupation: jobMatch?.group(1),
              location: locationMatch?.group(1),
              phone: phoneMatch?.group(1),
              email: emailMatch?.group(1),
              socials: [],
            );
          } else {
            debugPrint("No JSON object found in response");
          }
        } catch (e) {
          debugPrint("Error parsing JSON: $e");
        }
      } else {
        debugPrint("AI processing failed or empty response");
      }
    } catch (e, stackTrace) {
      debugPrint("Error processing with AI: $e");
      debugPrint("Stack trace: $stackTrace");
    }
    debugPrint("AI processing completed, returning null");
    return null;
  }

  Future<void> _captureAndProcessText() async {
    if (cameraController == null || !cameraController!.value.isInitialized || isScanning) {
      return;
    }

    setState(() {
      isScanning = true;
    });

    try {
      final XFile image = await cameraController!.takePicture();
      final InputImage inputImage = InputImage.fromFilePath(image.path);
      
      final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      
      if (recognizedText.text.isNotEmpty) {
        // Show raw text with AI button
        _showTextBottomSheet(recognizedText.text);
      } else {
        _showErrorSnackBar('No text detected. Please try again.');
      }
    } catch (e) {
      _showErrorSnackBar('Error processing image: $e');
    } finally {
      setState(() {
        isScanning = false;
      });
    }
  }

  void _showLoadingBottomSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: 200,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1F6DB4)),
              ),
              SizedBox(height: 20),
              Text(
                'Processing with AI...',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContactInfoBottomSheet(ContactInfo contactInfo, String rawText) {
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
                      color: const Color(0xFF1F6DB4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.person, color: Color(0xFF1F6DB4), size: 28),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact Information',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Extracted and organized by AI',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
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
            
            // Contact information content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (contactInfo.name != null) ...[
                      _buildContactField(
                        icon: Icons.person_outline,
                        label: 'Name',
                        value: contactInfo.name!,
                        color: const Color(0xFF1F6DB4),
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (contactInfo.occupation != null) ...[
                      _buildContactField(
                        icon: Icons.work_outline,
                        label: 'Occupation',
                        value: contactInfo.occupation!,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (contactInfo.location != null) ...[
                      _buildContactField(
                        icon: Icons.location_on,
                        label: 'Location',
                        value: contactInfo.location!,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (contactInfo.phone != null) ...[
                      _buildContactField(
                        icon: Icons.phone_outlined,
                        label: 'Phone',
                        value: contactInfo.phone!,
                        color: Colors.green,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (contactInfo.email != null) ...[
                      _buildContactField(
                        icon: Icons.email_outlined,
                        label: 'Email',
                        value: contactInfo.email!,
                        color: Colors.purple,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    if (contactInfo.socials.isNotEmpty) ...[
                      _buildContactField(
                        icon: Icons.share_outlined,
                        label: 'Social Media',
                        value: contactInfo.socials.join('\\n'),
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 16),
                    ],
                    
                    // Raw text section (expandable)
                    const SizedBox(height: 8),
                    ExpansionTile(
                      title: const Text(
                        'View Raw Text',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.grey[50],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: SelectableText(
                            rawText,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[700],
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
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
                    offset: const Offset(0, -2),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.close),
                      label: const Text('Close'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(color: Color(0xFF1F6DB4)),
                        foregroundColor: const Color(0xFF1F6DB4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Save contact functionality
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Save functionality coming soon!')),
                        );
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Save'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F6DB4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
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

  Widget _buildContactField({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: color,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                SelectableText(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTextBottomSheet(String text) {
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
                        Text(
                          'Extracted Text',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Text recognized from business card',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
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
                    text,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
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
                  // AI Organization button (prominent)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (!_isModelInitialized) {
                          _showErrorSnackBar('AI model is still initializing. Please wait.');
                          return;
                        }
                        
                        // Store context before async operations
                        final navigator = Navigator.of(context);
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        
                        // Close current sheet
                        navigator.pop();
                        
                        // Show loading
                        _showLoadingBottomSheet();
                        
                        try {
                          // Process with AI with timeout
                          final contactInfo = await _processTextWithAI(text).timeout(
                            const Duration(seconds: 45),
                            onTimeout: () {
                              debugPrint('Main timeout reached');
                              return null;
                            },
                          );
                          
                          // Close loading (check if widget is still mounted)
                          if (!mounted) return;
                          
                          try {
                            navigator.pop();
                          } catch (e) {
                            debugPrint('Could not pop loading sheet: $e');
                          }
                          
                          // Show organized results
                          if (contactInfo != null && contactInfo.hasAnyInfo) {
                            if (mounted) {
                              _showContactInfoBottomSheet(contactInfo, text);
                            }
                          } else {
                            if (mounted) {
                              scaffoldMessenger.showSnackBar(
                                const SnackBar(
                                  content: Text('AI could not extract contact info from the text.'),
                                  backgroundColor: Colors.orange,
                                  duration: Duration(seconds: 3),
                                ),
                              );
                            }
                          }
                        } catch (e, stackTrace) {
                          debugPrint('Error in AI button handler: $e');
                          debugPrint('Stack trace: $stackTrace');
                          if (mounted) {
                            // Try to close loading sheet
                            try {
                              navigator.pop();
                            } catch (_) {
                              debugPrint('Could not pop after error');
                            }
                            final errorMsg = e.toString();
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text('Processing failed: ${errorMsg.length > 50 ? errorMsg.substring(0, 50) : errorMsg}'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                      icon: const Icon(Icons.auto_awesome, size: 22),
                      label: const Text(
                        'Organize with AI',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F6DB4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Secondary buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.close, size: 18),
                          label: const Text('Close'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            // Copy to clipboard or save raw text
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Text saved!')),
                            );
                          },
                          icon: const Icon(Icons.save_outlined, size: 18),
                          label: const Text('Save Raw'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTipsBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isDismissible: true,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25),
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(
              left: 24,
              right: 24,
              top: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            
            // Icon
            const Icon(
              Icons.lightbulb_outline,
              size: 80,
              color: Color(0xFF1F6DB4),
            ),
            
            const SizedBox(height: 20),
            
            // Title
            const Text(
              'How to Scan',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              'Follow these simple steps for best results',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Tips
            _buildTipItem(
              Icons.credit_card,
              'Position the Card',
              'Place your business card within the frame',
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              Icons.light_mode,
              'Good Lighting',
              'Ensure adequate lighting for clear text recognition',
            ),
            const SizedBox(height: 16),
            _buildTipItem(
              Icons.center_focus_strong,
              'Stay Steady',
              'Hold your device steady while capturing',
            ),
            
            const SizedBox(height: 24),
            
            // Got it button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    showTipsSheet = false;
                  });
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1F6DB4),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Got it!',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTipItem(IconData icon, String title, String description) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1F6DB4).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1F6DB4),
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
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
        backgroundColor: Colors.white,
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF1F6DB4)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // Camera Preview
          Positioned.fill(
            child: CameraPreview(cameraController!),
          ),
          
          // AI Download Progress Bar (at top)
          if (_isDownloadingModel)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                color: const Color(0xFF1F6DB4),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top,
                  bottom: 8,
                  left: 16,
                  right: 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.download,
                          color: Colors.white,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _downloadStatus,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: _downloadProgress,
                        backgroundColor: Colors.white.withOpacity(0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        minHeight: 4,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Scan area overlay
          CustomPaint(
            painter: ScannerOverlay(
              scanWindow: Rect.fromCenter(
                center: Offset(
                  MediaQuery.of(context).size.width / 2,
                  MediaQuery.of(context).size.height / 2,
                ),
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.width * 0.55,
              ),
            ),
            child: const SizedBox.expand(),
          ),

          // Top Bar with gradient
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                bottom: 24,
                left: 16,
                right: 16,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Back Button
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),

                  // Title
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Scan Business Card',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Flash Toggle
                  IconButton(
                    onPressed: _toggleFlash,
                    icon: Icon(
                      flashOn ? Icons.flash_on : Icons.flash_off,
                      color: Colors.white,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black.withOpacity(0.5),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ],
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
                          colors: [
                            Colors.transparent,
                            Colors.white,
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.white.withOpacity(0.8),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

          // Bottom instruction area
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.transparent,
                  ],
                ),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).padding.bottom + 24,
                top: 40,
                left: 24,
                right: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Instructions
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.credit_card,
                          color: Colors.white,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Align business card within the frame',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Action Buttons
                  Row(
                    children: [
                      // Cancel Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white.withOpacity(0.9),
                            foregroundColor: Colors.black87,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: Colors.grey[300]!,
                                width: 1,
                              ),
                            ),
                            elevation: 0,
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.close, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(width: 16),

                      // Scan Button
                      Expanded(
                        child: ElevatedButton(
                          onPressed: isScanning ? null : _captureAndProcessText,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1F6DB4),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 8,
                            shadowColor: const Color(0xFF1F6DB4).withOpacity(0.4),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (isScanning)
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              else
                                const Icon(Icons.document_scanner, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                isScanning ? 'Processing...' : 'Scan Card',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for scanner overlay
class ScannerOverlay extends CustomPainter {
  final Rect scanWindow;

  ScannerOverlay({required this.scanWindow});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw dark overlay
    final backgroundPath = Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height));
    final cutoutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(scanWindow, const Radius.circular(20)));

    final backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.4)
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path.combine(PathOperation.difference, backgroundPath, cutoutPath),
      backgroundPaint,
    );

    // Draw corner borders
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const cornerLength = 40.0;

    // Top-left corner
    canvas.drawLine(
      Offset(scanWindow.left, scanWindow.top + cornerLength),
      Offset(scanWindow.left, scanWindow.top),
      borderPaint,
    );
    canvas.drawLine(
      Offset(scanWindow.left, scanWindow.top),
      Offset(scanWindow.left + cornerLength, scanWindow.top),
      borderPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(scanWindow.right - cornerLength, scanWindow.top),
      Offset(scanWindow.right, scanWindow.top),
      borderPaint,
    );
    canvas.drawLine(
      Offset(scanWindow.right, scanWindow.top),
      Offset(scanWindow.right, scanWindow.top + cornerLength),
      borderPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(scanWindow.left, scanWindow.bottom - cornerLength),
      Offset(scanWindow.left, scanWindow.bottom),
      borderPaint,
    );
    canvas.drawLine(
      Offset(scanWindow.left, scanWindow.bottom),
      Offset(scanWindow.left + cornerLength, scanWindow.bottom),
      borderPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(scanWindow.right - cornerLength, scanWindow.bottom),
      Offset(scanWindow.right, scanWindow.bottom),
      borderPaint,
    );
    canvas.drawLine(
      Offset(scanWindow.right, scanWindow.bottom - cornerLength),
      Offset(scanWindow.right, scanWindow.bottom),
      borderPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
