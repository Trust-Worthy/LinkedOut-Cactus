import 'package:isar/isar.dart';

part 'contact.g.dart';

@collection
class Contact {
  Id id = Isar.autoIncrement;

  // --- Identity Flag ---
  // If true, this is the User's own profile
  bool isMe; 

  // --- Basic Info ---
  @Index(type: IndexType.value, caseSensitive: false)
  late String name;
  
  String? company;
  String? title;
  String? email;
  String? phone;
  
  // --- Socials ---
  String? linkedin;
  String? instagram;
  String? twitter;
  
  // --- Contextual Data ---
  String? notes;
  List<String>? tags;
  
  // --- Spatial Data ---
  double? latitude;
  double? longitude;
  String? addressLabel;
  
  // --- Temporal Data ---
  late DateTime metAt;
  late DateTime lastInteractedAt;
  
  // --- Event Mode ---
  String? eventName;
  bool isEventMode;

  // --- Follow Up ---
  DateTime? followUpScheduledFor;
  bool isFollowUpCompleted;

  // --- AI Semantic Data ---
  List<double>? embedding;

  // --- Metadata ---
  String? rawScannedText; 

  Contact({
    required this.name,
    required this.metAt,
    this.isMe = false, // <--- FIX: Added this to constructor
    this.company,
    this.title,
    this.email,
    this.phone,
    this.linkedin,
    this.instagram,
    this.twitter,
    this.notes,
    this.tags,
    this.latitude,
    this.longitude,
    this.addressLabel,
    this.eventName,
    this.isEventMode = false,
    this.followUpScheduledFor,
    this.isFollowUpCompleted = false,
    this.embedding,
    this.rawScannedText,
  }) : lastInteractedAt = DateTime.now();
}