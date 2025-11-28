import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../data/models/contact.dart';

class ContactCard extends StatelessWidget {
  final Contact contact;
  final VoidCallback onTap;

  const ContactCard({
    super.key,
    required this.contact,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Format the date: "Nov 28"
    final dateString = DateFormat('MMM d').format(contact.metAt);
    
    // Get initials for avatar (e.g., "Sarah Chen" -> "SC")
    String initials = "";
    if (contact.name.isNotEmpty) {
      List<String> parts = contact.name.trim().split(" ");
      if (parts.length > 1) {
        initials = "${parts[0][0]}${parts[1][0]}".toUpperCase();
      } else {
        initials = parts[0][0].toUpperCase();
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 24,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  initials,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              
              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    if (contact.title != null || contact.company != null)
                      Text(
                        "${contact.title ?? ''} ${contact.company != null ? '@ ${contact.company}' : ''}",
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    
                    // Location/Event Badge
                    if (contact.eventName != null || contact.addressLabel != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              contact.eventName != null ? Icons.event : Icons.location_on,
                              size: 10,
                              color: Colors.grey.shade500,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              contact.eventName ?? contact.addressLabel ?? "Unknown",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              
              // Date
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    dateString,
                    style: TextStyle(
                      color: Colors.grey.shade400,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}