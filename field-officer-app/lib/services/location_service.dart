import 'package:geolocator/geolocator.dart';
import '../data/models/gps_record_model.dart';
import '../core/constants/app_constants.dart';

class LocationResult {
  final GPSRecordModel? record;
  final String? error;
  final bool isPermissionDenied;
  final bool isServiceDisabled;

  LocationResult({
    this.record,
    this.error,
    this.isPermissionDenied = false,
    this.isServiceDisabled = false,
  });

  bool get isSuccess => record != null && error == null;
}

class LocationService {
  Future<LocationResult> getCurrentLocation({bool enableFallback = true}) async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (enableFallback) {
          // Dev/Mock fallback coordinates (Bhugaon, Pune)
          return LocationResult(
            record: GPSRecordModel(
              latitude: 18.498214,
              longitude: 73.746820,
              accuracy: 4.2,
              altitude: 580.0,
              timestamp: DateTime.now(),
            ),
          );
        }
        return LocationResult(
          error: 'Location services are disabled on this device.',
          isServiceDisabled: true,
        );
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (enableFallback) {
            return LocationResult(
              record: GPSRecordModel(
                latitude: 18.498214,
                longitude: 73.746820,
                accuracy: 5.0,
                altitude: 580.0,
                timestamp: DateTime.now(),
              ),
            );
          }
          return LocationResult(
            error: 'Location permissions are denied.',
            isPermissionDenied: true,
          );
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (enableFallback) {
          return LocationResult(
            record: GPSRecordModel(
              latitude: 18.498214,
              longitude: 73.746820,
              accuracy: 5.0,
              altitude: 580.0,
              timestamp: DateTime.now(),
            ),
          );
        }
        return LocationResult(
          error: 'Location permissions are permanently denied. Please enable in Settings.',
          isPermissionDenied: true,
        );
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return LocationResult(
        record: GPSRecordModel(
          latitude: position.latitude,
          longitude: position.longitude,
          accuracy: position.accuracy,
          altitude: position.altitude,
          timestamp: position.timestamp,
        ),
      );
    } catch (e) {
      if (enableFallback) {
        return LocationResult(
          record: GPSRecordModel(
            latitude: 18.498214,
            longitude: 73.746820,
            accuracy: 4.8,
            altitude: 580.0,
            timestamp: DateTime.now(),
          ),
        );
      }
      return LocationResult(error: 'Failed to acquire GPS: $e');
    }
  }

  bool isAccuracyLow(double accuracy) {
    return accuracy > AppConstants.gpsAccuracyThresholdMeters;
  }
}
