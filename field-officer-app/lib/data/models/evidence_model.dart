class EvidenceModel {
  final String photoId;
  final String visitId;
  final String parcelId;
  final String officerId;
  final DateTime timestamp;
  final double? latitude;
  final double? longitude;
  final double? gpsAccuracy;
  final String category;
  final String? description;
  final String localFilePath;
  final String syncStatus;

  EvidenceModel({
    required this.photoId,
    required this.visitId,
    required this.parcelId,
    required this.officerId,
    required this.timestamp,
    this.latitude,
    this.longitude,
    this.gpsAccuracy,
    required this.category,
    this.description,
    required this.localFilePath,
    this.syncStatus = 'PENDING',
  });

  factory EvidenceModel.fromJson(Map<String, dynamic> json) {
    return EvidenceModel(
      photoId: json['photoId'] as String? ?? json['photo_id'] as String? ?? '',
      visitId: json['visitId'] as String? ?? json['visit_id'] as String? ?? '',
      parcelId: json['parcelId'] as String? ?? json['parcel_id'] as String? ?? '',
      officerId: json['officerId'] as String? ?? json['officer_id'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'] as String) ?? DateTime.now()
          : DateTime.now(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      gpsAccuracy: (json['gpsAccuracy'] as num?)?.toDouble() ?? (json['gps_accuracy'] as num?)?.toDouble(),
      category: json['category'] as String? ?? 'Parcel Boundary',
      description: json['description'] as String?,
      localFilePath: json['localFilePath'] as String? ?? json['local_file_path'] as String? ?? '',
      syncStatus: json['syncStatus'] as String? ?? json['sync_status'] as String? ?? 'PENDING',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'photoId': photoId,
      'visitId': visitId,
      'parcelId': parcelId,
      'officerId': officerId,
      'timestamp': timestamp.toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'gpsAccuracy': gpsAccuracy,
      'category': category,
      'description': description,
      'localFilePath': localFilePath,
      'syncStatus': syncStatus,
    };
  }
}
