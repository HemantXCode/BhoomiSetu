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

  String get fileName => localFilePath.isNotEmpty ? localFilePath.split(RegExp(r'[/\\]')).last : photoId;

  factory EvidenceModel.fromJson(Map<String, dynamic> json) {
    return EvidenceModel(
      photoId: (json['photoId'] ?? json['photo_id'])?.toString() ?? '',
      visitId: (json['visitId'] ?? json['visit_id'])?.toString() ?? '',
      parcelId: (json['parcelId'] ?? json['parcel_id'])?.toString() ?? '',
      officerId: (json['officerId'] ?? json['officer_id'])?.toString() ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.tryParse(json['timestamp'].toString()) ?? DateTime.now()
          : DateTime.now(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      gpsAccuracy: (json['gpsAccuracy'] as num?)?.toDouble() ?? (json['gps_accuracy'] as num?)?.toDouble(),
      category: json['category'] as String? ?? 'Parcel Boundary',
      description: json['description'] as String?,
      localFilePath: (json['localFilePath'] ?? json['local_file_path'] ?? json['file_path'] ?? json['filePath'])?.toString() ?? '',
      syncStatus: (json['syncStatus'] ?? json['sync_status'])?.toString() ?? 'PENDING',
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
