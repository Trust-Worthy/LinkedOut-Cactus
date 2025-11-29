import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Service Imports
import 'services/location/offline_geocoding_service.dart';
import 'services/search/vector_search_service.dart';
import 'services/ai/cactus_service.dart';

// App Structure Imports
import 'app.dart';
import 'data/local/database/isar_service.dart';
import 'data/repositories/contact_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Database
  final isarService = IsarService();
  
  // 2. Preload Offline Maps Data
  await OfflineGeocodingService.instance.initialize();
  
  // 3. Check Onboarding State
  final prefs = await SharedPreferences.getInstance();
  final hasOnboarded = prefs.getBool('has_onboarded') ?? false;

  runApp(
    MultiProvider(
      providers: [
        // Repository
        Provider<ContactRepository>(
          create: (_) => ContactRepository(isarService),
        ),
        
        // Search Service (Requires Repo + AI Service)
        Provider<VectorSearchService>(
          create: (context) => VectorSearchService(
            context.read<ContactRepository>(),
            CactusService.instance,
          ),
        ),
      ],
      child: LinkedOutApp(startOnboarding: !hasOnboarded),
    ),
  );
}