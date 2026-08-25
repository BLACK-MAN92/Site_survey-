import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../presentation/providers/geo_fix.dart';

class LocationService {
  // Returns true if permission is granted
  Future<bool> requestPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  Future<bool> hasPermission() async {
    return await Permission.location.isGranted;
  }

  /// The current fix, or null if one cannot be taken.
  ///
  /// Every failure mode is folded into null on purpose. A survey screen asks
  /// for location while the engineer is filling the form, and a thrown
  /// permission or platform error there would take down the whole flow over
  /// something the submit step already checks for and reports properly.
  Future<Position?> getCurrentPosition() async {
    try {
      // Asking only when it is missing keeps the OS prompt off the screen on
      // every capture, while still recovering if the engineer declined earlier.
      if (!await hasPermission() && !await requestPermission()) return null;

      if (!await Geolocator.isLocationServiceEnabled()) return null;

      // According to PRD, we require accuracy <= 50m. We use high accuracy.
      try {
        return await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 20),
        );
      } catch (_) {
        // A timeout indoors or under canopy is normal. Fall back to the last
        // known fix rather than blocking the survey outright.
        return await Geolocator.getLastKnownPosition();
      }
    } catch (_) {
      return null;
    }
  }

  /// A reading in the shape the survey API expects, or null if none could be
  /// taken. A 0,0 fix is treated as no fix, because that is what a failed
  /// lookup degrades to and the API rejects it anyway.
  Future<GeoFix?> currentFix() async {
    final position = await getCurrentPosition();
    if (position == null) return null;

    final fix = GeoFix(
      lat: position.latitude,
      lng: position.longitude,
      accuracyM: position.accuracy,
      altitude: position.altitude,
      provider: 'gps',
      mocked: position.isMocked,
      capturedAt: position.timestamp,
    );

    return fix.isUsable ? fix : null;
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
