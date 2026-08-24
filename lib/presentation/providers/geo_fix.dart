/// A single GPS reading, in the shape the API's `geoSchema` expects.
class GeoFix {
  final double lat;
  final double lng;
  final double accuracyM;
  final double? altitude;
  final String? provider;
  final bool mocked;
  final DateTime capturedAt;

  const GeoFix({
    required this.lat,
    required this.lng,
    required this.accuracyM,
    this.altitude,
    this.provider,
    this.mocked = false,
    required this.capturedAt,
  });

  /// The API rejects a literal 0,0 as "not a valid coordinate", which is what a
  /// failed fix usually decays to.
  bool get isUsable => !(lat == 0 && lng == 0);

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'accuracyM': accuracyM,
        if (altitude != null) 'altitude': altitude,
        if (provider != null) 'provider': provider,
        'mocked': mocked,
        // z.string().datetime() requires an ISO-8601 instant in UTC.
        'capturedAt': capturedAt.toUtc().toIso8601String(),
      };
}
