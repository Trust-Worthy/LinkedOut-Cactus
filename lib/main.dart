import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Services
import 'services/location/offline_geocoding_service.dart';
import 'services/search/vector_search_service.dart';
import 'services/ai/cactus_service.dart';
import 'services/search/smart_search_service.dart'; // ADD THIS IMPORT
import 'services/search/advanced_search_service.dart'; // ADD THIS
// Data & App
import 'app.dart';
import 'data/local/database/isar_service.dart';
import 'data/repositories/contact_repository.dart';

void main() async {
  // 1. Essential binding for native calls
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Initialize Isar (Contacts Database)
  final isarService = IsarService();
  
  // 3. Initialize Offline Geocoding (SQLite)
  // This line is critical: It copies assets/geonames.db to the device's
  // file system so SQLite can read/query it efficiently.
  await OfflineGeocodingService.instance.initialize();
  
  // 4. Check Onboarding State
  final prefs = await SharedPreferences.getInstance();
  final hasOnboarded = prefs.getBool('has_onboarded') ?? false;

  runApp(
    MultiProvider(
      providers: [
        Provider<ContactRepository>(create: (_) => ContactRepository(isarService)),
        
        // REPLACING SmartSearchService with AdvancedSearchService
        Provider<AdvancedSearchService>(
          create: (context) => AdvancedSearchService(
            context.read<ContactRepository>(),
            CactusService.instance,
          ),
        ),
        // ... other providers ...
      ],
      child: LinkedOutApp(startOnboarding: !hasOnboarded),
    ),
  );
}