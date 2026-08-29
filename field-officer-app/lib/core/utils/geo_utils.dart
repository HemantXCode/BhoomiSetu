import 'dart:math';
import '../constants/app_constants.dart';

class GeoUtils {
  /// Calculates great-circle distance between two points in meters using Haversine formula
  static double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusMeters = 6371000.0;
    final double dLat = _degToRad(lat2 - lat1);
    final double dLon = _degToRad(lon2 - lon1);

    final double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusMeters * c;
  }

  static double _degToRad(double deg) => deg * (pi / 180.0);

  /// Formats coordinate to standard 6-decimal precision
  static String formatCoordinate(double? coordinate) {
    if (coordinate == null) return '--';
    return coordinate.toStringAsFixed(6);
  }

  /// Formats accuracy in meters
  static String formatAccuracy(double? accuracy) {
    if (accuracy == null) return 'Unknown';
    return '±${accuracy.toStringAsFixed(1)}m';
  }

  /// Evaluates whether location is within expected range (< 50m)
  static bool isWithinExpectedRange(double distanceMeters) {
    return distanceMeters <= AppConstants.parcelProximityThresholdMeters;
  }

  /// Evaluates if accuracy meets reliable field threshold (<= 15m)
  static bool isAccuracyAcceptable(double? accuracy) {
    if (accuracy == null) return false;
    return accuracy <= AppConstants.gpsAccuracyThresholdMeters;
  }
}
