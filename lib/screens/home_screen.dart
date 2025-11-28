import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        // Put profile, search box, and plus on the same plane
        leading: Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: CircleAvatar(
            backgroundColor: Colors.grey[800],
            radius: 20,
            child: IconButton(
              icon: const Icon(Icons.person, color: Colors.white),
              onPressed: () {
                // TODO: Open profile screen
              },
            ),
          ),
        ),
        title: SizedBox(
          height: 44,
          child: TextField(
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Search professionals...',
              hintStyle: TextStyle(color: Colors.grey[500]),
              prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
              filled: true,
              fillColor: Colors.grey[900],
              contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 8),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(32),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12.0),
            child: CircleAvatar(
              backgroundColor: Colors.grey[800],
              radius: 20,
              child: IconButton(
                icon: const Icon(Icons.add, color: Colors.white),
                onPressed: () {}, // disabled for now
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search professionals...',
                  hintStyle: TextStyle(color: Colors.grey[500]),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
                  filled: true,
                  fillColor: Colors.grey[900],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(32),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // Featured section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Featured Connections',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: 3,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 12),
                          child: _ProfessionalCard(
                            name: 'Professional ${index + 1}',
                            title: 'Senior Developer',
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Recent activity
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Recent Activity',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ActivityItem(
                    name: 'John Doe',
                    action: 'Started following you',
                    time: '2 hours ago',
                  ),
                  const SizedBox(height: 12),
                  _ActivityItem(
                    name: 'Jane Smith',
                    action: 'Liked your post',
                    time: '4 hours ago',
                  ),
                  const SizedBox(height: 12),
                  _ActivityItem(
                    name: 'Mike Johnson',
                    action: 'Viewed your profile',
                    time: '1 day ago',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          // TODO: Connect to respective screens
          // 0 = Home
          // 1 = AI Search
          // 2 = Scanner
          // 3 = Timeline
        },
        type: BottomNavigationBarType.fixed,
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
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.person_add, color: Colors.white),
                title: const Text('Add Manually', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showAddContactManually();
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_upload, color: Colors.white),
                title: const Text('Import from File', style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(context);
                  _showImportFromFile();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  void _showAddContactManually() {
    final nameController = TextEditingController();
    final titleController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Add Contact', style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Name',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  labelText: 'Title',
                  labelStyle: TextStyle(color: Colors.grey[400]),
                  filled: true,
                  fillColor: Colors.grey[800],
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () {
                // TODO: Save contact
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showImportFromFile() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Import from File', style: TextStyle(color: Colors.white)),
          content: const Text('Import from file is not implemented yet.', style: TextStyle(color: Colors.white)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}

class _ProfessionalCard extends StatelessWidget {
  final String name;
  final String title;

  const _ProfessionalCard({
    required this.name,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[800],
            child: const Icon(Icons.person, color: Colors.white),
          ),
          Column(
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Connect',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActivityItem extends StatelessWidget {
  final String name;
  final String action;
  final String time;

  const _ActivityItem({
    required this.name,
    required this.action,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: Colors.grey[800],
            child: const Icon(Icons.person, color: Colors.white),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: name,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: ' $action',
                        style: TextStyle(
                          color: Colors.grey[400],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
