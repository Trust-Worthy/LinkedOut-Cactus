import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart'; 
import '../../../data/models/contact.dart';
import '../../../data/repositories/contact_repository.dart';
import '../../../services/location/location_service.dart';
import '../../../services/location/offline_geocoding_service.dart';

class ScanResultScreen extends StatefulWidget {
  final Map<String, String?> initialData;
  final String rawText;
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialAddress;

  const ScanResultScreen({
    super.key,
    required this.initialData,
    required this.rawText,
    this.initialLatitude,
    this.initialLongitude,
    this.initialAddress,
  });

  @override
  State<ScanResultScreen> createState() => _ScanResultScreenState();
}

class _ScanResultScreenState extends State<ScanResultScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _companyController;
  late TextEditingController _titleController;
  late TextEditingController _emailController;
  late TextEditingController _notesController;
  late TextEditingController _locationController;
  late TextEditingController _eventController;
  late TextEditingController _linkedinController;
  late TextEditingController _instagramController;
  
  // NEW: Outreach Controller
  late TextEditingController _outreachController;

  double? _currentLat;
  double? _currentLng;
  bool _isFetchingLocation = false;
  bool _isSaving = false;
  double _followUpWeeks = 0; 

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData['name'] ?? '');
    _companyController = TextEditingController(text: widget.initialData['company'] ?? '');
    _titleController = TextEditingController(text: widget.initialData['title'] ?? '');
    _emailController = TextEditingController(text: widget.initialData['email'] ?? '');
    _notesController = TextEditingController(text: widget.initialData['notes'] ?? '');
    _locationController = TextEditingController(text: widget.initialAddress ?? '');
    _eventController = TextEditingController(text: "");
    _linkedinController = TextEditingController(text: widget.initialData['linkedin'] ?? "");
    _instagramController = TextEditingController(text: "");
    _outreachController = TextEditingController();

    _currentLat = widget.initialLatitude;
    _currentLng = widget.initialLongitude;

    // Listeners to auto-update draft
    _nameController.addListener(_updateDraft);
    _eventController.addListener(_updateDraft);
    _locationController.addListener(_updateDraft);
    _notesController.addListener(_updateDraft);

    // Auto-Fetch GPS if missing
    if (_currentLat == null) {
      _fetchLocation();
    }
    
    // Initial draft generation
    _updateDraft();
  }

  void _updateDraft() {
    String name = _nameController.text.isEmpty ? "there" : _nameController.text.split(' ')[0];
    String event = _eventController.text;
    String city = _locationController.text.split(',')[0];
    
    String contextStr = "";
    if (event.isNotEmpty && city.isNotEmpty) {
      contextStr = "meeting at $event in $city";
    } else if (event.isNotEmpty) {
      contextStr = "meeting at $event";
    } else if (city.isNotEmpty) {
      contextStr = "meeting in $city";
    } else {
      contextStr = "connecting recently";
    }

    String msg = "Hi $name, it was great $contextStr! I'd love to follow up about ${_notesController.text.isEmpty ? 'our conversation' : 'what we discussed'}.";
    _outreachController.text = msg;
  }

  Future<void> _fetchLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      final position = await LocationService.instance.getCurrentLocation();
      if (position != null) {
        _currentLat = position.latitude;
        _currentLng = position.longitude;

        if (_locationController.text.isEmpty) {
          final address = await LocationService.instance.getAddressLabel(position.latitude, position.longitude);
          if (address != null) {
            _locationController.text = address;
          }
        }
      }
    } catch (e) {
      debugPrint("GPS error: $e");
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      DateTime? followUpDate;
      if (_followUpWeeks > 0) {
        followUpDate = DateTime.now().add(Duration(days: (_followUpWeeks * 7).toInt()));
      }

      // Forward Geocoding if user typed location manually
      if (_locationController.text.isNotEmpty && _currentLat == null) {
         final coords = await OfflineGeocodingService.instance.getCoordinates(_locationController.text);
         if (coords != null) {
           _currentLat = coords['lat'];
           _currentLng = coords['lng'];
         }
      }

      final contact = Contact(
        name: _nameController.text,
        company: _companyController.text,
        title: _titleController.text,
        email: _emailController.text,
        notes: _notesController.text,
        eventName: _eventController.text,
        linkedin: _linkedinController.text,
        instagram: _instagramController.text,
        followUpScheduledFor: followUpDate,
        metAt: DateTime.now(),
        rawScannedText: widget.rawText,
        latitude: _currentLat,
        longitude: _currentLng,
        addressLabel: _locationController.text, 
      );

      await Provider.of<ContactRepository>(context, listen: false).saveContact(contact);

      if (mounted) Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String _getSliderLabel(double value) {
    if (value == 0) return "No Reminder";
    if (value == 1) return "1 Week";
    if (value == 2) return "2 Weeks";
    if (value == 4) return "1 Month";
    return "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text("Verify Details", style: TextStyle(color: Colors.white)),
        elevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.pop(context)),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveContact,
            child: const Text("SAVE", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          )
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionTitle("Identity"),
            _buildField("Name", _nameController, isRequired: true),
            _buildField("Job Title", _titleController),
            _buildField("Company", _companyController),

            const SizedBox(height: 20),
            _buildSectionTitle("Context"),
            Row(
              children: [
                Expanded(
                  child: _buildField(
                    "Met At (City)",
                    _locationController,
                    suffixIcon: _isFetchingLocation
                      ? const SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : IconButton(icon: const Icon(Icons.my_location, color: Colors.blue), onPressed: _fetchLocation),
                  ),
                ),
              ],
            ),
            _buildField("Event Name", _eventController, hint: "e.g. Tech Conference"),

            const SizedBox(height: 20),
            _buildSectionTitle("Contact Info"),
            _buildField("Email", _emailController, keyboardType: TextInputType.emailAddress),
            Row(
              children: [
                Expanded(child: _buildField("LinkedIn", _linkedinController)),
                const SizedBox(width: 10),
                Expanded(child: _buildField("Instagram", _instagramController)),
              ],
            ),

            const SizedBox(height: 20),
            _buildSectionTitle("Notes"),
            _buildField("Thoughts / Topics", _notesController, maxLines: 3),

            const SizedBox(height: 20),
            _buildSectionTitle("Auto-Drafted Outreach"),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[800]!),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _outreachController,
                    maxLines: 4,
                    decoration: const InputDecoration(border: InputBorder.none),
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                  const Divider(color: Colors.grey),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () {
                        // TODO: Implement Copy to Clipboard
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Draft copied!")));
                      },
                      icon: const Icon(Icons.copy, size: 16, color: Colors.white),
                      label: const Text("Copy Draft", style: TextStyle(color: Colors.white)),
                    ),
                  )
                ],
              ),
            ),

            const SizedBox(height: 20),
            _buildSectionTitle("Follow Up Reminder"),
            Slider(
              value: _followUpWeeks,
              min: 0, max: 4, divisions: 4,
              activeColor: Colors.blue,
              label: _getSliderLabel(_followUpWeeks),
              onChanged: (val) {
                double newVal = val;
                if (val > 2.5) newVal = 4;
                else if (val > 1.5) newVal = 2;
                else if (val > 0.5) newVal = 1;
                else newVal = 0;
                setState(() => _followUpWeeks = newVal);
              },
            ),
            Center(child: Text(_getSliderLabel(_followUpWeeks), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white))),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold, letterSpacing: 1.0)),
    );
  }

  Widget _buildField(String label, TextEditingController controller, {bool isRequired = false, int maxLines = 1, TextInputType? keyboardType, Widget? suffixIcon, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.grey),
          alignLabelWithHint: maxLines > 1,
          filled: true,
          fillColor: Colors.grey[850],
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: suffixIcon,
        ),
        validator: isRequired ? (v) => v == null || v.isEmpty ? "$label is required" : null : null,
      ),
    );
  }
}