import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../contact/contact_detail_screen.dart';
import '../../../data/models/contact.dart';
import 'dart:io';
import '../../../data/repositories/contact_repository.dart';
import '../../../data/repositories/event_repository.dart';

class EventConnectionsScreen extends StatefulWidget {
  final String eventName;
  final int newConnections;

  const EventConnectionsScreen({
    super.key,
    required this.eventName,
    required this.newConnections,
  });

  @override
  State<EventConnectionsScreen> createState() => _EventConnectionsScreenState();
}

class _EventConnectionsScreenState extends State<EventConnectionsScreen> {
  Future<List<Contact>>? _connectionsFuture;

  @override
  void initState() {
    super.initState();
    _loadConnections();
  }

  void _loadConnections() {
    setState(() {
      _connectionsFuture = Provider.of<ContactRepository>(context, listen: false)
          .getAllContacts()
          .then((all) => all.where((c) => (c.eventName ?? '') == widget.eventName).toList());
    });
  }

  @override
  Widget build(BuildContext context) {
    // Static event details placeholder (could be made dynamic later)
    final eventDetails = {
      'date': 'Nov 10, 2025',
      'location': 'Denver Convention Center, Denver, CO',
      'description': 'Tech Conference 2025 is the premier event for innovators, startups, and tech leaders. Join us for keynotes, networking, and hands-on workshops.',
      'organizer': 'Tech Innovators Group',
      'website': 'www.techconf2025.com',
    };

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(widget.eventName),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadConnections),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Delete event?'),
                  content: const Text('Deleting this event will remove it from your events list.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                    TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                ),
              );

              if (confirm == true) {
                await EventRepository().deleteEvent(widget.eventName);
                if (mounted) Navigator.pop(context, true);
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Event storefront card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.event, color: Colors.blue, size: 32),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.eventName, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text('${eventDetails['date']} • ${eventDetails['location']}', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(eventDetails['description']!, style: const TextStyle(color: Colors.white, fontSize: 15)),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.business, color: Colors.blueAccent, size: 20),
                      const SizedBox(width: 6),
                      Text('Organizer: ', style: const TextStyle(color: Colors.grey, fontSize: 14)),
                      Text(eventDetails['organizer']!, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.link, color: Colors.blueAccent, size: 20),
                      const SizedBox(width: 6),
                      Text(eventDetails['website']!, style: const TextStyle(color: Colors.blueAccent, fontSize: 14, decoration: TextDecoration.underline)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Connections', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: FutureBuilder<List<Contact>>(
                future: _connectionsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final connections = snapshot.data ?? [];

                  if (connections.isEmpty) {
                    return const Center(child: Text('No connections for this event yet.', style: TextStyle(color: Colors.white)));
                  }

                  return ListView.separated(
                    itemCount: connections.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final conn = connections[i];
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[850],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ListTile(
                          leading: Builder(
                            builder: (_) {
                              final hasAvatar = conn.avatarPath != null && File(conn.avatarPath!).existsSync();
                              return CircleAvatar(
                                backgroundColor: Colors.blue,
                                backgroundImage: hasAvatar ? FileImage(File(conn.avatarPath!)) : null,
                                child: hasAvatar ? null : Text(conn.name.isNotEmpty ? conn.name[0] : '?', style: const TextStyle(color: Colors.white)),
                              );
                            },
                          ),
                          title: Text(conn.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${conn.title ?? ''} at ${conn.company ?? ''}', style: const TextStyle(color: Colors.grey)),
                              if (conn.notes != null && conn.notes!.isNotEmpty)
                                Text(conn.notes!, style: const TextStyle(color: Colors.white)),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.message, color: Colors.blue),
                            onPressed: () {
                              // TODO: Message action
                            },
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => ContactDetailScreen(contact: conn)),
                            ).then((_) => _loadConnections());
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
