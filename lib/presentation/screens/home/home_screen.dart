import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/models/contact.dart';
import 'dart:io';
import '../../../data/repositories/contact_repository.dart';
import '../../../data/repositories/event_repository.dart';
import '../../../data/models/event.dart';
import '../../../services/search/smart_search_service.dart';
import '../../../core/utils/mock_data_generator.dart'; // Import Mock Generator

// Screens
import '../scan/scan_screen.dart';
import '../scan/scan_result_screen.dart';
import '../chat/chat_screen.dart';
import '../timeline/timeline_screen.dart';
import '../contact/contact_detail_screen.dart';
import '../profile/profile_screen.dart';
import '../event/event_connections_screen.dart';
import '../event/event_create_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  bool _isLoading = true;
  List<EventModel> _events = [];
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _loadEvents();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    try {
      final repo = Provider.of<ContactRepository>(context, listen: false);
      final contacts = await repo.getAllContacts();
      
      // Sort alphabetically for the grouped list view
      contacts.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));

      setState(() {
        _allContacts = contacts;
        _filteredContacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadEvents() async {
    final repo = EventRepository();
    final events = await repo.getAllEvents();
    setState(() => _events = events);
  }

  Future<void> _handleSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _filteredContacts = _allContacts);
      return;
    }

    try {
      final searchService = Provider.of<SmartSearchService>(context, listen: false);
      final results = await searchService.search(query);
      results.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      setState(() => _filteredContacts = results);
    } catch (e) {
      final filtered = _allContacts.where((c) => 
        c.name.toLowerCase().contains(query.toLowerCase()) || 
        (c.company?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();
      filtered.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      setState(() => _filteredContacts = filtered);
    }
  }

  void _onScanPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ScanScreen()),
    ).then((_) async {
      await _loadContacts();
      await _loadEvents();
    });
  }

  void _onManualAddPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ScanResultScreen(
          initialData: {},
          rawText: "",
        ),
      ),
    ).then((_) async {
      await _loadContacts();
      await _loadEvents();
    });
  }

  void _showAddMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person_add, color: Colors.white),
              title: const Text('Add New Contact', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Create a contact manually or scan a card', style: TextStyle(color: Colors.grey)),
              onTap: () {
                Navigator.pop(ctx);
                _onManualAddPressed();
              },
            ),
            ListTile(
              leading: const Icon(Icons.event, color: Colors.white),
              title: const Text('Add New Event', style: TextStyle(color: Colors.white)),
              subtitle: const Text('Create an event to track connections', style: TextStyle(color: Colors.grey)),
              onTap: () async {
                Navigator.pop(ctx);
                final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const EventCreateScreen()));
                if (result == true) {
                  await _loadEvents();
                }
              },
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, 
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! > 0) {
            _onScanPressed();
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // --- Custom Top Bar ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                child: Row(
                  children: [
                    // Profile Button
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProfileScreen())
                        ).then((_) => _loadContacts());
                      },
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.grey[800],
                        child: const Icon(Icons.person, color: Colors.white70),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Search Bar
                    Expanded(
                      child: Container(
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: TextField(
                            controller: _searchController,
                            style: const TextStyle(color: Colors.white, fontSize: 16),
                            onSubmitted: _handleSearch,
                            textInputAction: TextInputAction.search,
                            decoration: InputDecoration(
                              hintText: 'Search contacts, companies, events...',
                              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 16),
                              prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 22),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 0),
                            ),
                            textAlignVertical: TextAlignVertical.center,
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Add Button
                    GestureDetector(
                      onTap: () => _showAddMenu(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.blue, 
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 24),
                      ),
                    ),

                    // --- NEW: Seed Data Button (Hidden helper for Demo) ---
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () async {
                        setState(() => _isLoading = true);
                        final repo = Provider.of<ContactRepository>(context, listen: false);
                        await MockDataGenerator.generateMockContacts(repo);
                        await _loadContacts();
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Generated 15 Mock Contacts!"))
                          );
                        }
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[800], 
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.cloud_download, color: Colors.white, size: 20),
                      ),
                    ),
                  ],
                ),
              ),

              // --- Content Body ---
              Expanded(
                child: _buildBody(),
              ),
            ],
          ),
        ),
      ),
      
      // --- Bottom Navigation ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey[600],
        onTap: (index) {
          if (index == 2) {
            _onScanPressed(); 
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'AI Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Scan'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Timeline'),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedIndex == 1) return const ChatScreen();
    if (_selectedIndex == 3) return const TimelineScreen();
    
    // Index 0: Home / Contact List
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildEventFeaturesSection(),
            const SizedBox(height: 18),
            _buildContactsHeader(),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(18),
              ),
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.55,
                child: _buildContactList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventFeaturesSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Event Features',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          if (_events.isEmpty) ...[
            const SizedBox(height: 8),
            const Text('No events yet. Create an event to track connections.', style: TextStyle(color: Colors.grey)),
          ] else ...[
              for (final ev in _events)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.event, color: Colors.white),
                  title: Text(ev.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  subtitle: Text(
                    '${_allContacts.where((c) => c.eventName == ev.name).length} new connections',
                    style: const TextStyle(color: Colors.blueAccent),
                  ),
                  trailing: PopupMenuButton<String>(
                    color: Colors.grey[900],
                    icon: const Icon(Icons.more_vert, color: Colors.white),
                    onSelected: (value) async {
                      if (value == 'view') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EventConnectionsScreen(
                              eventName: ev.name,
                              newConnections: _allContacts.where((c) => c.eventName == ev.name).length,
                            ),
                          ),
                        );
                      } else if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete event?'),
                            content: const Text('This will remove the event. Contacts will keep their eventName.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await EventRepository().deleteEvent(ev.name);
                          await _loadEvents();
                        }
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'view', child: Text('View', style: TextStyle(color: Colors.white))),
                      const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                  onTap: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventConnectionsScreen(
                          eventName: ev.name,
                          newConnections: _allContacts.where((c) => c.eventName == ev.name).length,
                        ),
                      ),
                    );
                    if (result == true) await _loadEvents();
                  },
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildContactsHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Contacts',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${_filteredContacts.length} total',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildContactList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: Colors.blue));
    }
    if (_filteredContacts.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      itemCount: _filteredContacts.length,
      itemBuilder: (context, index) {
        final contact = _filteredContacts[index];
        bool showSection = index == 0;
        if (index > 0) {
          final prevName = _filteredContacts[index - 1].name;
          if (contact.name.isNotEmpty && prevName.isNotEmpty) {
            showSection = contact.name[0].toUpperCase() != prevName[0].toUpperCase();
          }
        }
        return _buildContactTile(contact, showSection, index == _filteredContacts.length - 1);
      },
    );
  }

  Widget _buildContactTile(Contact contact, bool showSection, bool isLast) {
    String initials = contact.name.isNotEmpty ? contact.name[0].toUpperCase() : "?";
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showSection)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            color: Colors.black,
            child: Text(
              initials,
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
        
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ContactDetailScreen(contact: contact))
              ).then((_) => _loadContacts());
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Builder(
                    builder: (_) {
                      // In current model we don't have avatarPath, so default to initials.
                      // If you add avatarPath to Contact model later, uncomment below logic.
                      // final hasAvatar = contact.avatarPath != null && File(contact.avatarPath!).existsSync();
                      const hasAvatar = false; 
                      return CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.blue,
                        // backgroundImage: hasAvatar ? FileImage(File(contact.avatarPath!)) : null,
                        child: hasAvatar ? null : Text(
                          initials,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          contact.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          contact.company ?? contact.title ?? "No Details",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    color: Colors.grey[900],
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    onSelected: (value) async {
                      if (value == 'view') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => ContactDetailScreen(contact: contact)),
                        ).then((_) => _loadContacts());
                      } else if (value == 'delete') {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete contact?'),
                            content: const Text('This action cannot be undone.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          await Provider.of<ContactRepository>(context, listen: false).deleteContact(contact.id);
                          await _loadContacts();
                        }
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'view', child: Text('View', style: TextStyle(color: Colors.white))),
                      const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.only(left: 80),
            child: Divider(
              height: 1,
              thickness: 0.3,
              color: Colors.grey[850],
            ),
          ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return GestureDetector(
      onTap: _onManualAddPressed,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.contacts_outlined, size: 80, color: Colors.grey[700]),
            const SizedBox(height: 16),
            Text(
              'No contacts found',
              style: TextStyle(color: Colors.grey[500], fontSize: 18, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap anywhere here or + to add your first contact',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}