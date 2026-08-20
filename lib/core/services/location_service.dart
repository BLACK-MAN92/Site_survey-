import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  // Returns true if permission is granted
  Future<bool> requestPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  Future<bool> hasPermission() async {
    return await Permission.location.isGranted;
  }

  Future<Position?> getCurrentPosition() async {
    if (!await hasPermission()) return null;

    // According to PRD, we require accuracy <= 50m. We use high accuracy.
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  bool isMocked(Position position) {
    return position.isMocked;
  }

  bool isWithinGeofence({
    required double targetLat,
    required double targetLng,
    required double currentLat,
    required double currentLng,
    double radiusMeters = 200.0,
  }) {
    final distance = Geolocator.distanceBetween(
      targetLat,
      targetLng,
      currentLat,
      currentLng,
    );
    return distance <= radiusMeters;
  }
}
