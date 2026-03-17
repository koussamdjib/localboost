import 'dart:math';

import 'package:latlong2/latlong.dart';

/// Calculate distance between two GPS coordinates using Haversine formula
class GpsDistanceCalculator {
  /// Calculate distance in kilometers between two points
  static double calculateDistance(LatLng point1, LatLng point2) {
    const double earthRadius = 6371; // Earth's radius in kilometers

    final lat1Rad = _toRadians(point1.latitude);
    final lat2Rad = _toRadians(point2.latitude);
    final deltaLat = _toRadians(point2.latitude - point1.latitude);
    final deltaLon = _toRadians(point2.longitude - point1.longitude);

    final a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(deltaLon / 2) * sin(deltaLon / 2);

    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  static double _toRadians(double degrees) {
    return degrees * pi / 180;
  }
}
