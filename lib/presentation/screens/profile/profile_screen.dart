import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/contact.dart';
import '../../../data/repositories/contact_repository.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _companyController;
  late TextEditingController _titleController;
  late TextEditingController _bioController;

  bool _isLoading = true;
  Contact? _userProfile;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _companyController = TextEditingController();
    _titleController = TextEditingController();
    _bioController = TextEditingController();
    
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final repo = Provider.of<ContactRepository>(context, listen: false);
    final profile = await repo.getUserProfile();
    
    if (profile != null) {
      _userProfile = profile;
      _nameController.text = profile.name;
      _emailController.text = profile.email ?? '';
      _companyController.text = profile.company ?? '';
      _titleController.text = profile.title ?? '';
      _bioController.text = profile.notes ?? '';
    }
    
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final repo = Provider.of<ContactRepository>(context, listen: false);
    
    // Create new or update existing
    final contact = _userProfile ?? Contact(
      name: '', 
      metAt: DateTime.now(),
      isMe: true, // This flag is critical
    );

    contact.name = _nameController.text;
    contact.email = _emailController.text;
    contact.company = _companyController.text;
    contact.title = _titleController.text;
    contact.notes = _bioController.text; // "Bio" is stored in notes
    
    await repo.saveUserProfile(contact);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated & Embedded")),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: const BackButton(color: Colors.white),
        title: const Text('My Profile', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.blue),
            onPressed: _saveProfile,
          )
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Avatar
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey[800],
                    child: const Icon(Icons.person, size: 60, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 30),
                
                _buildDarkField("Full Name", _nameController),
                const SizedBox(height: 16),
                _buildDarkField("Job Title", _titleController),
                const SizedBox(height: 16),
                _buildDarkField("Company", _companyController),
                const SizedBox(height: 16),
                _buildDarkField("Email", _emailController, keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 16),
                _buildDarkField("Bio / Expertise", _bioController, maxLines: 4),
                
                const SizedBox(height: 30),
                const Text(
                  "Tip: Information here helps the AI understand your context. "
                  "E.g., if you list 'Cactus Corp' as your company, searching "
                  "'people at my company' will work.",
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
    );
  }

  Widget _buildDarkField(String label, TextEditingController controller, {int maxLines = 1, TextInputType? keyboardType}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (v) => v!.isEmpty ? "Required" : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[900],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      ),
    );
  }
}