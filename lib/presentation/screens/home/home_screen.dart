import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/contact.dart';
import '../../../data/repositories/contact_repository.dart';
import '../../widgets/contact/contact_card.dart';
import '../scan/scan_screen.dart';
import '../chat/chat_screen.dart';
import '../timeline/timeline_screen.dart';
import '../scan/scan_result_screen.dart'; // Import reused screen

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1; // Default to Middle (Contacts)
  
  // Contacts Data
  List<Contact> _allContacts = [];
  List<Contact> _filteredContacts = []; // For search
  bool _isLoading = true;
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    try {
      final repo = Provider.of<ContactRepository>(context, listen: false);
      final contacts = await repo.getAllContacts();
      setState(() {
        _allContacts = contacts;
        _filteredContacts = contacts; // Initially show all
        _isLoading = false;
      });
      // Re-apply search if text exists
      if (_searchController.text.isNotEmpty) {
        _filterContacts(_searchController.text);
      }
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
        final name = c.name.toLowerCase();
        final company = (c.company ?? "").toLowerCase();
        final title = (c.title ?? "").toLowerCase();
        return name.contains(lowerQuery) || 
               company.contains(lowerQuery) || 
               title.contains(lowerQuery);
      }).toList();
    });
  }

  void _onScanPressed() {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => const ScanScreen())
    ).then((_) => _loadContacts());
  }

  void _onManualAddPressed() {
    // Navigate to ScanResultScreen with empty data to act as "Add New"
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ScanResultScreen(
          initialData: {}, 
          rawText: "", // No OCR text
          // You could pass current location here if you wanted, 
          // or let the screen fetch it if you implement logic there.
        ),
      ),
    ).then((_) => _loadContacts()); // Refresh list on return
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey.shade300,
            child: const Icon(Icons.person, color: Colors.white),
          ),
        ),
        title: Row(
          children: [
            // Plus button to the LEFT of search bar
            IconButton(
              icon: const Icon(Icons.add_circle_outline, color: Colors.black),
              onPressed: _onManualAddPressed,
            ),
            // Search Bar
            Expanded(
              child: Container(
                height: 40,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: _filterContacts,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    hintText: "Search contacts...",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 8), // Centers text vertically
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      
      body: _buildBody(),
      
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) {
            _onScanPressed(); // Middle button opens Scanner
          } else {
            setState(() => _selectedIndex = index);
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: "Chat AI",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: "Scan",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: "Timeline",
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_selectedIndex == 0) {
      return const ChatScreen();
    } else if (_selectedIndex == 2) {
      return const TimelineScreen();
    }
    
    // Default View: Contact List (Filtered)
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (_allContacts.isEmpty) {
      return _buildEmptyState();
    }

    if (_filteredContacts.isEmpty) {
      return const Center(child: Text("No contacts match your search."));
    }

    return ListView.builder(
      itemCount: _filteredContacts.length,
      padding: const EdgeInsets.all(8),
      itemBuilder: (context, index) {
        return ContactCard(
          contact: _filteredContacts[index],
          onTap: () {
            // TODO: Open Detail Screen
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "Your network is empty",
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          const Text(
            "Scan a card or tap + to add manually",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}