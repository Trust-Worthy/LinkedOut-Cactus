import 'dart:math';
import 'package:flutter/services.dart' show rootBundle;

class City {
  final String name;
  final String country;
  final double lat;
  final double lng;

  City({required this.name, required this.country, required this.lat, required this.lng});
}

class OfflineGeocodingService {
  // Singleton
  static final OfflineGeocodingService _instance = OfflineGeocodingService._internal();
  factory OfflineGeocodingService() => _instance;
  OfflineGeocodingService._internal();
  static OfflineGeocodingService get instance => _instance;

  List<City> _cities = [];
  bool _isLoaded = false;

  /// Load the CSV into memory (Call this in main.dart)
  Future<void> initialize() async {
    if (_isLoaded) return;
    
    try {
      final data = await rootBundle.loadString('assets/cities.csv');
      final lines = data.split('\n');
      
      // Skip header row
      for (var i = 1; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty) continue;
        
        final parts = line.split(',');
        if (parts.length >= 4) {
          _cities.add(City(
            name: parts[0],
            country: parts[1],
            lat: double.parse(parts[2]),
            lng: double.parse(parts[3]),
          ));
        }
      }
      _isLoaded = true;
      print("Offline Geocoding: Loaded ${_cities.length} cities.");
    } catch (e) {
      print("Error loading cities CSV: $e");
    }
  }

  /// Find the nearest city to the given coordinates
  String? getCityName(double lat, double lng) {
    if (_cities.isEmpty) return null;

    City? nearestCity;
    double minDistance = double.infinity;

    for (final city in _cities) {
      final dist = _calculateDistance(lat, lng, city.lat, city.lng);
      if (dist < minDistance) {
        minDistance = dist;
        nearestCity = city;
      }
    }

    if (nearestCity != null) {
      // If nearest city is > 50km away, maybe just return generic country or "Unknown"
      // But for hackathon, let's just return the nearest match.
      return "${nearestCity.name}, ${nearestCity.country}";
    }
    return null;
  }

  // Haversine formula for distance
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const p = 0.017453292519943295; // Math.PI / 180
    final a = 0.5 - cos((lat2 - lat1) * p) / 2 +
        cos(lat1 * p) * cos(lat2 * p) * (1 - cos((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a)); // 2 * R; R = 6371 km
  }
}