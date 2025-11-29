class EventModel {
  final String name;
  final String date;
  final String location;
  final String description;
  final String organizer;
  final String website;

  EventModel({
    required this.name,
    required this.date,
    required this.location,
    required this.description,
    required this.organizer,
    required this.website,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'date': date,
        'location': location,
        'description': description,
        'organizer': organizer,
        'website': website,
      };

  factory EventModel.fromJson(Map<String, dynamic> j) => EventModel(
        name: j['name'] ?? '',
        date: j['date'] ?? '',
        location: j['location'] ?? '',
        description: j['description'] ?? '',
        organizer: j['organizer'] ?? '',
        website: j['website'] ?? '',
      );
}
