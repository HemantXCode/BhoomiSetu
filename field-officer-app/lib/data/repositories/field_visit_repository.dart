import 'dart:convert';
import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../models/field_visit_model.dart';
import '../models/gps_record_model.dart';
import '../models/inspection_model.dart';
import '../models/evidence_model.dart';
import '../models/document_model.dart';
import '../../core/storage/database_helper.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import 'sync_repository.dart';

abstract class IFieldVisitRepository {
  Future<FieldVisitModel> createOrGetVisit({
    required String taskId,
    required String parcelId,
    required String officerId,
  });

  Future<FieldVisitModel?> getVisitById(String visitId);
  Future<List<FieldVisitModel>> getAllVisits();
  Future<void> updateVisitLocation(String visitId, GPSRecordModel gps);
  Future<void> updateInspection(String visitId, InspectionModel inspection);
  Future<void> addEvidence(EvidenceModel evidence);
  Future<void> removeEvidence(String photoId);
  Future<List<EvidenceModel>> getEvidenceForVisit(String visitId);
  Future<void> addDocument(DocumentModel document);
  Future<void> removeDocument(String documentId);
  Future<List<DocumentModel>> getDocumentsForVisit(String visitId);
  Future<void> submitVisit(String visitId, {String? remarks, bool isConfirmed = true});
}

class MockFieldVisitRepository implements IFieldVisitRepository {
  final DatabaseHelper _dbHelper;
  final ISyncRepository syncRepository;

  MockFieldVisitRepository({
    DatabaseHelper? dbHelper,
    required this.syncRepository,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<FieldVisitModel> createOrGetVisit({
    required String taskId,
    required String parcelId,
    required String officerId,
  }) async {
    final db = await _dbHelper.database;
    // Check if visit already exists for this task (duplicate prevention)
    final List<Map<String, dynamic>> existing = await db.query(
      'field_visits',
      where: 'taskId = ?',
      whereArgs: [taskId],
    );

    if (existing.isNotEmpty) {
      final visit = FieldVisitModel.fromJson(existing.first);
      final evidence = await getEvidenceForVisit(visit.visitId);
      final documents = await getDocumentsForVisit(visit.visitId);
      final inspection = await _getInspectionForVisit(visit.visitId);
      return visit.copyWith(
        evidence: evidence,
        documents: documents,
        inspection: inspection,
      );
    }

    final newVisitId = 'VST-${const Uuid().v4().substring(0, 8).toUpperCase()}';
    final visit = FieldVisitModel(
      visitId: newVisitId,
      taskId: taskId,
      parcelId: parcelId,
      officerId: officerId,
      startTime: DateTime.now().toUtc().toIso8601String(),
      status: 'IN_PROGRESS',
      syncStatus: 'PENDING',
    );

    await db.insert('field_visits', {
      'visitId': visit.visitId,
      'taskId': visit.taskId,
      'parcelId': visit.parcelId,
      'officerId': visit.officerId,
      'startTime': visit.startTime,
      'status': visit.status,
      'syncStatus': visit.syncStatus,
      'isConfirmed': 0,
    });

    return visit;
  }

  @override
  Future<FieldVisitModel?> getVisitById(String visitId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'field_visits',
      where: 'visitId = ?',
      whereArgs: [visitId],
    );
    if (maps.isEmpty) return null;

    final visit = FieldVisitModel.fromJson(maps.first);
    final evidence = await getEvidenceForVisit(visitId);
    final documents = await getDocumentsForVisit(visitId);
    final inspection = await _getInspectionForVisit(visitId);

    return visit.copyWith(
      evidence: evidence,
      documents: documents,
      inspection: inspection,
    );
  }

  @override
  Future<List<FieldVisitModel>> getAllVisits() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query('field_visits');
    final List<FieldVisitModel> visits = [];
    for (final map in maps) {
      final visit = FieldVisitModel.fromJson(map);
      final evidence = await getEvidenceForVisit(visit.visitId);
      final documents = await getDocumentsForVisit(visit.visitId);
      final inspection = await _getInspectionForVisit(visit.visitId);
      visits.add(visit.copyWith(evidence: evidence, documents: documents, inspection: inspection));
    }
    return visits;
  }

  @override
  Future<void> updateVisitLocation(String visitId, GPSRecordModel gps) async {
    final db = await _dbHelper.database;
    await db.update(
      'field_visits',
      {
        'latitude': gps.latitude,
        'longitude': gps.longitude,
        'gpsAccuracy': gps.accuracy,
        'altitude': gps.altitude,
      },
      where: 'visitId = ?',
      whereArgs: [visitId],
    );
  }

