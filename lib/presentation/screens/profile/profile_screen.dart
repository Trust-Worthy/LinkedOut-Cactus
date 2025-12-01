import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/contact.dart';
import '../../../data/repositories/contact_repository.dart';
import '../../../data/repositories/event_repository.dart';
import '../../../services/storage/image_storage.dart';
import '../../../services/auth/auth_provider.dart';

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

  Future<void> _handleLogout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await Provider.of<AuthProvider>(context, listen: false).logout();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final currentUser = authProvider.currentUser;
    
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
                // User Info Card
                if (currentUser != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[900],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.account_circle, color: Colors.grey[400], size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Logged in as: ',
                              style: TextStyle(color: Colors.grey[400], fontSize: 14),
                            ),
                            Text(
                              currentUser.username,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        if (currentUser.displayName != null && currentUser.displayName != currentUser.username) ...[
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const SizedBox(width: 28),
                              Text(
                                currentUser.displayName!,
                                style: TextStyle(color: Colors.grey[500], fontSize: 13),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
                
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
                
                const SizedBox(height: 40),
                
                // Logout Button
                ElevatedButton(
                  onPressed: _handleLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.red),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout),
                      SizedBox(width: 8),
                      Text(
                        'Logout',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
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