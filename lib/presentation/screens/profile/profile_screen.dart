import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/contact.dart';
import '../../../data/repositories/contact_repository.dart';
import '../../../services/storage/image_storage.dart';

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
    // avatarPath is already set by the image picker, just ensure it persists
    
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
                  child: GestureDetector(
                    onTap: () async {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: Colors.transparent,
                        builder: (ctx) => Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              ListTile(
                                leading: const Icon(Icons.photo_library, color: Colors.white),
                                title: const Text('Choose from gallery', style: TextStyle(color: Colors.white)),
                                onTap: () async {
                                  Navigator.pop(ctx);
                                  final picked = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
                                  if (picked != null) {
                                    final bytes = await picked.readAsBytes();
                                    final ext = picked.path.split('.').last;
                                    final fileName = 'profile_avatar_${DateTime.now().millisecondsSinceEpoch}.$ext';
                                    final saved = await ImageStorage.saveAvatar(bytes, fileName);
                                    setState(() { _userProfile?.avatarPath = saved; });
                                  }
                                },
                              ),
                              ListTile(
                                leading: const Icon(Icons.camera_alt, color: Colors.white),
                                title: const Text('Take a photo', style: TextStyle(color: Colors.white)),
                                onTap: () async {
                                  Navigator.pop(ctx);
                                  final picked = await ImagePicker().pickImage(source: ImageSource.camera, maxWidth: 1024, maxHeight: 1024, imageQuality: 85);
                                  if (picked != null) {
                                    final bytes = await picked.readAsBytes();
                                    final ext = picked.path.split('.').last;
                                    final fileName = 'profile_avatar_${DateTime.now().millisecondsSinceEpoch}.$ext';
                                    final saved = await ImageStorage.saveAvatar(bytes, fileName);
                                    setState(() { _userProfile?.avatarPath = saved; });
                                  }
                                },
                              ),
                              if (_userProfile?.avatarPath != null)
                                ListTile(
                                  leading: const Icon(Icons.delete, color: Colors.red),
                                  title: const Text('Remove photo', style: TextStyle(color: Colors.red)),
                                  onTap: () async {
                                    Navigator.pop(ctx);
                                    await ImageStorage.deleteFileIfExists(_userProfile?.avatarPath);
                                    setState(() { _userProfile?.avatarPath = null; });
                                  },
                                ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      );
                    },
                    child: Stack(
                      children: [
                        Builder(
                          builder: (_) {
                            final hasAvatar = _userProfile?.avatarPath != null && File(_userProfile!.avatarPath!).existsSync();
                            return CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.blue,
                              backgroundImage: hasAvatar ? FileImage(File(_userProfile!.avatarPath!)) : null,
                              child: hasAvatar ? null : const Icon(Icons.person, size: 60, color: Colors.white),
                            );
                          },
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ],
                    ),
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