import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../data/models/contact.dart';
import '../../../data/repositories/contact_repository.dart';
import '../contact/contact_detail_screen.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  // Data State
  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = [];
  bool _isLoading = true;
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    try {
      final repo = Provider.of<ContactRepository>(context, listen: false);
      final contacts = await repo.getAllContacts();
      
      // Sort by Date (Newest First) for a true Timeline
      contacts.sort((a, b) => b.metAt.compareTo(a.metAt));

      setState(() {
        _allContacts = contacts;
        _filteredContacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _filterContacts(String query) {
    if (query.isEmpty) {
      setState(() => _filteredContacts = _allContacts);
      return;
    }
    
    final lowerQuery = query.toLowerCase();
    setState(() {
      _filteredContacts = _allContacts.where((c) {
        return c.name.toLowerCase().contains(lowerQuery) ||
               (c.company?.toLowerCase().contains(lowerQuery) ?? false) ||
               (c.eventName?.toLowerCase().contains(lowerQuery) ?? false) ||
               (c.addressLabel?.toLowerCase().contains(lowerQuery) ?? false);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Friend's Dark Theme
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        // Removed leading back button since this is a main Tab
        automaticallyImplyLeading: false, 
        title: const Text(
          'Timeline',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search bar (Friend's Design)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: TextField(
              controller: _searchController,
              onChanged: _filterContacts,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Search connections...',
                hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
                filled: true,
                fillColor: Colors.grey[900],
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Timeline list
          Expanded(
            child: _isLoading 
              ? const Center(child: CircularProgressIndicator(color: Colors.blue))
              : _filteredContacts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.timeline,
                            size: 80,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No connections yet',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: _filteredContacts.length,
                      itemBuilder: (context, index) {
                        final contact = _filteredContacts[index];
                        
                        // Formatting Data
                        final initials = contact.name.isNotEmpty ? contact.name[0].toUpperCase() : "?";
                        final dateStr = DateFormat('MMM d, yyyy').format(contact.metAt);
                        final locationStr = contact.eventName ?? contact.addressLabel ?? "Unknown Place";
                        final jobStr = "${contact.title ?? ''} ${contact.company != null ? '@ ${contact.company}' : ''}".trim();
                        
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          decoration: BoxDecoration(
                            color: Colors.grey[900],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            leading: CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.blue,
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            title: Text(
                              contact.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (jobStr.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4, bottom: 4),
                                    child: Text(
                                      jobStr,
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                
                                // Date Row
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 14,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      dateStr,
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                
                                // Location Row
                                Row(
                                  children: [
                                    Icon(
                                      Icons.place,
                                      size: 14,
                                      color: Colors.grey[500],
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: Text(
                                        locationStr,
                                        style: TextStyle(
                                          color: Colors.grey[400],
                                          fontSize: 13,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            trailing: Icon(
                              Icons.chevron_right,
                              color: Colors.grey[600],
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ContactDetailScreen(contact: contact),
                                ),
                              ).then((_) => _loadContacts()); // Refresh on return
                            },
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}