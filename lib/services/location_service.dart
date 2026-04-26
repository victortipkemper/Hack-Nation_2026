import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Initialize the location service, checking for permissions.
  static Future<void> initialize() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the 
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
        'Location permissions are permanently denied, we cannot request permissions.');
    }
  }

  /// Determine the current position of the device.
  static Future<Position> getAndStorePosition() async {
    await initialize();

    try {
      // Get current position
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      // Fallback to last known location as requested
      Position? position = await Geolocator.getLastKnownPosition();
      if (position != null) {
        return position;
      }
      return Future.error('Could not retrieve location.');
    }
  }

  /// Get a stream of position updates to regularly retrieve location.
  static Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update when the user moves 10 meters
      ),
    );
  }
}
