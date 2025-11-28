import 'package:isar/isar.dart';

// This line allows the code generator to build the helper file
part 'contact.g.dart';

@collection
class Contact {
  Id id = Isar.autoIncrement;

  // --- Basic Info ---
  @Index(type: IndexType.value, caseSensitive: false)
  late String name;
  
  String? company;
  String? title;
  String? email;
  String? phone;
  
  // --- Contextual Data ---
  String? notes;
  List<String>? tags;
  
  // --- Spatial Data (Where you met) ---
  double? latitude;
  double? longitude;
  String? addressLabel; // e.g. "Willings House, London"
  
  // --- Temporal Data (When you met) ---
  late DateTime metAt;
  late DateTime lastInteractedAt;
  
  // --- Event Mode ---
  String? eventName; // e.g. "Cactus Hackathon"
  bool isEventMode;

  // --- AI Semantic Data ---
  // We store the vector embedding here for search
  List<double>? embedding;

  // --- Metadata ---
  // Store the raw OCR text in case we want to re-parse later
  String? rawScannedText; 

  Contact({
    required this.name,
    required this.metAt,
    this.company,
    this.title,
    this.email,
    this.phone,
    this.notes,
    this.tags,
    this.latitude,
    this.longitude,
    this.addressLabel,
    this.eventName,
    this.isEventMode = false,
    this.embedding,
    this.rawScannedText,
  }) : lastInteractedAt = DateTime.now();
}