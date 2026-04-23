import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      locationSettings: AndroidSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      ),
    );
  }

  Future<Map<String, String>> getAddressFromCoordinates(double lat, double long) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, long);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String country = place.country ?? 'Unknown';
        
        String address = '';
        if (place.name != null && place.name!.isNotEmpty) address += '${place.name}, ';
        if (place.subLocality != null && place.subLocality!.isNotEmpty) address += '${place.subLocality}, ';
        if (place.locality != null && place.locality!.isNotEmpty) address += place.locality!;
        
        return {
          'country': country,
          'address': address.isEmpty ? 'Unknown Address' : address,
        };
      }
    } catch (e) {
      debugPrint('Geocoding Error at ($lat, $long): $e');
    }
    return {
      'country': 'Unknown',
      'address': 'Unknown Address',
    };
  }

  double calculateDistance(double startLat, double startLong, double endLat, double endLong) {
    return Geolocator.distanceBetween(startLat, startLong, endLat, endLong);
  }

  Future<String> getCurrentAddress() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return 'Location services are disabled.';

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return 'Location permissions are denied';
      }

      if (permission == LocationPermission.deniedForever) return 'Location permissions are permanently denied';

      Position position = await getCurrentPosition();
      final data = await getAddressFromCoordinates(position.latitude, position.longitude);
      return data['address']!;
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }
}
