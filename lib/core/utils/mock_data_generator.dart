import 'dart:math';
import '../../data/models/contact.dart';
import '../../data/repositories/contact_repository.dart';

class MockDataGenerator {
  static final Random _random = Random();

  static Future<void> generateMockContacts(ContactRepository repo) async {
    final List<Map<String, dynamic>> mockData = [
      {
        "name": "Sarah Chen",
        "title": "Head of Product",
        "company": "TechFlow",
        "notes": "Expert in PLG. Met at the AI summit. Loves hiking.",
        "city": "San Francisco, CA",
        "lat": 37.7749, "lng": -122.4194,
        "event": "AI Summit 2024"
      },
      {
        "name": "David Miller",
        "title": "General Partner",
        "company": "High Altitude Ventures",
        "notes": "Looking for Seed stage B2B SaaS. Big skier.",
        "city": "Denver, CO",
        "lat": 39.7392, "lng": -104.9903,
        "event": "Denver Startup Week"
      },
      {
        "name": "Elena Rodriguez",
        "title": "CTO",
        "company": "FinScale",
        "notes": "Building next-gen payments. Needs introductions to bank partners.",
        "city": "New York, NY",
        "lat": 40.7128, "lng": -74.0060,
        "event": "Fintech Mixer"
      },
      {
        "name": "James Wilson",
        "title": "Angel Investor",
        "company": "Self-Employed",
        "notes": "Invests in deep tech and climate. Former founder of GreenEnergy.",
        "city": "Austin, TX",
        "lat": 30.2672, "lng": -97.7431,
        "event": "SXSW"
      },
      {
        "name": "Priya Patel",
        "title": "Senior Engineer",
        "company": "CloudSystems",
        "notes": "Expert in Kubernetes and distributed systems. Hiring engineers.",
        "city": "Seattle, WA",
        "lat": 47.6062, "lng": -122.3321,
        "event": "CloudConf"
      },
      {
        "name": "Marcus Johnson",
        "title": "Director of Sales",
        "company": "GrowthRocket",
        "notes": "Can help with enterprise sales strategy. Met at the coffee shop.",
        "city": "Chicago, IL",
        "lat": 41.8781, "lng": -87.6298,
        "event": "Coffee Connect"
      },
      {
        "name": "Olivia Kim",
        "title": "UX Designer",
        "company": "PixelPerfect",
        "notes": "Amazing portfolio. Interested in freelance work.",
        "city": "Los Angeles, CA",
        "lat": 34.0522, "lng": -118.2437,
        "event": "Design Week"
      },
      {
        "name": "Tom Baker",
        "title": "Founder",
        "company": "EduTech",
        "notes": "Raising Series A. Needs intro to education VCs.",
        "city": "Boston, MA",
        "lat": 42.3601, "lng": -71.0589,
        "event": "EdTech Forum"
      },
      {
        "name": "Sofia Garcia",
        "title": "Marketing Lead",
        "company": "BrandNew",
        "notes": "Specializes in viral growth loops. Met at the beach mixer.",
        "city": "Miami, FL",
        "lat": 25.7617, "lng": -80.1918,
        "event": "Miami Tech Week"
      },
      {
        "name": "Robert Chang",
        "title": "Data Scientist",
        "company": "DataCorp",
        "notes": "Building LLM agents. Wants to collaborate on open source.",
        "city": "San Jose, CA",
        "lat": 37.3382, "lng": -121.8863,
        "event": "Hacker House Party"
      },
      {
        "name": "Alice White",
        "title": "Recruiter",
        "company": "TalentHunt",
        "notes": "Specializes in executive hiring for startups.",
        "city": "Atlanta, GA",
        "lat": 33.7490, "lng": -84.3880,
        "event": "HR Tech"
      },
      {
        "name": "Bill Gates (Mock)",
        "title": "Philanthropist",
        "company": "Foundation",
        "notes": "Met briefly. Discussed climate change and nuclear energy.",
        "city": "Seattle, WA",
        "lat": 47.6062, "lng": -122.3321,
        "event": "Climate Summit"
      },
      {
        "name": "Nancy Wu",
        "title": "Researcher",
        "company": "BioLife",
        "notes": "Working on longevity research. Very smart.",
        "city": "San Diego, CA",
        "lat": 32.7157, "lng": -117.1611,
        "event": "BioTech Conference"
      },
      {
        "name": "Kevin O'Leary (Mock)",
        "title": "Investor",
        "company": "Shark Tank",
        "notes": "loves money. looking for royalty deals.",
        "city": "Boston, MA",
        "lat": 42.3601, "lng": -71.0589,
        "event": "Investment Gala"
      },
      {
        "name": "Linda Park",
        "title": "COO",
        "company": "LogisticsCo",
        "notes": "Operations expert. scaling teams from 10 to 100.",
        "city": "Portland, OR",
        "lat": 45.5152, "lng": -122.6784,
        "event": "Ops Summit"
      }
    ];

    print("🌱 Seeding ${mockData.length} contacts...");

    for (var data in mockData) {
      // Random date in last 6 months
      final daysAgo = _random.nextInt(180); 
      final metAt = DateTime.now().subtract(Duration(days: daysAgo));

      final contact = Contact(
        name: data['name'],
        title: data['title'],
        company: data['company'],
        notes: data['notes'],
        addressLabel: data['city'],
        latitude: data['lat'],
        longitude: data['lng'],
        eventName: data['event'],
        metAt: metAt,
        email: "${data['name'].toString().split(' ')[0].toLowerCase()}@example.com",
      );

      // This will automatically generate the embedding!
      await repo.saveContact(contact);
      print("   Saved ${contact.name}");
    }
    print("✅ Seeding Complete!");
  }
}