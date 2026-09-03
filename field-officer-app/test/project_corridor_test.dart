import 'package:flutter_test/flutter_test.dart';
import 'package:field_officer_app/data/models/project_corridor_model.dart';
import 'package:field_officer_app/data/datasources/mock/project_corridor_demo_data.dart';
import 'package:field_officer_app/data/repositories/project_corridor_repository.dart';

void main() {
  group('Project Corridor Domain & Progress Calculations', () {
    test('Pune Ring Road Corridor metrics and dynamic progress percentage', () {
      final ringRoad = ProjectCorridorDemoData.puneRingRoadCorridor;

      expect(ringRoad.name, 'Pune Ring Road Express Corridor (Phase-I)');
      expect(ringRoad.type, 'Highway');
      expect(ringRoad.totalLandRequired, 485.50);
      expect(ringRoad.acquiredLand, 289.28);
      expect(ringRoad.inProgressLand, 96.20);
      expect(ringRoad.pendingLand, 100.02);
      expect(ringRoad.totalParcels, 18);
      expect(ringRoad.acquiredParcels, 10);
      expect(ringRoad.inProgressParcels, 4);
      expect(ringRoad.pendingParcels, 4);
      expect(ringRoad.status, 'Ongoing');

      // Dynamic acquisition progress: (289.28 / 485.5) * 100 = 59.58% -> 59.6%
      expect(ringRoad.acquisitionProgressPercentage, closeTo(59.5839, 0.001));
      expect(ringRoad.formattedAcquisitionProgress, '59.6%');

      // Dynamic parcel completion: (10 / 18) * 100 = 55.56% -> 55.6%
      expect(ringRoad.parcelCompletionPercentage, closeTo(55.5555, 0.001));
      expect(ringRoad.formattedParcelCompletion, '55.6%');

      // Check segments and parcels
      expect(ringRoad.segments.length, 4);
      expect(ringRoad.parcels.length, 18);
    });

    test('Pune-Nashik Rail Corridor metrics and dynamic progress percentage', () {
      final railCorridor = ProjectCorridorDemoData.puneNashikRailCorridor;

      expect(railCorridor.name, 'Pune-Nashik Semi-High Speed Rail Corridor');
      expect(railCorridor.type, 'Railway');
      expect(railCorridor.totalLandRequired, 720.0);
      expect(railCorridor.acquiredLand, 430.0);
      expect(railCorridor.inProgressLand, 140.0);
      expect(railCorridor.pendingLand, 150.0);
      expect(railCorridor.totalParcels, 24);
      expect(railCorridor.acquiredParcels, 14);
      expect(railCorridor.inProgressParcels, 5);
      expect(railCorridor.pendingParcels, 5);
      expect(railCorridor.status, 'Ongoing');

      // Dynamic acquisition progress: (430.0 / 720.0) * 100 = 59.72% -> 59.7%
      expect(railCorridor.acquisitionProgressPercentage, closeTo(59.7222, 0.001));
      expect(railCorridor.formattedAcquisitionProgress, '59.7%');

      // Dynamic parcel completion: (14 / 24) * 100 = 58.33% -> 58.3%
      expect(railCorridor.parcelCompletionPercentage, closeTo(58.3333, 0.001));
      expect(railCorridor.formattedParcelCompletion, '58.3%');

      expect(railCorridor.segments.length, 4);
      expect(railCorridor.parcels.length, 24);
    });

    test('AcquisitionStatus enum string mapping and color definitions', () {
      expect(AcquisitionStatus.fromString('ACQUIRED'), AcquisitionStatus.acquired);
      expect(AcquisitionStatus.fromString('VERIFIED'), AcquisitionStatus.acquired);
      expect(AcquisitionStatus.fromString('IN_PROGRESS'), AcquisitionStatus.inProgress);
      expect(AcquisitionStatus.fromString('PENDING'), AcquisitionStatus.pending);

      expect(AcquisitionStatus.acquired.label, 'Acquired');
      expect(AcquisitionStatus.inProgress.label, 'In Progress');
      expect(AcquisitionStatus.pending.label, 'Pending');
    });

    test('DemoProjectCorridorRepository retrieves both corridors offline', () async {
      final repo = DemoProjectCorridorRepository();
      final corridors = await repo.getCorridors();

      expect(corridors.length, 2);
      expect(corridors.any((c) => c.id == 'PRJ-MH-PUN-001'), isTrue);
      expect(corridors.any((c) => c.id == 'PRJ-MH-PUN-002'), isTrue);

      final single = await repo.getCorridorById('PRJ-MH-PUN-001');
      expect(single, isNotNull);
      expect(single!.name, 'Pune Ring Road Express Corridor (Phase-I)');
    });

    test('ProjectCorridorModel JSON serialization roundtrip for future API compatibility', () {
      final original = ProjectCorridorDemoData.puneRingRoadCorridor;
      final json = original.toJson();
      final recreated = ProjectCorridorModel.fromJson(json);

      expect(recreated.id, original.id);
      expect(recreated.name, original.name);
      expect(recreated.type, original.type);
      expect(recreated.totalLandRequired, original.totalLandRequired);
      expect(recreated.acquiredLand, original.acquiredLand);
      expect(recreated.inProgressLand, original.inProgressLand);
      expect(recreated.pendingLand, original.pendingLand);
      expect(recreated.totalParcels, original.totalParcels);
      expect(recreated.acquiredParcels, original.acquiredParcels);
      expect(recreated.formattedAcquisitionProgress, original.formattedAcquisitionProgress);
    });
  });
}
