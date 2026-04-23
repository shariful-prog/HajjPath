import 'package:geocoding/geocoding.dart';
import 'package:flutter/foundation.dart';
import 'package:latlong2/latlong.dart';

bool isValidLatLng(double? lat, double? lng) {
  if (lat == null || lng == null) return false;
  if (!lat.isFinite || !lng.isFinite) return false;
  if (lat < -90 || lat > 90) return false;
  if (lng < -180 || lng > 180) return false;
  // Filter out 0,0 which is often a GPS glitch
  if (lat == 0.0 && lng == 0.0) return false;
  return true;
}

LatLng safeLatLng(double? lat, double? lng) {
  if (isValidLatLng(lat, lng)) {
    return LatLng(lat!, lng!);
  }
  // Default fallback: Mecca (safe constant)
  return const LatLng(21.4225, 39.8262);
}

Future<String> getAddressFromLatLng(double lat, double lng) async {
  if (!lat.isFinite || !lng.isFinite) return 'Invalid Location';
  try {
    List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
    if (placemarks.isNotEmpty) {
      Placemark place = placemarks[0];
      // Construct address string: Street, City, Country
      final components = [
        place.street,
        place.subLocality,
        place.locality,
        place.country
      ].where((s) => s != null && s.isNotEmpty).toList();
      
      return components.join(', ');
    }
  } catch (e) {
    debugPrint('Geocoding error: $e');
  }
  return 'Unknown Location';
}

