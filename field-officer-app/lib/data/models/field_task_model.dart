class FieldTaskModel {
  final String id;
  final String ulpin;
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
    String? ulpin,
    String? parcelId,
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
  }) : ulpin = ulpin ?? parcelId ?? '';

  String get parcelId => ulpin;

  factory FieldTaskModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id']?.toString() ?? '';
    final rawUlpin = (json['ulpin'] ?? json['parcel_number'] ?? json['parcelId'] ?? json['parcel_id'])?.toString() ?? '';
    final project = json['project'] as String? ?? json['project_name'] as String? ?? 'Pune Ring Road Express Corridor';
    final village = json['village'] as String? ?? '';
    final district = json['district'] as String? ?? json['district_name'] as String? ?? 'Pune';
    final state = json['state'] as String? ?? json['state_name'] as String? ?? 'Maharashtra';
    final surveyNumber = json['surveyNumber'] as String? ?? json['survey_number'] as String? ?? (rawUlpin.isNotEmpty ? 'Gat No. $rawUlpin' : '');
    final landAreaSqM = (json['landAreaSqM'] as num?)?.toDouble() ??
        (json['land_area_sqm'] as num?)?.toDouble() ??
        (((json['area_hectares'] as num?)?.toDouble() ?? 0.0) * 10000.0);
    final taskType = json['taskType'] as String? ?? json['task_type'] as String? ?? 'Survey & Verification';
    final assignedDate = json['assignedDate'] as String? ?? json['assigned_date'] as String? ?? '';
    final dueDate = json['dueDate'] as String? ?? json['due_date'] as String? ?? '';
    final status = json['status'] as String? ?? 'PENDING';
    final latitude = (json['latitude'] as num?)?.toDouble() ?? (json['target_latitude'] as num?)?.toDouble() ?? 18.5204;
    final longitude = (json['longitude'] as num?)?.toDouble() ?? (json['target_longitude'] as num?)?.toDouble() ?? 73.8567;
    final instructions = json['instructions'] as String? ?? 'Conduct field verification and ground parcel inspection.';
    final remarks = json['remarks'] as String?;
    final syncStatus = json['syncStatus'] as String? ?? json['sync_status'] as String? ?? 'SYNCED';

    return FieldTaskModel(
      id: rawId,
      ulpin: rawUlpin,
      project: project,
      village: village,
      district: district,
      state: state,
      surveyNumber: surveyNumber,
      landAreaSqM: landAreaSqM,
      taskType: taskType,
      assignedDate: assignedDate,
      dueDate: dueDate,
      status: status,
      latitude: latitude,
      longitude: longitude,
      instructions: instructions,
      remarks: remarks,
      syncStatus: syncStatus,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ulpin': ulpin,
      'parcelId': ulpin,
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
      ulpin: ulpin,
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
