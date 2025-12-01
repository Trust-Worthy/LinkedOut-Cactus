import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Services
import 'services/location/offline_geocoding_service.dart';
import 'services/search/vector_search_service.dart';
import 'services/ai/cactus_service.dart';
import 'services/auth/auth_provider.dart';
// Data & App
import 'app.dart';
import 'data/local/database/isar_service.dart';
import 'data/repositories/contact_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final isarService = IsarService();
  await OfflineGeocodingService.instance.initialize();

  runApp(
    MultiProvider(
      providers: [
        // Auth Provider - Must be first to initialize before other services
        ChangeNotifierProvider(
          create: (_) => AuthProvider()..initialize(),
        ),
        
        Provider<ContactRepository>(create: (_) => ContactRepository(isarService)),
        
        // USE PURE VECTOR SEARCH
        Provider<VectorSearchService>(
          create: (context) => VectorSearchService(
            context.read<ContactRepository>(),
            CactusService.instance,
          ),
        ),
      ],
      child: const LinkedOutApp(),
    ),
  );
}

// void main() async {
//   // 1. Essential binding for native calls
//   WidgetsFlutterBinding.ensureInitialized();

//   // 2. Initialize Isar (Contacts Database)
//   final isarService = IsarService();
  
//   // 3. Initialize Offline Geocoding (SQLite)
//   // This line is critical: It copies assets/geonames.db to the device's
//   // file system so SQLite can read/query it efficiently.
//   await OfflineGeocodingService.instance.initialize();
  
//   // 4. Check Onboarding State
//   final prefs = await SharedPreferences.getInstance();
//   final hasOnboarded = prefs.getBool('has_onboarded') ?? false;

//   runApp(
//     MultiProvider(
//       providers: [
//         Provider<ContactRepository>(create: (_) => ContactRepository(isarService)),
        
//         // REPLACING SmartSearchService with AdvancedSearchService
//         Provider<AdvancedSearchService>(
//           create: (context) => AdvancedSearchService(
//             context.read<ContactRepository>(),
//             CactusService.instance,
//           ),
//         ),
//         // ... other providers ...
//       ],
//       child: LinkedOutApp(startOnboarding: !hasOnboarded),
//     ),
//   );
// }