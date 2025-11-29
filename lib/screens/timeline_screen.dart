import 'package:flutter/material.dart';
import 'contact_detail_screen.dart';

class TimelineScreen extends StatefulWidget {
  const TimelineScreen({super.key});

  @override
  State<TimelineScreen> createState() => _TimelineScreenState();
}

class _TimelineScreenState extends State<TimelineScreen> {
  // Sample timeline data with connections
  final List<Map<String, String>> _connections = [
    {
      'name': 'Alex Johnson',
      'date': 'Nov 25, 2025',
      'place': 'Tech Conference 2025',
      'avatar': 'AJ',
      'occupation': 'Senior Developer',
      'email': 'alex.johnson@techcorp.com',
      'phone': '+1 234 567 8900',
      'notes': 'Met at the AI session. Interested in collaboration on mobile projects.',
      'image': 'https://randomuser.me/api/portraits/men/1.jpg',
    },
    {
      'name': 'Sarah Williams',
      'date': 'Nov 20, 2025',
      'place': 'Startup Mixer',
      'avatar': 'SW',
      'occupation': 'Product Manager',
      'email': 'sarah.w@startup.io',
      'phone': '+1 234 567 8901',
      'notes': 'Great conversation about product strategy.',
      'image': 'https://randomuser.me/api/portraits/women/2.jpg',
    },
    {
      'name': 'Michael Chen',
      'date': 'Nov 18, 2025',
      'place': 'Coffee Shop Downtown',
      'avatar': 'MC',
      'occupation': 'UX Designer',
      'email': 'michael@design.co',
      'phone': '+1 234 567 8902',
      'image': 'https://randomuser.me/api/portraits/men/3.jpg',
    },
    {
      'name': 'Emily Rodriguez',
      'date': 'Nov 15, 2025',
      'place': 'LinkedIn Networking Event',
      'avatar': 'ER',
      'occupation': 'Marketing Director',
      'email': 'emily.r@marketing.com',
      'phone': '+1 234 567 8903',
      'notes': 'Looking for partnerships in Q1 2026.',
      'image': 'https://randomuser.me/api/portraits/women/4.jpg',
    },
    {
      'name': 'David Kim',
      'date': 'Nov 10, 2025',
      'place': 'Business Lunch',
      'avatar': 'DK',
      'occupation': 'Sales Executive',
      'email': 'david.kim@sales.com',
      'phone': '+1 234 567 8904',
      'image': 'https://randomuser.me/api/portraits/men/5.jpg',
    },
    {
      'name': 'Jessica Brown',
      'date': 'Nov 5, 2025',
      'place': 'Design Workshop',
      'avatar': 'JB',
      'occupation': 'Creative Director',
      'email': 'jessica@creative.agency',
      'phone': '+1 234 567 8905',
      'notes': 'Really talented designer. Follow up about the branding project.',
      'image': 'https://randomuser.me/api/portraits/women/6.jpg',
    },
  ];

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
        title: const Text(
          'Timeline',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
            child: TextField(
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
            child: _connections.isEmpty
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
                    itemCount: _connections.length,
                    itemBuilder: (context, index) {
                      final connection = _connections[index];
                      
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
                            backgroundImage: connection['image'] != null 
                                ? NetworkImage(connection['image']!)
                                : null,
                            child: connection['image'] == null
                                ? Text(
                                    connection['avatar']!,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  )
                                : null,
                          ),
                          title: Text(
                            connection['name']!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today,
                                    size: 14,
                                    color: Colors.grey[500],
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    connection['date']!,
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
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
                                      connection['place']!,
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
                                builder: (context) => ContactDetailScreen(
                                  name: connection['name']!,
                                  avatar: connection['avatar']!,
                                  date: connection['date']!,
                                  place: connection['place']!,
                                  occupation: connection['occupation'],
                                  email: connection['email'],
                                  phone: connection['phone'],
                                  notes: connection['notes'],
                                  imageUrl: connection['image'],
                                ),
                              ),
                            );
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
