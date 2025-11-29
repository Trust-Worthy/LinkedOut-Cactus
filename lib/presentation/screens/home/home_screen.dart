import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Ensure you have this dependency or remove if not using SVG here specifically
import '../../../data/models/contact.dart';
import '../../../data/repositories/contact_repository.dart';
import '../../../services/search/smart_search_service.dart';

// Screens
import '../scan/scan_screen.dart';
import '../scan/scan_result_screen.dart';
import '../chat/chat_screen.dart';
import '../timeline/timeline_screen.dart';
// Note: We are using the screens we already built. 
// If you want to use his specific ProfileScreen, import it here.

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  
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

  // Uses the SmartSearchService (Router Agent) we built earlier
  Future<void> _handleSearch(String query) async {
    if (query.isEmpty) {
      setState(() => _filteredContacts = _allContacts);
      return;
    }

    try {
      final searchService = Provider.of<SmartSearchService>(context, listen: false);
      final results = await searchService.search(query);
      setState(() => _filteredContacts = results);
    } catch (e) {
      // Fallback to local filter if service fails
      setState(() {
        _filteredContacts = _allContacts.where((c) => 
          c.name.toLowerCase().contains(query.toLowerCase()) || 
          (c.company?.toLowerCase().contains(query.toLowerCase()) ?? false)
        ).toList();
      });
    }
  }

  void _onScanPressed() {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => const ScanScreen())
    ).then((_) => _loadContacts());
  }

  void _onManualAddPressed() {
    // Reusing the ScanResultScreen for manual entry guarantees Embeddings are generated
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ScanResultScreen(
          initialData: {}, 
          rawText: "",
        ),
      ),
    ).then((_) => _loadContacts());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Friend's Dark Theme
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          // Swipe right to open scanner (Friend's feature)
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
                    // Profile Button (Placeholder)
                    GestureDetector(
                      onTap: () {
                        // TODO: Navigate to ProfileScreen
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
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: TextField(
                          controller: _searchController,
                          style: const TextStyle(color: Colors.white, fontSize: 15),
                          onSubmitted: _handleSearch,
                          textInputAction: TextInputAction.search,
                          decoration: InputDecoration(
                            hintText: 'Search (e.g. "Investors in Denver")',
                            hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
                            prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Add Button
                    GestureDetector(
                      onTap: _onManualAddPressed,
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.blue, // Friend's accent color
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.add, color: Colors.white, size: 24),
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
            _onScanPressed(); // Middle action
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

  // Switches between the main views based on the Bottom Nav
  Widget _buildBody() {
    if (_selectedIndex == 1) return const ChatScreen();
    if (_selectedIndex == 3) return const TimelineScreen();
    
    // Index 0: Home / Contact List
    return _buildContactList();
  }

  Widget _buildContactList() {
    // Header Stats
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_filteredContacts.length} Contacts',
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
        
        // The List
        Expanded(
          child: _isLoading 
            ? const Center(child: CircularProgressIndicator(color: Colors.blue))
            : _filteredContacts.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    itemCount: _filteredContacts.length,
                    itemBuilder: (context, index) {
                      final contact = _filteredContacts[index];
                      
                      // Logic for Section Headers (A, B, C...)
                      bool showSection = index == 0;
                      if (index > 0) {
                        final prevName = _filteredContacts[index - 1].name;
                        if (contact.name.isNotEmpty && prevName.isNotEmpty) {
                          showSection = contact.name[0].toUpperCase() != prevName[0].toUpperCase();
                        }
                      }
                      
                      return _buildContactTile(contact, showSection, index == _filteredContacts.length - 1);
                    },
                  ),
        ),
      ],
    );
  }

  // Friend's "Tile" Design adapted for Real Data
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
              // TODO: Navigate to Contact Detail Screen
              // Navigator.push(...)
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.blue,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
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
                  Icon(
                    Icons.chevron_right,
                    color: Colors.grey[600],
                    size: 22,
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
    return Center(
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
            'Tap + to add your first contact',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }
}