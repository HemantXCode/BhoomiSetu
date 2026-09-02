import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/app_colors.dart';
import 'land_parcel_model.dart';

enum AcquisitionStatus {
  acquired,
  inProgress,
  pending;

  static AcquisitionStatus fromString(String? value) {
    if (value == null) return AcquisitionStatus.pending;
    switch (value.toUpperCase()) {
      case 'ACQUIRED':
      case 'VERIFIED':
      case 'COMPLETED':
        return AcquisitionStatus.acquired;
      case 'IN_PROGRESS':
      case 'INPROGRESS':
      case 'SURVEYING':
        return AcquisitionStatus.inProgress;
      case 'PENDING':
      case 'NOT_STARTED':
      default:
        return AcquisitionStatus.pending;
    }
  }

  String toDbString() {
    switch (this) {
      case AcquisitionStatus.acquired:
        return 'ACQUIRED';
      case AcquisitionStatus.inProgress:
        return 'IN_PROGRESS';
      case AcquisitionStatus.pending:
        return 'PENDING';
    }
  }

  String get label {
    switch (this) {
      case AcquisitionStatus.acquired:
        return 'Acquired';
      case AcquisitionStatus.inProgress:
        return 'In Progress';
      case AcquisitionStatus.pending:
        return 'Pending';
    }
  }

  Color get color {
    switch (this) {
      case AcquisitionStatus.acquired:
        return AppColors.success; // #15803D Forest Green
      case AcquisitionStatus.inProgress:
        return AppColors.warning; // #D97706 Amber/Orange
      case AcquisitionStatus.pending:
        return AppColors.danger; // #DC2626 Ruby Red
    }
  }

  Color get backgroundColor {
    switch (this) {
      case AcquisitionStatus.acquired:
        return AppColors.successBg;
      case AcquisitionStatus.inProgress:
        return AppColors.warningBg;
      case AcquisitionStatus.pending:
        return AppColors.dangerBg;
    }
  }
}

class CorridorSegmentModel {
  final String id;
  final String projectId;
  final String name;
  final AcquisitionStatus status;
  final List<LatLng> routeGeometry;
  final List<String> ulpins;
  final double lengthKm;
  final double landAreaHa;

  CorridorSegmentModel({
    required this.id,
    required this.projectId,
    required this.name,
    required this.status,
    required this.routeGeometry,
    List<String>? ulpins,
    List<String>? parcelIds,
    this.lengthKm = 0.0,
    this.landAreaHa = 0.0,
  }) : ulpins = ulpins ?? parcelIds ?? const [];

  List<String> get parcelIds => ulpins;

