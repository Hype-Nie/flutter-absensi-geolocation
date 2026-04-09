import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../core/utils/logger.dart';

class LocationService {
  // Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  // Check location permission
  Future<LocationPermission> checkPermission() async {
    return await Geolocator.checkPermission();
  }

  // Request location permission
  Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  // Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        AppLogger.warning('Location services are disabled.');
        return null;
      }

      // Check permission
      LocationPermission permission = await checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await requestPermission();
        if (permission == LocationPermission.denied) {
          AppLogger.warning('Location permissions are denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        AppLogger.warning('Location permissions are permanently denied');
        return null;
      }

      // Get current position
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      AppLogger.error('Error getting current location', e);
      return null;
    }
  }

  // Get address from coordinates
  Future<String?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        return '${place.street}, ${place.subLocality}, ${place.locality}, ${place.administrativeArea}, ${place.country}';
      }
      return null;
    } catch (e) {
      AppLogger.error('Error getting address from coordinates', e);
      return null;
    }
  }

  // Calculate distance between two points (in meters)
  double getDistanceBetween(
    double startLat,
    double startLon,
    double endLat,
    double endLon,
  ) {
    return Geolocator.distanceBetween(startLat, startLon, endLat, endLon);
  }

  // Check if user is within office radius
  bool isWithinOfficeRadius(
    double userLat,
    double userLon,
    double officeLat,
    double officeLon,
    double radiusInMeters,
  ) {
    double distance = getDistanceBetween(userLat, userLon, officeLat, officeLon);
    return distance <= radiusInMeters;
  }
}
