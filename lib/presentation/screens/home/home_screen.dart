import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/contact.dart';
import '../../../data/repositories/contact_repository.dart';
import '../../widgets/contact/contact_card.dart';
import '../scan/scan_screen.dart'; // We will create this next
// import '../map/map_screen.dart';   // We will create this later

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  List<Contact> _contacts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  // Fetch contacts from the database
  Future<void> _loadContacts() async {
    setState(() => _isLoading = true);
    try {
      final repo = Provider.of<ContactRepository>(context, listen: false);
      final contacts = await repo.getAllContacts();
      setState(() {
        _contacts = contacts;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading contacts: $e");
      setState(() => _isLoading = false);
    }
  }

  // void _onFabPressed() {
  //   // Navigate to Scan Screen
  //   // Navigator.push(context, MaterialPageRoute(builder: (_) => const ScanScreen()))
  //   //     .then((_) => _loadContacts()); // Reload list when returning
    
  //   // TEMPORARY: Add a dummy contact so you can see the list work immediately
  //   _addDummyContact();
  // }

  void _onFabPressed() {
    Navigator.push(
      context, 
      MaterialPageRoute(builder: (_) => const ScanScreen())
    ).then((_) {
      // Refresh list when returning from scan
      _loadContacts(); 
    });
  }
  
  // Helper for testing without the scanner
  Future<void> _addDummyContact() async {
    final repo = Provider.of<ContactRepository>(context, listen: false);
    final dummy = Contact(
      name: "Test User ${_contacts.length + 1}",
      company: "Cactus AI",
      title: "Engineer",
      metAt: DateTime.now(),
      addressLabel: "Hackathon Venue",
    );
    await repo.saveContact(dummy);
    _loadContacts(); // Refresh UI
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          "LinkedOut",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              // TODO: Open Settings
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _contacts.isEmpty
              ? _buildEmptyState()
              : _buildContactList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onFabPressed,
        backgroundColor: Colors.black,
        icon: const Icon(Icons.qr_code_scanner, color: Colors.white),
        label: const Text("Scan Card", style: TextStyle(color: Colors.white)),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          // Handle navigation logic here later
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.list), label: "Network"),
          BottomNavigationBarItem(icon: Icon(Icons.map), label: "Map"),
        ],
      ),
    );
  }

  Widget _buildContactList() {
    return Column(
      children: [
        // Search Bar (Visual Only for MVP Phase 1)
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: "Search your network...",
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
          ),
        ),
        
        // List
        Expanded(
          child: ListView.builder(
            itemCount: _contacts.length,
            padding: const EdgeInsets.only(bottom: 80), // Space for FAB
            itemBuilder: (context, index) {
              return ContactCard(
                contact: _contacts[index],
                onTap: () {
                  // TODO: Open Detail Screen
                },
              );
            },
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
          Icon(Icons.people_outline, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            "Your network is empty",
            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 8),
          const Text(
            "Scan a business card to get started",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}