  factory CorridorSegmentModel.fromJson(Map<String, dynamic> json) {
    final rawCoords = json['route_geometry'] as List<dynamic>? ?? [];
    final coords = rawCoords.map((c) {
      if (c is List && c.length >= 2) {
        return LatLng((c[0] as num).toDouble(), (c[1] as num).toDouble());
      } else if (c is Map<String, dynamic>) {
        return LatLng(
          (c['lat'] as num?)?.toDouble() ?? (c['latitude'] as num?)?.toDouble() ?? 0.0,
          (c['lng'] as num?)?.toDouble() ?? (c['longitude'] as num?)?.toDouble() ?? 0.0,
        );
      }
      return const LatLng(0, 0);
    }).toList();

    final rawUlpins = (json['ulpins'] ?? json['parcel_ids'] ?? json['parcelIds']) as List<dynamic>? ?? [];

    return CorridorSegmentModel(
      id: json['id']?.toString() ?? '',
      projectId: json['project_id']?.toString() ?? '',
      name: json['name'] as String? ?? 'Segment',
      status: AcquisitionStatus.fromString(json['status'] as String?),
      routeGeometry: coords,
      ulpins: rawUlpins.map((e) => e.toString()).toList(),
      lengthKm: (json['length_km'] as num?)?.toDouble() ?? 0.0,
      landAreaHa: (json['land_area_ha'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'project_id': projectId,
      'name': name,
      'status': status.toDbString(),
      'route_geometry': routeGeometry.map((p) => [p.latitude, p.longitude]).toList(),
      'ulpins': ulpins,
      'parcel_ids': ulpins,
      'length_km': lengthKm,
      'land_area_ha': landAreaHa,
    };
  }
}

class ProjectCorridorModel {
  final String id;
  final String name;
  final String type; // 'Highway' | 'Railway'
  final String code;
  final String startPoint;
  final String endPoint;
  final LatLng startCoordinate;
  final LatLng endCoordinate;
  final double totalLandRequired; // Ha
  final double acquiredLand; // Ha
  final double inProgressLand; // Ha
  final double pendingLand; // Ha
  final int totalParcels;
  final int acquiredParcels;
  final int inProgressParcels;
  final int pendingParcels;
  final String status; // 'Ongoing', 'Completed', etc.
  final bool isDemo;
  final double lengthKm;
  final String authority;
  final List<LatLng> routeGeometry;
  final List<CorridorSegmentModel> segments;
  final List<LandParcelModel> parcels;

  ProjectCorridorModel({
    required this.id,
    required this.name,
    required this.type,
    required this.code,
    required this.startPoint,
    required this.endPoint,
    required this.startCoordinate,
    required this.endCoordinate,
    required this.totalLandRequired,
    required this.acquiredLand,
    required this.inProgressLand,
    required this.pendingLand,
    required this.totalParcels,
    required this.acquiredParcels,
    required this.inProgressParcels,
    required this.pendingParcels,
    this.status = 'Ongoing',
    this.isDemo = true,
    this.lengthKm = 0.0,
    this.authority = 'Maharashtra State Road Development Corp / Ministry of Railways',
    this.routeGeometry = const [],
    this.segments = const [],
    this.parcels = const [],
  });

  /// Dynamic Acquisition Progress %: (Acquired Land / Total Land Required) * 100
  double get acquisitionProgressPercentage {
    if (totalLandRequired <= 0) return 0.0;
    final progress = (acquiredLand / totalLandRequired) * 100.0;
    return progress > 100.0 ? 100.0 : progress;
  }

  /// Dynamic Parcel Completion %: (Acquired Parcels / Total Parcels) * 100
  double get parcelCompletionPercentage {
    if (totalParcels <= 0) return 0.0;
    final completion = (acquiredParcels / totalParcels) * 100.0;
    return completion > 100.0 ? 100.0 : completion;
  }

  /// In-Progress Land %
  double get inProgressLandPercentage {
    if (totalLandRequired <= 0) return 0.0;
    return (inProgressLand / totalLandRequired) * 100.0;
  }

  /// Pending Land %
  double get pendingLandPercentage {
    if (totalLandRequired <= 0) return 0.0;
    return (pendingLand / totalLandRequired) * 100.0;
  }

  String get formattedAcquisitionProgress => '${acquisitionProgressPercentage.toStringAsFixed(1)}%';
  String get formattedParcelCompletion => '${parcelCompletionPercentage.toStringAsFixed(1)}%';

  factory ProjectCorridorModel.fromJson(Map<String, dynamic> json) {
    final rawCoords = json['route_geometry'] as List<dynamic>? ?? [];
    final coords = rawCoords.map((c) {
      if (c is List && c.length >= 2) {
        return LatLng((c[0] as num).toDouble(), (c[1] as num).toDouble());
      } else if (c is Map<String, dynamic>) {
        return LatLng(
          (c['lat'] as num?)?.toDouble() ?? (c['latitude'] as num?)?.toDouble() ?? 0.0,
          (c['lng'] as num?)?.toDouble() ?? (c['longitude'] as num?)?.toDouble() ?? 0.0,
        );
      }
      return const LatLng(0, 0);
    }).toList();

    final rawSegments = (json['segments'] as List<dynamic>?) ?? [];
    final segments = rawSegments
        .map((s) => CorridorSegmentModel.fromJson(s as Map<String, dynamic>))
        .toList();

    final rawParcels = (json['parcels'] as List<dynamic>?) ?? [];
    final parcels = rawParcels
        .map((p) => LandParcelModel.fromJson(p as Map<String, dynamic>))
        .toList();

    final startCoordJson = json['start_coordinate'] as Map<String, dynamic>?;
    final endCoordJson = json['end_coordinate'] as Map<String, dynamic>?;

    final startCoord = startCoordJson != null
        ? LatLng((startCoordJson['latitude'] as num).toDouble(), (startCoordJson['longitude'] as num).toDouble())
        : (coords.isNotEmpty ? coords.first : const LatLng(18.5204, 73.8567));

    final endCoord = endCoordJson != null
        ? LatLng((endCoordJson['latitude'] as num).toDouble(), (endCoordJson['longitude'] as num).toDouble())
        : (coords.isNotEmpty ? coords.last : const LatLng(18.5204, 73.8567));

    return ProjectCorridorModel(
      id: (json['project_id'] ?? json['id'])?.toString() ?? '',
      name: json['name'] as String? ?? 'Infrastructure Corridor',
      type: json['type'] as String? ?? 'Highway',
      code: json['code'] as String? ?? '',
      startPoint: json['start_point'] as String? ?? 'Point A',
      endPoint: json['end_point'] as String? ?? 'Point B',
      startCoordinate: startCoord,
      endCoordinate: endCoord,
      totalLandRequired: (json['total_land_required'] as num?)?.toDouble() ?? 0.0,
      acquiredLand: (json['acquired_land'] as num?)?.toDouble() ?? 0.0,
      inProgressLand: (json['in_progress_land'] as num?)?.toDouble() ?? 0.0,
      pendingLand: (json['pending_land'] as num?)?.toDouble() ?? 0.0,
      totalParcels: (json['total_parcels'] as num?)?.toInt() ?? 0,
      acquiredParcels: (json['acquired_parcels'] as num?)?.toInt() ?? 0,
      inProgressParcels: (json['in_progress_parcels'] as num?)?.toInt() ?? 0,
      pendingParcels: (json['pending_parcels'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'Ongoing',
      isDemo: json['is_demo'] as bool? ?? true,
      lengthKm: (json['length_km'] as num?)?.toDouble() ?? 0.0,
      authority: json['authority'] as String? ?? 'Government Authority',
      routeGeometry: coords,
      segments: segments,
      parcels: parcels,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'project_id': id,
      'name': name,
      'type': type,
      'code': code,
      'start_point': startPoint,
      'end_point': endPoint,
      'start_coordinate': {
        'latitude': startCoordinate.latitude,
        'longitude': startCoordinate.longitude,
      },
      'end_coordinate': {
        'latitude': endCoordinate.latitude,
        'longitude': endCoordinate.longitude,
      },
      'total_land_required': totalLandRequired,
      'acquired_land': acquiredLand,
      'in_progress_land': inProgressLand,
      'pending_land': pendingLand,
      'total_parcels': totalParcels,
      'acquired_parcels': acquiredParcels,
      'in_progress_parcels': inProgressParcels,
      'pending_parcels': pendingParcels,
      'status': status,
      'is_demo': isDemo,
      'length_km': lengthKm,
      'authority': authority,
      'route_geometry': routeGeometry.map((p) => [p.latitude, p.longitude]).toList(),
      'segments': segments.map((s) => s.toJson()).toList(),
      'parcels': parcels.map((p) => p.toJson()).toList(),
    };
  }
}
