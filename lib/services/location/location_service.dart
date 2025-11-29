import 'package:geolocator/geolocator.dart';
import 'offline_geocoding_service.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();
  static LocationService get instance => _instance;

  /// Gets current position
  Future<Position?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) return null;
    }
    
    if (permission == LocationPermission.deniedForever) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// PURE OFFLINE REVERSE GEOCODING
  Future<String?> getAddressLabel(double lat, double lng) async {
    // 1. Ensure our offline DB is loaded
    await OfflineGeocodingService.instance.initialize();
    
    // 2. Lookup nearest city
    return OfflineGeocodingService.instance.getCityName(lat, lng);
  }
}