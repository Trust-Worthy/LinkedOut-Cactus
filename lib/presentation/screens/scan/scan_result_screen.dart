import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/contact.dart';
import '../../../data/repositories/contact_repository.dart';
import '../../../services/ai/cactus_service.dart';
import '../../../services/location/location_service.dart'; // Add this import

class ScanResultScreen extends StatefulWidget {
  final Map<String, String?> initialData;
  final String rawText;

  const ScanResultScreen({
    super.key,
    required this.initialData,
    required this.rawText,
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

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData['name'] ?? '');
    _companyController = TextEditingController(text: widget.initialData['company'] ?? '');
    _titleController = TextEditingController(text: widget.initialData['title'] ?? '');
    _emailController = TextEditingController(text: widget.initialData['email'] ?? '');
    // Pre-fill notes with any raw text that might be useful, or leave empty
    _notesController = TextEditingController(text: widget.initialData['notes'] ?? '');
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // 1. Capture Location
      double? lat;
      double? lng;
      String? address = "Scanned Location";

      try {
        final position = await LocationService.instance.getCurrentLocation();
        if (position != null) {
          lat = position.latitude;
          lng = position.longitude;
          
          // Get readable name
          final label = await LocationService.instance.getAddressLabel(lat, lng);
          if (label != null) address = label;
        }
      } catch (e) {
        print("Location error: $e"); // Fail silently, save contact anyway
      }

      final contact = Contact(
        name: _nameController.text,
        company: _companyController.text,
        title: _titleController.text,
        email: _emailController.text,
        notes: _notesController.text,
        metAt: DateTime.now(),
        rawScannedText: widget.rawText,
        
        // 2. Save Location Data
        latitude: lat,
        longitude: lng,
        addressLabel: address, 
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

  // Future<void> _saveContact() async {
  //   if (!_formKey.currentState!.validate()) return;

  //   setState(() => _isSaving = true);

  //   try {
  //     final contact = Contact(
  //       name: _nameController.text,
  //       company: _companyController.text,
  //       title: _titleController.text,
  //       email: _emailController.text,
  //       notes: _notesController.text,
  //       metAt: DateTime.now(),
  //       rawScannedText: widget.rawText,
  //       // TODO: Get actual location here in next step
  //       addressLabel: "Scanned Location", 
  //     );

  //     // This will automatically generate the embedding via our Repo logic!
  //     await Provider.of<ContactRepository>(context, listen: false).saveContact(contact);

  //     if (mounted) {
  //       // Go back to Home (pop twice: ScanScreen and ResultScreen)
  //       Navigator.pop(context); 
  //     }
  //   } catch (e) {
  //     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
  //   } finally {
  //     if (mounted) setState(() => _isSaving = false);
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Contact")),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              "AI extracted the following details. Please verify.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            
            _buildField("Name", _nameController, isRequired: true),
            _buildField("Company", _companyController),
            _buildField("Job Title", _titleController),
            _buildField("Email", _emailController, keyboardType: TextInputType.emailAddress),
            _buildField("Notes", _notesController, maxLines: 3),

            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveContact,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isSaving 
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text("Save to Network"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label, 
    TextEditingController controller, 
    {bool isRequired = false, int maxLines = 1, TextInputType? keyboardType}
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: isRequired 
          ? (v) => v == null || v.isEmpty ? "$label is required" : null 
          : null,
      ),
    );
  }
}