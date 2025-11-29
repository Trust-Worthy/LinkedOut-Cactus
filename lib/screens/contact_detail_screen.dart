import 'package:flutter/material.dart';

class ContactDetailScreen extends StatelessWidget {
  final String name;
  final String avatar;
  final String date;
  final String place;
  final String? occupation;
  final String? email;
  final String? phone;
  final String? notes;
  final String? imageUrl;

  const ContactDetailScreen({
    super.key,
    required this.name,
    required this.avatar,
    required this.date,
    required this.place,
    this.occupation,
    this.email,
    this.phone,
    this.notes,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
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
              // TODO: Edit contact
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
                  CircleAvatar(
                    radius: 60,
                    backgroundColor: Colors.blue,
                    backgroundImage: imageUrl != null 
                        ? NetworkImage(imageUrl!)
                        : null,
                    child: imageUrl == null
                        ? Text(
                            avatar,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (occupation != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      occupation!,
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
                    value: date,
                  ),
                  const SizedBox(height: 12),
                  _InfoRow(
                    icon: Icons.place,
                    label: 'Location',
                    value: place,
                  ),
                ],
              ),
            ),

            // Contact Info Card
            if (email != null || phone != null)
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
                    if (email != null) ...[
                      _InfoRow(
                        icon: Icons.email,
                        label: 'Email',
                        value: email!,
                        isLink: true,
                      ),
                      if (phone != null) const SizedBox(height: 12),
                    ],
                    if (phone != null)
                      _InfoRow(
                        icon: Icons.phone,
                        label: 'Phone',
                        value: phone!,
                        isLink: true,
                      ),
                  ],
                ),
              ),

            // Notes Card
            if (notes != null && notes!.isNotEmpty)
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
                      notes!,
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
