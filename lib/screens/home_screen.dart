import 'package:flutter/material.dart';
import 'ai_chat_screen.dart';
import 'timeline_screen.dart';
import 'profile_screen.dart';
import 'contact_detail_screen.dart';
import 'scanner_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // Default profile image URL for the user avatar (can be updated later)
  final String _profileImageUrl = 'https://randomuser.me/api/portraits/men/32.jpg';

  // Sample contacts data
  final List<Map<String, String>> _contacts = [
    {'name': 'Alex Johnson', 'company': 'Tech Corp', 'phone': '+1 234 567 8900', 'image': 'https://randomuser.me/api/portraits/men/1.jpg', 'event': 'TechCrunch Disrupt 2025'},
    {'name': 'Amanda White', 'company': 'StartUp Inc', 'phone': '+1 234 567 8901', 'image': 'https://randomuser.me/api/portraits/women/2.jpg', 'event': 'Y Combinator Demo Day'},
    {'name': 'Andrew Miller', 'company': 'Creative Agency', 'phone': '+1 234 567 8902', 'image': 'https://randomuser.me/api/portraits/men/3.jpg', 'event': 'Adobe MAX Conference'},
    {'name': 'Brian Smith', 'company': 'Design Studio', 'phone': '+1 234 567 8903', 'image': 'https://randomuser.me/api/portraits/men/4.jpg', 'event': 'SXSW Interactive Festival'},
    {'name': 'Bella Martinez', 'company': 'Media Corp', 'phone': '+1 234 567 8904', 'image': 'https://randomuser.me/api/portraits/women/5.jpg', 'event': 'NAB Show 2025'},
    {'name': 'Catherine Lee', 'company': 'Marketing Inc', 'phone': '+1 234 567 8905', 'image': 'https://randomuser.me/api/portraits/women/6.jpg', 'event': 'Content Marketing World'},
    {'name': 'Chris Anderson', 'company': 'Tech Solutions', 'phone': '+1 234 567 8906', 'image': 'https://randomuser.me/api/portraits/men/7.jpg', 'event': 'Google I/O Developer Conference'},
    {'name': 'David Brown', 'company': 'Sales Pro', 'phone': '+1 234 567 8907', 'image': 'https://randomuser.me/api/portraits/men/8.jpg', 'event': 'Dreamforce by Salesforce'},
    {'name': 'Diana Ross', 'company': 'Entertainment Co', 'phone': '+1 234 567 8908', 'image': 'https://randomuser.me/api/portraits/women/9.jpg', 'event': 'Cannes Film Festival Networking'},
    {'name': 'Emily Davis', 'company': 'Consulting LLC', 'phone': '+1 234 567 8909', 'image': 'https://randomuser.me/api/portraits/women/10.jpg', 'event': 'McKinsey Executive Roundtable'},
    {'name': 'Emma Thompson', 'company': 'Fashion Brand', 'phone': '+1 234 567 8910', 'image': 'https://randomuser.me/api/portraits/women/11.jpg', 'event': 'New York Fashion Week'},
    {'name': 'Ethan Hunt', 'company': 'Security Firm', 'phone': '+1 234 567 8911', 'image': 'https://randomuser.me/api/portraits/men/12.jpg', 'event': 'RSA Conference 2025'},
    {'name': 'Frank Wilson', 'company': 'Finance Group', 'phone': '+1 234 567 8912', 'image': 'https://randomuser.me/api/portraits/men/13.jpg', 'event': 'World Economic Forum'},
    {'name': 'Grace Martinez', 'company': 'Legal Firm', 'phone': '+1 234 567 8913', 'image': 'https://randomuser.me/api/portraits/women/14.jpg', 'event': 'American Bar Association Conference'},
    {'name': 'Henry Taylor', 'company': 'Real Estate', 'phone': '+1 234 567 8914', 'image': 'https://randomuser.me/api/portraits/men/15.jpg', 'event': 'MIPIM Real Estate Summit'},
    {'name': 'Hannah Lee', 'company': 'Hospitality Group', 'phone': '+1 234 567 8915', 'image': 'https://randomuser.me/api/portraits/women/16.jpg', 'event': 'Skift Global Forum'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          // Swipe right detection
          if (details.primaryVelocity! > 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ScannerScreen(),
              ),
            );
          }
        },
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Row(
                children: [
                  // Profile Button
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[800],
                      backgroundImage: NetworkImage(_profileImageUrl),
                      child: null,
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
                        style: const TextStyle(color: Colors.white, fontSize: 15),
                        decoration: InputDecoration(
                          hintText: 'Search',
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
                    onTap: _showAddContactModal,
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
                ],
              ),
            ),

            // Contacts count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_contacts.length} Contacts',
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

            // Contact list
            Expanded(
              child: _contacts.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.contacts_outlined,
                            size: 80,
                            color: Colors.grey[700],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No contacts yet',
                            style: TextStyle(
                              color: Colors.grey[500],
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap + to add your first contact',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      itemCount: _contacts.length,
                      itemBuilder: (context, index) {
                        final contact = _contacts[index];
                        final showSection = index == 0 || 
                            contact['name']![0] != _contacts[index - 1]['name']![0];
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (showSection)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                                color: Colors.black,
                                child: Text(
                                  contact['name']![0].toUpperCase(),
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
                                    MaterialPageRoute(
                                      builder: (context) => ContactDetailScreen(
                                        name: contact['name']!,
                                        avatar: contact['name']![0].toUpperCase(),
                                        date: 'Nov 28, 2025',
                                        place: contact['event'] ?? 'Networking Event',
                                        occupation: contact['company'],
                                        email: '${contact['name']!.toLowerCase().replaceAll(' ', '.')}@email.com',
                                        phone: contact['phone'],
                                        notes: 'Met at ${contact['event'] ?? 'a professional networking event'}.',
                                        imageUrl: contact['image'],
                                      ),
                                    ),
                                  );
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 24,
                                        backgroundColor: Colors.blue,
                                        backgroundImage: contact['image'] != null 
                                            ? NetworkImage(contact['image']!)
                                            : null,
                                        child: contact['image'] == null
                                            ? Text(
                                                contact['name']![0].toUpperCase(),
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 18,
                                                ),
                                              )
                                            : null,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              contact['name']!,
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 17,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 3),
                                            Text(
                                              contact['company']!,
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
                            if (index < _contacts.length - 1)
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
                      },
                    ),
            ),
          ],
        ),
          ),
        ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          
          // Navigate to screens based on index
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AiChatScreen(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ScannerScreen(),
              ),
            );
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TimelineScreen(),
              ),
            );
          }
          // 0 = Home
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey[600],
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: 'AI',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.qr_code_scanner),
            label: 'Scan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'Timeline',
          ),
        ],
      ),
    );
  }

  void _showAddContactModal() {
    final nameController = TextEditingController();
    final occupationController = TextEditingController();
    final emailController = TextEditingController();
    final phoneController = TextEditingController();
    final eventController = TextEditingController();
    final notesController = TextEditingController();

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
                      'New Contact',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        // TODO: Save contact
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Done',
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
              
              const Divider(color: Colors.grey, height: 1),
              
              // Form content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // Add Image
                      GestureDetector(
                        onTap: () {
                          // TODO: Add image picker
                        },
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[800],
                            shape: BoxShape.circle,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo, color: Colors.grey[500], size: 32),
                              const SizedBox(height: 4),
                              Text(
                                'Add Photo',
                                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Name
                      TextField(
                        controller: nameController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[850],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.person, color: Colors.grey[500]),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Occupation
                      TextField(
                        controller: occupationController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Occupation',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[850],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.work, color: Colors.grey[500]),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Email
                      TextField(
                        controller: emailController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[850],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.email, color: Colors.grey[500]),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Phone
                      TextField(
                        controller: phoneController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.phone,
                        decoration: InputDecoration(
                          labelText: 'Phone',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[850],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.phone, color: Colors.grey[500]),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Event
                      TextField(
                        controller: eventController,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Event / Where you met',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[850],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Icon(Icons.event, color: Colors.grey[500]),
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Notes
                      TextField(
                        controller: notesController,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: 'Notes',
                          labelStyle: TextStyle(color: Colors.grey[400]),
                          filled: true,
                          fillColor: Colors.grey[850],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(bottom: 60),
                            child: Icon(Icons.note, color: Colors.grey[500]),
                          ),
                          alignLabelWithHint: true,
                        ),
                      ),
                      
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
}