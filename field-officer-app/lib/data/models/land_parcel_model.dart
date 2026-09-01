class LandParcelModel {
  final String parcelId;
  final String surveyNumber;
  final String village;
  final String district;
  final String state;
  final double landAreaSqM;
  final double latitude;
  final double longitude;
  final String landType;
  final String ownerName;
  final String status;

  LandParcelModel({
    required this.parcelId,
    required this.surveyNumber,
    required this.village,
    required this.district,
    required this.state,
    required this.landAreaSqM,
    required this.latitude,
    required this.longitude,
    required this.landType,
    required this.ownerName,
    required this.status,
  });

  factory LandParcelModel.fromJson(Map<String, dynamic> json) {
    return LandParcelModel(
      parcelId: (json['parcelId'] ?? json['parcel_id'] ?? json['id'])?.toString() ?? '',
      surveyNumber: json['surveyNumber'] as String? ?? json['survey_number'] as String? ?? '',
      village: json['village'] as String? ?? '',
      district: json['district'] as String? ?? 'Pune',
      state: json['state'] as String? ?? 'Maharashtra',
      landAreaSqM: (json['landAreaSqM'] as num?)?.toDouble() ?? (json['land_area_sqm'] as num?)?.toDouble() ?? 0.0,
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      landType: json['landType'] as String? ?? json['land_type'] as String? ?? 'Agricultural',
      ownerName: json['ownerName'] as String? ?? json['owner_name'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'parcelId': parcelId,
      'surveyNumber': surveyNumber,
      'village': village,
      'district': district,
      'state': state,
      'landAreaSqM': landAreaSqM,
      'latitude': latitude,
      'longitude': longitude,
      'landType': landType,
      'ownerName': ownerName,
      'status': status,
    };
  }
}
