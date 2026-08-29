class FieldTaskModel {
  final String id;
  final String parcelId;
  final String project;
  final String village;
  final String district;
  final String state;
  final String surveyNumber;
  final double landAreaSqM;
  final String taskType;
  final String assignedDate;
  final String dueDate;
  final String status;
  final double latitude;
  final double longitude;
  final String instructions;
  final String? remarks;
  final String syncStatus;

  FieldTaskModel({
    required this.id,
    required this.parcelId,
    required this.project,
    required this.village,
    required this.district,
    required this.state,
    required this.surveyNumber,
    required this.landAreaSqM,
    required this.taskType,
    required this.assignedDate,
    required this.dueDate,
    required this.status,
    required this.latitude,
    required this.longitude,
    required this.instructions,
    this.remarks,
    this.syncStatus = 'SYNCED',
  });

  factory FieldTaskModel.fromJson(Map<String, dynamic> json) {
    return FieldTaskModel(
      id: json['id'] as String? ?? '',
      parcelId: json['parcelId'] as String? ?? json['parcel_id'] as String? ?? '',
      project: json['project'] as String? ?? 'Pune Ring Road Express Corridor',
      village: json['village'] as String? ?? '',
      district: json['district'] as String? ?? 'Pune',
      state: json['state'] as String? ?? 'Maharashtra',
      surveyNumber: json['surveyNumber'] as String? ?? json['survey_number'] as String? ?? '',
      landAreaSqM: (json['landAreaSqM'] as num?)?.toDouble() ?? (json['land_area_sqm'] as num?)?.toDouble() ?? 0.0,
      taskType: json['taskType'] as String? ?? json['task_type'] as String? ?? 'Survey & Verification',
      assignedDate: json['assignedDate'] as String? ?? json['assigned_date'] as String? ?? '',
      dueDate: json['dueDate'] as String? ?? json['due_date'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      instructions: json['instructions'] as String? ?? '',
      remarks: json['remarks'] as String?,
      syncStatus: json['syncStatus'] as String? ?? json['sync_status'] as String? ?? 'SYNCED',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'parcelId': parcelId,
      'project': project,
      'village': village,
      'district': district,
      'state': state,
      'surveyNumber': surveyNumber,
      'landAreaSqM': landAreaSqM,
      'taskType': taskType,
      'assignedDate': assignedDate,
      'dueDate': dueDate,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'instructions': instructions,
      'remarks': remarks,
      'syncStatus': syncStatus,
    };
  }

  FieldTaskModel copyWith({
    String? status,
    String? remarks,
    String? syncStatus,
  }) {
    return FieldTaskModel(
      id: id,
      parcelId: parcelId,
      project: project,
      village: village,
      district: district,
      state: state,
      surveyNumber: surveyNumber,
      landAreaSqM: landAreaSqM,
      taskType: taskType,
      assignedDate: assignedDate,
      dueDate: dueDate,
      status: status ?? this.status,
      latitude: latitude,
      longitude: longitude,
      instructions: instructions,
      remarks: remarks ?? this.remarks,
      syncStatus: syncStatus ?? this.syncStatus,
    );
  }
}
