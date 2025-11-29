import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../../data/models/contact.dart';
import '../../../data/repositories/contact_repository.dart';
import '../../../services/location/location_service.dart';
import '../../../services/location/offline_geocoding_service.dart'; // Import Geocoding Service

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
    
    _currentLat = widget.initialLatitude;
    _currentLng = widget.initialLongitude;
    _locationController = TextEditingController(text: widget.initialAddress ?? '');
    
    _eventController = TextEditingController(text: "");
    _linkedinController = TextEditingController(text: "");
    _instagramController = TextEditingController(text: "");

    if (_currentLat == null || _currentLng == null) {
      _fetchLocation();
    }
  }

  Future<void> _fetchLocation() async {
    setState(() => _isFetchingLocation = true);
    try {
      final position = await LocationService.instance.getCurrentLocation();
      if (position != null) {
        _currentLat = position.latitude;
        _currentLng = position.longitude;

        if (_locationController.text.isEmpty) {
          final address = await LocationService.instance.getAddressLabel(
            position.latitude, 
            position.longitude
          );
          if (address != null) {
            _locationController.text = address;
          }
        }
      }
    } catch (e) {
      debugPrint("Could not fetch manual location: $e");
    } finally {
      if (mounted) setState(() => _isFetchingLocation = false);
    }
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // --- NEW: Forward Geocoding Logic ---
      // If user typed a location manually, we try to verify it against the DB
      if (_locationController.text.isNotEmpty) {
        bool isLocationDirty = _locationController.text != widget.initialAddress;
        
        // Only lookup if text changed OR we never had coords
        if (isLocationDirty || _currentLat == null) {
           final coords = await OfflineGeocodingService.instance.getCoordinates(_locationController.text);
           
           if (coords != null) {
             _currentLat = coords['lat'];
             _currentLng = coords['lng'];
             // Optional: Standardize format (e.g. "Denver" -> "Denver, US")
             // _locationController.text = await OfflineGeocodingService.instance.getCityName(_currentLat!, _currentLng!) ?? _locationController.text;
           } else {
             // ERROR: City not found
             if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(
                   content: Text("⚠️ Offline Location Error: '${_locationController.text}' not found in database. Try a major city name (e.g. 'Denver')."),
                   backgroundColor: Colors.red,
                   duration: const Duration(seconds: 4),
                 ),
               );
               setState(() => _isSaving = false);
               return; // STOP SAVE
             }
           }
        }
      }

      DateTime? followUpDate;
      if (_followUpWeeks > 0) {
        followUpDate = DateTime.now().add(Duration(days: (_followUpWeeks * 7).toInt()));
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

      if (mounted) {
        Navigator.pop(context);
      }
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Edit Contact Card"),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveContact,
            child: const Text("SAVE", style: TextStyle(fontWeight: FontWeight.bold)),
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
                    "Met At (City Name)", 
                    _locationController, 
                    suffixIcon: _isFetchingLocation 
                      ? const SizedBox(
                          width: 12, height: 12, 
                          child: CircularProgressIndicator(strokeWidth: 2)
                        )
                      : IconButton(
                          icon: const Icon(Icons.my_location, color: Colors.blue),
                          onPressed: _fetchLocation,
                        ),
                  ),
                ),
              ],
            ),
            if (_currentLat != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16, left: 4),
                child: Text(
                  "GPS Locked: ${_currentLat!.toStringAsFixed(4)}, ${_currentLng!.toStringAsFixed(4)}", 
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade400),
                ),
              ),

            _buildField("Event / Conference", _eventController, hint: "e.g. Cactus Hackathon"),
            
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
            _buildSectionTitle("Follow Up"),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Remind me in:", style: TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        _getSliderLabel(_followUpWeeks),
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Slider(
                    value: _followUpWeeks,
                    min: 0,
                    max: 4,
                    divisions: 4,
                    activeColor: Colors.black,
                    onChanged: (val) {
                      double newVal = val;
                      if (val > 2.5) newVal = 4;
                      else if (val > 1.5) newVal = 2;
                      else if (val > 0.5) newVal = 1;
                      else newVal = 0;
                      
                      setState(() => _followUpWeeks = newVal);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
            _buildSectionTitle("Notes"),
            _buildField("Thoughts, conversation topics...", _notesController, maxLines: 4),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          color: Colors.grey.shade500,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildField(
    String label, 
    TextEditingController controller, 
    {bool isRequired = false, int maxLines = 1, TextInputType? keyboardType, Widget? suffixIcon, String? hint}
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          alignLabelWithHint: maxLines > 1,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          suffixIcon: suffixIcon,
        ),
        validator: isRequired 
          ? (v) => v == null || v.isEmpty ? "$label is required" : null 
          : null,
      ),
    );
  }
}