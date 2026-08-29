import 'package:flutter_test/flutter_test.dart';
import 'package:field_officer_app/data/models/field_visit_model.dart';
import 'package:field_officer_app/data/models/inspection_model.dart';
import 'package:field_officer_app/data/models/evidence_model.dart';
import 'package:field_officer_app/data/models/document_model.dart';

void main() {
  group('Field Visit Model & Inspection Validation', () {
    test('FieldVisitModel initializes with complete sub-entities', () {
      final inspection = InspectionModel(
        visitId: 'VST-TEST-001',
        parcelMatchesRecord: 'YES',
        boundaryIdentified: 'YES',
        boundaryMarkersAvailable: 'YES',
        boundaryMatchesCadastral: 'YES',
        landUseVerified: 'YES',
        physicalConditionVerified: 'YES',
        encroachmentChecked: 'YES',
        ownershipChecked: 'YES',
        documentsReviewed: 'YES',
        objectionReceived: 'NO',
        disputeObserved: 'NO',
        encroachmentObserved: 'NO',
        otherIssues: 'NO',
        remarks: 'All ground boundaries verified.',
      );

      final evidence = EvidenceModel(
        photoId: 'PHO-001',
        visitId: 'VST-TEST-001',
        parcelId: 'PUN-1024',
        officerId: 'FO-MH-PUN-0842',
        timestamp: DateTime.now(),
        latitude: 18.498214,
        longitude: 73.746820,
        gpsAccuracy: 3.8,
        category: 'Parcel Boundary',
        description: 'Corner stone marker #1',
        localFilePath: '/storage/emulated/0/evidence.jpg',
      );

      final doc = DocumentModel(
        documentId: 'DOC-001',
        visitId: 'VST-TEST-001',
        parcelId: 'PUN-1024',
        fileName: '7_12_extract.pdf',
        fileType: 'PDF',
        fileSizeBytes: 102400,
        localFilePath: '/storage/emulated/0/7_12.pdf',
      );

      final visit = FieldVisitModel(
        visitId: 'VST-TEST-001',
        taskId: 'TSK-1024',
        parcelId: 'PUN-1024',
        officerId: 'FO-MH-PUN-0842',
        startTime: '2026-08-29T10:00:00Z',
        latitude: 18.498214,
        longitude: 73.746820,
        gpsAccuracy: 3.8,
        status: 'IN_PROGRESS',
        inspection: inspection,
        evidence: [evidence],
        documents: [doc],
      );

      expect(visit.inspection?.isComplete(), true);
      expect(visit.evidence.length, 1);
      expect(visit.documents.length, 1);
      expect(visit.documents.first.formattedSize, '100.0 KB');

      final json = visit.toJson();
      final fromJson = FieldVisitModel.fromJson(json);

      expect(fromJson.visitId, 'VST-TEST-001');
      expect(fromJson.evidence.first.category, 'Parcel Boundary');
      expect(fromJson.documents.first.fileName, '7_12_extract.pdf');
    });

    test('InspectionModel validation verifies required fields', () {
      final validInspection = InspectionModel(
        visitId: 'VST-1',
        parcelMatchesRecord: 'YES',
        boundaryIdentified: 'YES',
        boundaryMatchesCadastral: 'YES',
        landUseVerified: 'YES',
        ownershipChecked: 'YES',
      );
      expect(validInspection.isComplete(), true);

      final invalidInspection = InspectionModel(
        visitId: 'VST-1',
        parcelMatchesRecord: '',
        boundaryIdentified: 'YES',
      );
      expect(invalidInspection.isComplete(), false);
    });
  });
}
