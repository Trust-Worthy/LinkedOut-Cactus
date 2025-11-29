import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class OfflineGeocodingService {
  static final OfflineGeocodingService _instance = OfflineGeocodingService._internal();
  factory OfflineGeocodingService() => _instance;
  OfflineGeocodingService._internal();
  static OfflineGeocodingService get instance => _instance;

  Database? _db;

  Future<void> initialize() async {
    if (_db != null) return;

    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "geonames.db");

    var exists = await databaseExists(path);

    if (!exists) {
      print("Creating new copy of geonames.db from asset");
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      ByteData data = await rootBundle.load(join("assets", "geonames.db"));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    }

    _db = await openDatabase(path, readOnly: true);
  }

  Future<String?> getCityName(double lat, double lng) async {
    if (_db == null) await initialize();

    double range = 0.5;

    final List<Map<String, dynamic>> maps = await _db!.query(
      'cities',
      where: 'lat BETWEEN ? AND ? AND lng BETWEEN ? AND ?',
      whereArgs: [lat - range, lat + range, lng - range, lng + range],
    );

    if (maps.isEmpty) return null;

    Map<String, dynamic>? nearest;
    double minDistance = double.infinity;

    for (var city in maps) {
      double cLat = city['lat'];
      double cLng = city['lng'];
      
      double dist = (lat - cLat) * (lat - cLat) + (lng - cLng) * (lng - cLng);
      
      if (dist < minDistance) {
        minDistance = dist;
        nearest = city;
      }
    }

    if (nearest != null) {
      return "${nearest['name']}, ${nearest['country']}";
    }
    return null;
  }

  // --- NEW: Forward Geocoding (Name -> Lat/Lng) ---
  Future<Map<String, double>?> getCoordinates(String query) async {
    if (_db == null) await initialize();

    // Clean query (remove country code if user typed "Denver, US")
    String cityName = query.split(',')[0].trim();

    // Search for city name (Case insensitive search)
    // We use LIKE to match "Denver" in "Denver"
    final List<Map<String, dynamic>> results = await _db!.query(
      'cities',
      columns: ['lat', 'lng', 'name', 'country'],
      where: 'name LIKE ? COLLATE NOCASE',
      whereArgs: [cityName], 
      limit: 1,
    );

    if (results.isNotEmpty) {
      return {
        'lat': results.first['lat'] as double,
        'lng': results.first['lng'] as double,
      };
    }
    return null;
  }
}