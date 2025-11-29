import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../data/models/contact.dart';
import '../../../data/repositories/contact_repository.dart';
import '../../../services/storage/image_storage.dart';

class ContactDetailScreen extends StatefulWidget {
  final Contact contact;

  const ContactDetailScreen({
    super.key,
    required this.contact,
  });

  @override
  State<ContactDetailScreen> createState() => _ContactDetailScreenState();
}

class _ContactDetailScreenState extends State<ContactDetailScreen> {
  late Contact _contact;

  @override
  void initState() {
    super.initState();
    _contact = widget.contact;
  }

  void _showEditContactBottomSheet(BuildContext context) {
    final nameController = TextEditingController(text: _contact.name);
    final companyController = TextEditingController(text: _contact.company);
    final titleController = TextEditingController(text: _contact.title);
    final emailController = TextEditingController(text: _contact.email);
    final phoneController = TextEditingController(text: _contact.phone);
    final placeController = TextEditingController(text: _contact.addressLabel);
    final eventController = TextEditingController(text: _contact.eventName);
    final notesController = TextEditingController(text: _contact.notes);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[700],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(color: Colors.grey, fontSize: 16),
                      ),
                    ),
                    const Text(
                      'Edit Contact',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () async {
                        // Update object in memory
                        _contact.name = nameController.text;
                        _contact.company = companyController.text;
                        _contact.title = titleController.text;
                        _contact.email = emailController.text;
                        _contact.phone = phoneController.text;
                        _contact.addressLabel = placeController.text;
                        _contact.eventName = eventController.text;
                        _contact.notes = notesController.text;

                        // Save to Database
                        await Provider.of<ContactRepository>(context, listen: false)
                            .saveContact(_contact);
                        
                        // Update UI
                        setState(() {});
                        
                        if (mounted) Navigator.pop(context);
                      },
                      child: const Text(
                        'Save',
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              Divider(color: Colors.grey[800], height: 1),
              
              // Form content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                                      // Edit Image Placeholder
                      GestureDetector(
                        onTap: () async {
                          // Show options: Camera / Gallery / Remove
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
                                        final fileName = 'avatar_${_contact.id}_${DateTime.now().millisecondsSinceEpoch}.$ext';
                                        final saved = await ImageStorage.saveAvatar(bytes, fileName);
                                        setState(() { _contact.avatarPath = saved; });
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
                                        final fileName = 'avatar_${_contact.id}_${DateTime.now().millisecondsSinceEpoch}.$ext';
                                        final saved = await ImageStorage.saveAvatar(bytes, fileName);
                                        setState(() { _contact.avatarPath = saved; });
                                      }
                                    },
                                  ),
                                  if (_contact.avatarPath != null)
                                    ListTile(
                                      leading: const Icon(Icons.delete, color: Colors.red),
                                      title: const Text('Remove photo', style: TextStyle(color: Colors.red)),
                                      onTap: () async {
                                        Navigator.pop(ctx);
                                        await ImageStorage.deleteFileIfExists(_contact.avatarPath);
                                        setState(() { _contact.avatarPath = null; });
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
                            CircleAvatar(
                              radius: 50,
                              backgroundColor: Colors.blue,
                              child: Text(
                                _contact.name.isNotEmpty ? _contact.name[0].toUpperCase() : "?",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 32,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Colors.grey[900]!, width: 2),
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      _buildDarkTextField("Name", nameController, Icons.person),
                      const SizedBox(height: 16),
                      _buildDarkTextField("Company", companyController, Icons.business),
                      const SizedBox(height: 16),
                      _buildDarkTextField("Job Title", titleController, Icons.work),
                      const SizedBox(height: 16),
                      _buildDarkTextField("Email", emailController, Icons.email, keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 16),
                      _buildDarkTextField("Phone", phoneController, Icons.phone, keyboardType: TextInputType.phone),
                      const SizedBox(height: 16),
                      _buildDarkTextField("Location / City", placeController, Icons.place),
                      const SizedBox(height: 16),
                      _buildDarkTextField("Event Name", eventController, Icons.event),
                      const SizedBox(height: 16),
                      _buildDarkTextField("Notes", notesController, Icons.note, maxLines: 4),
                      
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDarkTextField(String label, TextEditingController controller, IconData icon, {TextInputType? keyboardType, int maxLines = 1}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        filled: true,
        fillColor: Colors.grey[850],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        prefixIcon: Padding(
          padding: maxLines > 1 ? const EdgeInsets.only(bottom: 60) : EdgeInsets.zero,
          child: Icon(icon, color: Colors.grey[500]),
        ),
        alignLabelWithHint: maxLines > 1,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Format Display Data
    final initials = _contact.name.isNotEmpty ? _contact.name[0].toUpperCase() : "?";
    final dateStr = DateFormat.yMMMd().format(_contact.metAt);
    final jobStr = "${_contact.title ?? ''}${(_contact.title != null && _contact.company != null) ? ' at ' : ''}${_contact.company ?? ''}";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue),
            onPressed: () {
              _showEditContactBottomSheet(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Delete Contact?"),
                  content: const Text("This cannot be undone."),
                  actions: [
                    TextButton(onPressed: ()=> Navigator.pop(ctx, false), child: const Text("Cancel")),
                    TextButton(onPressed: ()=> Navigator.pop(ctx, true), child: const Text("Delete", style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              
              if (confirm == true && mounted) {
                await Provider.of<ContactRepository>(context, listen: false).deleteContact(_contact.id);
                if (mounted) Navigator.pop(context);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Builder(
                    builder: (_) {
                      final hasAvatar = _contact.avatarPath != null && File(_contact.avatarPath!).existsSync();
                      return CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.blue,
                        backgroundImage: hasAvatar ? FileImage(File(_contact.avatarPath!)) : null,
                        child: hasAvatar ? null : Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _contact.name,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (jobStr.isNotEmpty) ...[  
                    const SizedBox(height: 8),
                    Text(
                      jobStr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Connection Info Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Connection Details',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _InfoRow(
                    icon: Icons.calendar_today,
                    label: 'Met on',
                    value: dateStr,
                  ),
                  const SizedBox(height: 12),
                  if (_contact.addressLabel != null || _contact.eventName != null)
                    _InfoRow(
                      icon: Icons.place,
                      label: 'Location / Event',
                      value: "${_contact.addressLabel ?? ''} \n${_contact.eventName ?? ''}".trim(),
                    ),
                ],
              ),
            ),

            // Contact Info Card
            if (_contact.email != null || _contact.phone != null)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Contact Information',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_contact.email != null && _contact.email!.isNotEmpty) ...[  
                      _InfoRow(
                        icon: Icons.email,
                        label: 'Email',
                        value: _contact.email!,
                        isLink: true,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_contact.phone != null && _contact.phone!.isNotEmpty)
                      _InfoRow(
                        icon: Icons.phone,
                        label: 'Phone',
                        value: _contact.phone!,
                        isLink: true,
                      ),
                  ],
                ),
              ),

            // Notes Card
            if (_contact.notes != null && _contact.notes!.isNotEmpty)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Notes',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _contact.notes!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isLink;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.isLink = false,
  });

  @override
  Widget build(BuildContext context) {
    if (value.isEmpty) return const SizedBox.shrink();
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.grey[500],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.grey[500],
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  color: isLink ? Colors.blue : Colors.white,
                  fontSize: 16,
                  decoration: isLink ? TextDecoration.underline : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}