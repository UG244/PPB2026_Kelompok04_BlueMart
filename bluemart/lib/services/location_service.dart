import 'package:geolocator/geolocator.dart';
import '../models/supplier.dart';

class LocationService {
  Future<Position?> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );
    } catch (e) {
      return null;
    }
  }

  double calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  double calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    return Geolocator.bearingBetween(lat1, lon1, lat2, lon2);
  }

  Supplier? findNearestSupplier(double userLat, double userLng) {
    Supplier? nearest;
    double minDistance = double.infinity;

    for (final supplier in Supplier.sampleSuppliers) {
      final distance = calculateDistance(
        userLat, userLng,
        supplier.latitude, supplier.longitude,
      );
      if (distance < minDistance) {
        minDistance = distance;
        nearest = supplier;
      }
    }
    return nearest;
  }
}