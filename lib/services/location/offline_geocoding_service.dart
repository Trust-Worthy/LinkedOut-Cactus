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

    // 1. Get location on device
    var databasesPath = await getDatabasesPath();
    var path = join(databasesPath, "geonames.db");

    // 2. Check if DB exists
    var exists = await databaseExists(path);

    if (!exists) {
      print("Creating new copy of geonames.db from asset");
      try {
        await Directory(dirname(path)).create(recursive: true);
      } catch (_) {}

      // 3. Copy from Asset
      ByteData data = await rootBundle.load(join("assets", "geonames.db"));
      List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
      await File(path).writeAsBytes(bytes, flush: true);
    } else {
      print("Opening existing geonames.db");
    }

    // 4. Open
    _db = await openDatabase(path, readOnly: true);
  }

  /// Find nearest city using SQL math
  /// Note: SQLite doesn't have SQRT/COS built-in by default in all versions, 
  /// so we select a "box" of candidates and refine in Dart.
  Future<String?> getCityName(double lat, double lng) async {
    if (_db == null) await initialize();

    // 1. Optimization: Only fetch cities within ~0.5 degrees (approx 50km)
    // This makes the query instant.
    double range = 0.5;

    final List<Map<String, dynamic>> maps = await _db!.query(
      'cities',
      where: 'lat BETWEEN ? AND ? AND lng BETWEEN ? AND ?',
      whereArgs: [lat - range, lat + range, lng - range, lng + range],
    );

    if (maps.isEmpty) return null;

    // 2. Find exact nearest in Dart
    Map<String, dynamic>? nearest;
    double minDistance = double.infinity;

    for (var city in maps) {
      double cLat = city['lat'];
      double cLng = city['lng'];
      
      // Simple Euclidean distance for speed (sufficient for finding nearest city)
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
}