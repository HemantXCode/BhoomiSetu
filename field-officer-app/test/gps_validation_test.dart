import 'package:flutter_test/flutter_test.dart';
import 'package:field_officer_app/core/utils/geo_utils.dart';
import 'package:field_officer_app/data/models/gps_record_model.dart';

void main() {
  group('GeoUtils & GPS Validation Tests', () {
    test('Calculates accurate Haversine distance between two coordinates', () {
      // Bhugaon (18.498214, 73.746820) to nearby point ~100m away
      final distance = GeoUtils.calculateDistance(18.498214, 73.746820, 18.498300, 73.746900);

      expect(distance, greaterThan(0));
      expect(distance, lessThan(50)); // ~13m away
    });

    test('Validates expected range proximity threshold (< 50m)', () {
      expect(GeoUtils.isWithinExpectedRange(24.5), true);
      expect(GeoUtils.isWithinExpectedRange(49.9), true);
      expect(GeoUtils.isWithinExpectedRange(50.1), false);
      expect(GeoUtils.isWithinExpectedRange(120.0), false);
    });

    test('Validates GPS accuracy reliability threshold (<= 15m)', () {
      expect(GeoUtils.isAccuracyAcceptable(4.2), true);
      expect(GeoUtils.isAccuracyAcceptable(14.9), true);
      expect(GeoUtils.isAccuracyAcceptable(15.0), true);
      expect(GeoUtils.isAccuracyAcceptable(15.1), false);
      expect(GeoUtils.isAccuracyAcceptable(35.0), false);
      expect(GeoUtils.isAccuracyAcceptable(null), false);
    });

    test('GPSRecordModel serialization handles precision correctly', () {
      final now = DateTime.now();
      final record = GPSRecordModel(
        latitude: 18.498214,
        longitude: 73.746820,
        accuracy: 3.5,
        altitude: 580.2,
        timestamp: now,
      );

      final json = record.toJson();
      final deserialized = GPSRecordModel.fromJson(json);

      expect(deserialized.latitude, 18.498214);
      expect(deserialized.longitude, 73.746820);
      expect(deserialized.accuracy, 3.5);
      expect(deserialized.altitude, 580.2);
    });
  });
}