  @override
  Future<void> updateInspection(String visitId, InspectionModel inspection) async {
    final db = await _dbHelper.database;
    await db.insert(
      'inspections',
      inspection.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<InspectionModel?> _getInspectionForVisit(String visitId) async {
    final db = await _dbHelper.database;
    final maps = await db.query('inspections', where: 'visitId = ?', whereArgs: [visitId]);
    if (maps.isNotEmpty) {
      return InspectionModel.fromJson(maps.first);
    }
    return null;
  }

  @override
  Future<void> addEvidence(EvidenceModel evidence) async {
    final db = await _dbHelper.database;
    await db.insert('evidence', evidence.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> removeEvidence(String photoId) async {
    final db = await _dbHelper.database;
    await db.delete('evidence', where: 'photoId = ?', whereArgs: [photoId]);
  }

  @override
  Future<List<EvidenceModel>> getEvidenceForVisit(String visitId) async {
    final db = await _dbHelper.database;
    final maps = await db.query('evidence', where: 'visitId = ?', whereArgs: [visitId]);
    return maps.map((m) => EvidenceModel.fromJson(m)).toList();
  }

  @override
  Future<void> addDocument(DocumentModel document) async {
    final db = await _dbHelper.database;
    await db.insert('documents', document.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> removeDocument(String documentId) async {
    final db = await _dbHelper.database;
    await db.delete('documents', where: 'documentId = ?', whereArgs: [documentId]);
  }

  @override
  Future<List<DocumentModel>> getDocumentsForVisit(String visitId) async {
    final db = await _dbHelper.database;
    final maps = await db.query('documents', where: 'visitId = ?', whereArgs: [visitId]);
    return maps.map((m) => DocumentModel.fromJson(m)).toList();
  }

  @override
  Future<void> submitVisit(String visitId, {String? remarks, bool isConfirmed = true}) async {
    final db = await _dbHelper.database;
    final endTime = DateTime.now().toUtc().toIso8601String();

    await db.update(
      'field_visits',
      {
        'endTime': endTime,
        'status': 'PENDING_VERIFICATION',
        'remarks': remarks,
        'isConfirmed': isConfirmed ? 1 : 0,
        'syncStatus': 'PENDING',
      },
      where: 'visitId = ?',
      whereArgs: [visitId],
    );

    // Fetch complete visit payload and queue for sync
    final completeVisit = await getVisitById(visitId);
    if (completeVisit != null) {
      await syncRepository.queueOperation(
        entityType: 'FIELD_VISIT',
        entityId: visitId,
        operation: 'SUBMIT',
        payload: jsonEncode(completeVisit.toJson()),
      );
    }
  }
}

class ApiFieldVisitRepository implements IFieldVisitRepository {
  final ApiClient apiClient;
  final MockFieldVisitRepository localFallback;

  ApiFieldVisitRepository({
    required this.apiClient,
    required this.localFallback,
  });

  @override
  Future<FieldVisitModel> createOrGetVisit({
    required String taskId,
    required String parcelId,
    required String officerId,
  }) async {
    return localFallback.createOrGetVisit(taskId: taskId, parcelId: parcelId, officerId: officerId);
  }

  @override
  Future<FieldVisitModel?> getVisitById(String visitId) => localFallback.getVisitById(visitId);

  @override
  Future<List<FieldVisitModel>> getAllVisits() => localFallback.getAllVisits();

  @override
  Future<void> updateVisitLocation(String visitId, GPSRecordModel gps) =>
      localFallback.updateVisitLocation(visitId, gps);

  @override
  Future<void> updateInspection(String visitId, InspectionModel inspection) =>
      localFallback.updateInspection(visitId, inspection);

  @override
  Future<void> addEvidence(EvidenceModel evidence) => localFallback.addEvidence(evidence);

  @override
  Future<void> removeEvidence(String photoId) => localFallback.removeEvidence(photoId);

  @override
  Future<List<EvidenceModel>> getEvidenceForVisit(String visitId) =>
      localFallback.getEvidenceForVisit(visitId);

  @override
  Future<void> addDocument(DocumentModel document) => localFallback.addDocument(document);

  @override
  Future<void> removeDocument(String documentId) => localFallback.removeDocument(documentId);

  @override
  Future<List<DocumentModel>> getDocumentsForVisit(String visitId) =>
      localFallback.getDocumentsForVisit(visitId);

  @override
  Future<void> submitVisit(String visitId, {String? remarks, bool isConfirmed = true}) async {
    await localFallback.submitVisit(visitId, remarks: remarks, isConfirmed: isConfirmed);
    try {
      final completeVisit = await getVisitById(visitId);
      if (completeVisit != null) {
        await apiClient.post(ApiEndpoints.visitSubmit(visitId), data: completeVisit.toJson());
      }
    } catch (_) {
      // Handled by background sync queue
    }
  }
}
