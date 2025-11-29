import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/contact.dart';
import '../../../data/repositories/contact_repository.dart';

class ScanResultScreen extends StatefulWidget {
  final Map<String, String?> initialData;
  final String rawText;
  
  // New Fields for Location
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
  late TextEditingController _locationController; // New Controller

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialData['name'] ?? '');
    _companyController = TextEditingController(text: widget.initialData['company'] ?? '');
    _titleController = TextEditingController(text: widget.initialData['title'] ?? '');
    _emailController = TextEditingController(text: widget.initialData['email'] ?? '');
    _notesController = TextEditingController(text: widget.initialData['notes'] ?? '');
    
    // Pre-fill location
    _locationController = TextEditingController(text: widget.initialAddress ?? '');
  }

  Future<void> _saveContact() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final contact = Contact(
        name: _nameController.text,
        company: _companyController.text,
        title: _titleController.text,
        email: _emailController.text,
        notes: _notesController.text,
        metAt: DateTime.now(),
        rawScannedText: widget.rawText,
        
        // Use the passed-in coordinates directly
        latitude: widget.initialLatitude,
        longitude: widget.initialLongitude,
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
              "AI extracted details. Location captured automatically.",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            
            _buildField("Name", _nameController, isRequired: true),
            _buildField("Company", _companyController),
            _buildField("Job Title", _titleController),
            _buildField("Email", _emailController, keyboardType: TextInputType.emailAddress),
            
            // Location Field (Editable)
            _buildField("Met At", _locationController, 
              suffixIcon: const Icon(Icons.location_on, color: Colors.green)),
              
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
    {bool isRequired = false, int maxLines = 1, TextInputType? keyboardType, Widget? suffixIcon}
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
          suffixIcon: suffixIcon,
        ),
        validator: isRequired 
          ? (v) => v == null || v.isEmpty ? "$label is required" : null 
          : null,
      ),
    );
  }
}