import 'inspection_model.dart';
import 'evidence_model.dart';
import 'document_model.dart';

class FieldVisitModel {
  final String visitId;
  final String taskId;
  final String parcelId;
  final String officerId;
  final String startTime;
  final String? endTime;
  final double? latitude;
  final double? longitude;
  final double? gpsAccuracy;
  final double? altitude;
  final String status; // IN_PROGRESS, PENDING_VERIFICATION, VERIFIED, REJECTED
  final String? remarks;
  final bool isConfirmed;
  final String syncStatus; // PENDING, SYNCING, SYNCED, FAILED
  final InspectionModel? inspection;
  final List<EvidenceModel> evidence;
  final List<DocumentModel> documents;

  FieldVisitModel({
    required this.visitId,
    required this.taskId,
    required this.parcelId,
    required this.officerId,
    required this.startTime,
    this.endTime,
    this.latitude,
    this.longitude,
    this.gpsAccuracy,
    this.altitude,
    this.status = 'IN_PROGRESS',
    this.remarks,
    this.isConfirmed = false,
    this.syncStatus = 'PENDING',
    this.inspection,
    this.evidence = const [],
    this.documents = const [],
  });

  factory FieldVisitModel.fromJson(Map<String, dynamic> json) {
    return FieldVisitModel(
      visitId: (json['visitId'] ?? json['visit_id'] ?? json['id'])?.toString() ?? '',
      taskId: (json['taskId'] ?? json['task_id'])?.toString() ?? '',
      parcelId: (json['parcelId'] ?? json['parcel_id'])?.toString() ?? '',
      officerId: (json['officerId'] ?? json['officer_id'] ?? json['field_officer_id'])?.toString() ?? '',
      startTime: json['startTime'] as String? ?? json['start_time'] as String? ?? json['visit_start'] as String? ?? '',
      endTime: json['endTime'] as String? ?? json['end_time'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      gpsAccuracy: (json['gpsAccuracy'] as num?)?.toDouble() ?? (json['gps_accuracy'] as num?)?.toDouble() ?? (json['accuracy_meters'] as num?)?.toDouble(),
      altitude: (json['altitude'] as num?)?.toDouble(),
      status: json['status'] as String? ?? 'IN_PROGRESS',
      remarks: json['remarks'] as String?,
      isConfirmed: json['isConfirmed'] == 1 || json['isConfirmed'] == true || json['is_confirmed'] == 1,
      syncStatus: (json['syncStatus'] ?? json['sync_status']) as String? ?? 'PENDING',
      inspection: json['inspection'] != null ? InspectionModel.fromJson(json['inspection'] as Map<String, dynamic>) : null,
      evidence: (json['evidence'] as List<dynamic>?)
              ?.map((e) => EvidenceModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      documents: (json['documents'] as List<dynamic>?)
              ?.map((d) => DocumentModel.fromJson(d as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'visitId': visitId,
      'taskId': taskId,
      'parcelId': parcelId,
      'officerId': officerId,
      'startTime': startTime,
      'endTime': endTime,
      'latitude': latitude,
      'longitude': longitude,
      'gpsAccuracy': gpsAccuracy,
      'altitude': altitude,
      'status': status,
      'remarks': remarks,
      'isConfirmed': isConfirmed ? 1 : 0,
      'syncStatus': syncStatus,
      'inspection': inspection?.toJson(),
      'evidence': evidence.map((e) => e.toJson()).toList(),
      'documents': documents.map((d) => d.toJson()).toList(),
    };
  }

  FieldVisitModel copyWith({
    String? endTime,
    double? latitude,
    double? longitude,
    double? gpsAccuracy,
    double? altitude,
    String? status,
    String? remarks,
    bool? isConfirmed,
    String? syncStatus,
    InspectionModel? inspection,
    List<EvidenceModel>? evidence,
    List<DocumentModel>? documents,
  }) {
    return FieldVisitModel(
      visitId: visitId,
      taskId: taskId,
      parcelId: parcelId,
      officerId: officerId,
      startTime: startTime,
      endTime: endTime ?? this.endTime,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      gpsAccuracy: gpsAccuracy ?? this.gpsAccuracy,
      altitude: altitude ?? this.altitude,
      status: status ?? this.status,
      remarks: remarks ?? this.remarks,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      syncStatus: syncStatus ?? this.syncStatus,
      inspection: inspection ?? this.inspection,
      evidence: evidence ?? this.evidence,
      documents: documents ?? this.documents,
    );
  }
}
