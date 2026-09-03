import 'package:latlong2/latlong.dart';

class LandParcelModel {
  final String ulpin;
  final String surveyNumber;
  final String village;
  final String district;
  final String state;
  final double landAreaSqM;
  final double areaHectares;
  final double latitude;
  final double longitude;
  final String landType;
  final String classification;
  final String ownerName;
  final String status;
  final String projectId;
  final String projectName;
  final String rowStatus;
  final String verificationStatus;
  final bool isAffected;
  final List<LatLng> polygon;

  LandParcelModel({
    String? ulpin,
    String? parcelId,
    required this.surveyNumber,
    required this.village,
    required this.district,
    required this.state,
    double? landAreaSqM,
    double? areaHectares,
    double? latitude,
    double? longitude,
    String? landType,
    String? classification,
    required this.ownerName,
    required this.status,
    this.projectId = 'PRJ-MH-PUN-001',
    this.projectName = 'Pune Ring Road Express Corridor (Phase-I)',
    this.rowStatus = 'Corridor Intersects This Parcel',
    this.verificationStatus = 'VERIFIED',
    this.isAffected = true,
    List<LatLng>? polygon,
  })  : ulpin = ulpin ?? parcelId ?? '',
        areaHectares = areaHectares ?? ((landAreaSqM ?? 0.0) / 10000.0),
        landAreaSqM = landAreaSqM ?? ((areaHectares ?? 0.0) * 10000.0),
        classification = classification ?? landType ?? 'AGRICULTURAL',
        landType = landType ?? classification ?? 'Agricultural',
        polygon = polygon ?? const [],
        latitude = latitude ?? (polygon != null && polygon.isNotEmpty ? _calcCentroid(polygon).latitude : 18.5204),
        longitude = longitude ?? (polygon != null && polygon.isNotEmpty ? _calcCentroid(polygon).longitude : 73.8567);

  String get parcelId => ulpin;

  static LatLng _calcCentroid(List<LatLng> points) {
    if (points.isEmpty) return const LatLng(18.5204, 73.8567);
    double sumLat = 0;
    double sumLng = 0;
    for (final p in points) {
      sumLat += p.latitude;
      sumLng += p.longitude;
    }
    return LatLng(sumLat / points.length, sumLng / points.length);
  }

  LatLng get centroid => polygon.isNotEmpty ? _calcCentroid(polygon) : LatLng(latitude, longitude);

  factory LandParcelModel.fromJson(Map<String, dynamic> json) {
    final rawPolygon = (json['polygon'] ?? json['coordinates'] ?? json['geometry']?['coordinates']) as List<dynamic>?;
    List<LatLng> parsedPolygon = [];

    if (rawPolygon != null) {
      if (rawPolygon.isNotEmpty && rawPolygon.first is List && (rawPolygon.first as List).isNotEmpty && (rawPolygon.first as List).first is List) {
        // GeoJSON [[[lng, lat], ...]]
        final ring = (rawPolygon.first as List);
        for (final pt in ring) {
          if (pt is List && pt.length >= 2) {
            final double p0 = (pt[0] as num).toDouble();
            final double p1 = (pt[1] as num).toDouble();
            // GeoJSON is [lng, lat]
            if (p0 > 50) {
              parsedPolygon.add(LatLng(p1, p0));
            } else {
              parsedPolygon.add(LatLng(p0, p1));
            }
          }
        }
      } else {
        // Leaflet [[lat, lng], ...]
        for (final pt in rawPolygon) {
          if (pt is List && pt.length >= 2) {
            final double p0 = (pt[0] as num).toDouble();
            final double p1 = (pt[1] as num).toDouble();
            if (p0 > 50) {
              parsedPolygon.add(LatLng(p1, p0));
            } else {
              parsedPolygon.add(LatLng(p0, p1));
            }
          }
        }
      }
    }

    final double ha = (json['area_hectares'] as num?)?.toDouble() ??
        ((json['landAreaSqM'] as num?)?.toDouble() ?? (json['land_area_sqm'] as num?)?.toDouble() ?? 0.0) / 10000.0;
    final double sqm = (json['landAreaSqM'] as num?)?.toDouble() ??
        (json['land_area_sqm'] as num?)?.toDouble() ??
        (ha * 10000.0);

    return LandParcelModel(
      ulpin: (json['ulpin'] ?? json['parcelId'] ?? json['parcel_id'] ?? json['id'])?.toString() ?? '',
      surveyNumber: json['surveyNumber'] as String? ?? json['survey_number'] as String? ?? '',
      village: json['village'] as String? ?? '',
      district: json['district'] as String? ?? 'Pune',
      state: json['state'] as String? ?? 'Maharashtra',
      landAreaSqM: sqm,
      areaHectares: ha,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      landType: json['landType'] as String? ?? json['land_type'] as String? ?? json['classification'] as String? ?? 'Agricultural',
      classification: json['classification'] as String? ?? json['landType'] as String? ?? 'AGRICULTURAL',
      ownerName: json['ownerName'] as String? ?? json['owner_name'] as String? ?? '',
      status: json['status'] as String? ?? 'PENDING',
      projectId: json['project_id']?.toString() ?? json['projectId']?.toString() ?? 'PRJ-MH-PUN-001',
      projectName: json['project_name'] as String? ?? json['projectName'] as String? ?? 'Pune Ring Road Express Corridor (Phase-I)',
      rowStatus: json['row_status'] as String? ?? json['rowStatus'] as String? ?? 'Corridor Intersects This Parcel',
      verificationStatus: json['verification_status'] as String? ?? json['verificationStatus'] as String? ?? 'VERIFIED',
      isAffected: json['affected_by_corridor'] as bool? ?? json['is_affected'] as bool? ?? true,
      polygon: parsedPolygon,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ulpin': ulpin,
      'parcelId': ulpin,
      'surveyNumber': surveyNumber,
      'survey_number': surveyNumber,
      'village': village,
      'district': district,
      'state': state,
      'landAreaSqM': landAreaSqM,
      'land_area_sqm': landAreaSqM,
      'area_hectares': areaHectares,
      'latitude': latitude,
      'longitude': longitude,
      'landType': landType,
      'classification': classification,
      'ownerName': ownerName,
      'owner_name': ownerName,
      'status': status,
      'project_id': projectId,
      'project_name': projectName,
      'row_status': rowStatus,
      'verification_status': verificationStatus,
      'is_affected': isAffected,
      'polygon': polygon.map((p) => [p.latitude, p.longitude]).toList(),
    };
  }
}

