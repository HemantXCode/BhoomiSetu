import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:field_officer_app/data/models/land_parcel_model.dart';
import 'package:field_officer_app/data/models/field_task_model.dart';
import 'package:field_officer_app/data/models/project_corridor_model.dart';
import 'package:field_officer_app/core/theme/app_colors.dart';
import 'package:field_officer_app/core/widgets/bhoomi_app_bar.dart';
import 'package:field_officer_app/core/widgets/bhoomi_button.dart';
import 'package:field_officer_app/core/routing/app_router.dart';
import 'package:field_officer_app/features/tasks/tasks_controller.dart';
import 'project_corridor_controller.dart';
import 'widgets/project_selector_bar.dart';
import 'widgets/corridor_legend_widget.dart';
import 'widgets/project_corridor_bottom_sheet.dart';

class ParcelMapScreen extends ConsumerStatefulWidget {
  const ParcelMapScreen({super.key});

  @override
  ConsumerState<ParcelMapScreen> createState() => _ParcelMapScreenState();
}

class _ParcelMapScreenState extends ConsumerState<ParcelMapScreen> {
  final MapController _mapController = MapController();
  LandParcelModel? _selectedParcel;
  bool _isOfflineFallback = false;
  bool _isLegendCollapsed = false;

  // Center coordinate around Pune Corridor
  static const LatLng _puneCenter = LatLng(18.5204, 73.8567);
  static const LatLng _officerLocation = LatLng(18.5180, 73.7400);

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksControllerProvider);
    final tasks = tasksState.tasks;

    final corridorState = ref.watch(projectCorridorControllerProvider);
    final corridorCtrl = ref.read(projectCorridorControllerProvider.notifier);
    final visibleCorridors = corridorState.visibleCorridors;

    // Collect all visible parcels from active project corridors (or fallback to tasks if empty)
    final corridorParcels = corridorState.visibleParcels;

    // Build Polylines for Corridor Routes and Segment Statuses
    final polylines = <Polyline>[];

    for (final corridor in visibleCorridors) {
      // 1. Background full corridor trace (project context)
      if (corridor.routeGeometry.isNotEmpty) {
        polylines.add(
          Polyline(
            points: corridor.routeGeometry,
            strokeWidth: 7.0,
            color: AppColors.secondary.withValues(alpha: 0.35),
            borderColor: Colors.white70,
            borderStrokeWidth: 1.5,
          ),
        );
      }

      // 2. Acquisition-status colored segments along the corridor
      for (final segment in corridor.segments) {
        if (segment.routeGeometry.isNotEmpty) {
          polylines.add(
            Polyline(
              points: segment.routeGeometry,
              strokeWidth: 5.5,
              color: segment.status.color,
              borderColor: Colors.white,
              borderStrokeWidth: 1.0,
            ),
          );
        }
      }
    }

    // Build Map Markers
    final markers = <Marker>[];

    // A. Project Corridor Start (Point A) and End (Point B) Markers
    for (final corridor in visibleCorridors) {
      final isRail = corridor.type.toLowerCase().contains('rail');

      // Start Marker (Point A)
      markers.add(
        Marker(
          point: corridor.startCoordinate,
          width: 110,
          height: 44,
          child: GestureDetector(
            onTap: () => _openCorridorDetails(corridor),
            child: _buildEndpointMarker(
              label: 'Point A',
              locationName: corridor.startPoint.split('(').first.trim(),
              color: AppColors.primary,
              icon: isRail ? Icons.train : Icons.play_arrow,
            ),
          ),
        ),
      );

      // End Marker (Point B)
      markers.add(
        Marker(
          point: corridor.endCoordinate,
          width: 110,
          height: 44,
          child: GestureDetector(
            onTap: () => _openCorridorDetails(corridor),
            child: _buildEndpointMarker(
              label: 'Point B',
              locationName: corridor.endPoint.split('(').first.trim(),
              color: AppColors.secondary,
              icon: isRail ? Icons.flag : Icons.stop,
            ),
          ),
        ),
      );
    }

    // B. Cadastral Land Parcel Markers along the corridor
    final displayedParcels = corridorParcels.isNotEmpty
        ? corridorParcels
        : tasks.map((t) => LandParcelModel(
              parcelId: t.parcelId,
              surveyNumber: t.surveyNumber,
              village: t.village,
              district: t.district,
              state: t.state,
              landAreaSqM: t.landAreaSqM,
              latitude: t.latitude,
              longitude: t.longitude,
              landType: 'Agricultural',
              ownerName: 'Assigned Landowner',
              status: t.status,
            )).toList();

    for (final parcel in displayedParcels) {
      final isSelected = _selectedParcel?.parcelId == parcel.parcelId;
      final statusEnum = AcquisitionStatus.fromString(parcel.status);

      markers.add(
        Marker(
          point: LatLng(parcel.latitude, parcel.longitude),
          width: 58,
          height: 52,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedParcel = parcel;
              });
              corridorCtrl.highlightParcel(parcel.parcelId);
              _mapController.move(LatLng(parcel.latitude, parcel.longitude), 14.5);
            },
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(
                      color: isSelected ? AppColors.primaryLight : statusEnum.color,
                      width: 1.5,
                    ),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 1))],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.white : statusEnum.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        parcel.ulpin.replaceAll('ULPIN-', '').replaceAll('MH-PUN-', '').replaceAll('PUN-', '').replaceAll('PRR-', 'R-').replaceAll('PNR-', 'N-'),
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.location_on,
                  size: isSelected ? 28 : 22,
                  color: isSelected ? AppColors.primary : statusEnum.color,
                ),
              ],
            ),
          ),
        ),
      );
    }

    // C. Officer Location Marker
    markers.add(
      const Marker(
        point: _officerLocation,
        width: 44,
        height: 44,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_pin_circle, size: 30, color: Color(0xFF10B981)),
          ],
        ),
      ),
    );

    // Current subtitle based on active filter
    String subtitle = 'All Infrastructure Corridors';
    if (corridorState.selectedProjectFilter != 'ALL' && visibleCorridors.isNotEmpty) {
      subtitle = visibleCorridors.first.name;
    }

    return Scaffold(
      appBar: BhoomiAppBar(
        title: 'Corridor & Parcel Map',
        subtitle: subtitle,
        actions: [
          IconButton(
            icon: Icon(_isOfflineFallback ? Icons.map : Icons.layers_outlined, color: Colors.white),
            tooltip: 'Toggle Offline Vector Card View',
            onPressed: () => setState(() => _isOfflineFallback = !_isOfflineFallback),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            tooltip: 'Project Overview',
            onPressed: () {
              if (visibleCorridors.isNotEmpty) {
                _openCorridorDetails(visibleCorridors.first);
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.my_location, color: Colors.white),
            tooltip: 'Center Officer Location',
            onPressed: () => _mapController.move(_officerLocation, 14.0),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Map or Offline Card View
          if (_isOfflineFallback)
            _buildOfflineMapView(visibleCorridors, displayedParcels, tasks)
          else
            FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: _puneCenter,
                initialZoom: 11.2,
                minZoom: 8.5,
                maxZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'in.gov.bhoomisetu.field_officer_app',
                  errorTileCallback: (tile, error, stackTrace) {
                    // Graceful fallback if tile network fails
                  },
                ),
                PolylineLayer(polylines: polylines),
                MarkerLayer(markers: markers),
              ],
            ),

          // Top Project Selector Bar
          if (!_isOfflineFallback)
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: ProjectSelectorBar(
                corridors: corridorState.corridors,
                selectedFilter: corridorState.selectedProjectFilter,
                onSelectFilter: (filterId) {
                  corridorCtrl.selectProjectFilter(filterId);
                  _focusMapOnFilter(filterId, corridorState.corridors);
                },
              ),
            ),

          // Map Legend / Overlay
          if (!_isOfflineFallback)
            Positioned(
              top: 60,
              left: 10,
              child: CorridorLegendWidget(
                isCollapsed: _isLegendCollapsed,
                onToggleCollapse: () {
                  setState(() => _isLegendCollapsed = !_isLegendCollapsed);
                },
              ),
            ),

          // Recenter / Fit Corridor Floating Action Button
          if (!_isOfflineFallback)
            Positioned(
              bottom: _selectedParcel != null ? 210 : 20,
              right: 14,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.small(
                    heroTag: 'zoom_fit_btn',
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    tooltip: 'Fit Active Corridor',
                    onPressed: () {
                      _focusMapOnFilter(corridorState.selectedProjectFilter, corridorState.corridors);
                    },
                    child: const Icon(Icons.crop_free, size: 20),
                  ),
                  const SizedBox(height: 8),
                  FloatingActionButton.small(
                    heroTag: 'recenter_gps_btn',
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF10B981),
                    tooltip: 'Center GPS Location',
                    onPressed: () => _mapController.move(_officerLocation, 14.0),
                    child: const Icon(Icons.my_location, size: 20),
                  ),
                ],
              ),
            ),

          // Selected Parcel Details Card
          if (_selectedParcel != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: _buildSelectedParcelCard(tasks),
            ),
        ],
      ),
    );
  }

  Widget _buildEndpointMarker({
    required String label,
    required String locationName,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
        border: Border.all(color: Colors.white, width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 4),
          Flexible(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 8, fontWeight: FontWeight.w800, color: Colors.white70),
                ),
                Text(
                  locationName,
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedParcelCard(List<FieldTaskModel> tasks) {
    final parcel = _selectedParcel!;
    final statusEnum = AcquisitionStatus.fromString(parcel.status);

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ULPIN ${parcel.ulpin}',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.secondary),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      Text(
                        '${parcel.village} • Survey No: ${parcel.surveyNumber}',
                        style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: statusEnum.backgroundColor,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: statusEnum.color.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    statusEnum.label.toUpperCase(),
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: statusEnum.color,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Area: ${parcel.landAreaSqM.toStringAsFixed(0)} sq.m',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                Text(
                  'GPS: ${parcel.latitude.toStringAsFixed(4)}, ${parcel.longitude.toStringAsFixed(4)}',
                  style: const TextStyle(fontSize: 10, fontFamily: 'monospace', color: AppColors.textSecondary),
                ),
              ],
            ),
            if (parcel.ownerName.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                'Owner: ${parcel.ownerName}',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: BhoomiButton(
                    text: 'OPEN TASK',
                    height: 38,
                    onPressed: () {
                      final matchingTask = tasks.firstWhere(
                        (t) => t.ulpin == parcel.ulpin || t.parcelId == parcel.ulpin,
                        orElse: () => FieldTaskModel(
                          id: 'TSK-${parcel.ulpin}',
                          ulpin: parcel.ulpin,
                          project: 'Infrastructure Corridor',
                          village: parcel.village,
                          district: parcel.district,
                          state: parcel.state,
                          surveyNumber: parcel.surveyNumber,
                          landAreaSqM: parcel.landAreaSqM,
                          taskType: 'Cadastral Verification',
                          assignedDate: '2026-09-01',
                          dueDate: '2026-09-10',
                          status: parcel.status,
                          latitude: parcel.latitude,
                          longitude: parcel.longitude,
                          instructions: 'Ground verification of corridor alignment and boundary demarcation.',
                        ),
                      );
                      Navigator.of(context).pushNamed(AppRoutes.taskDetails, arguments: matchingTask);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.close, size: 20),
                  onPressed: () => setState(() => _selectedParcel = null),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openCorridorDetails(ProjectCorridorModel corridor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ProjectCorridorBottomSheet(
        corridor: corridor,
        onViewParcels: () {
          Navigator.of(ctx).pop();
          ref.read(projectCorridorControllerProvider.notifier).selectProjectFilter(corridor.id);
          _focusMapOnFilter(corridor.id, [corridor]);
        },
        onClose: () => Navigator.of(ctx).pop(),
      ),
    );
  }

  void _focusMapOnFilter(String filterId, List<ProjectCorridorModel> corridors) {
    if (filterId == 'PRJ-MH-PUN-001') {
      // Focus Pune Ring Road
      _mapController.move(const LatLng(18.5360, 73.7400), 11.5);
    } else if (filterId == 'PRJ-MH-PUN-002') {
      // Focus Pune-Nashik Rail
      _mapController.move(const LatLng(19.2300, 73.9500), 9.2);
    } else {
      // All Projects
      _mapController.move(_puneCenter, 10.2);
    }
  }

  Widget _buildOfflineMapView(
    List<ProjectCorridorModel> corridors,
    List<LandParcelModel> parcels,
    List<FieldTaskModel> tasks,
  ) {
    return Container(
      color: const Color(0xFFF1F5F9),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.warningBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.wifi_off, size: 18, color: AppColors.warning),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Offline Mode: Cached Corridors & Parcel Indices',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Project Summary Cards in Offline Mode
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: corridors.length,
              itemBuilder: (ctx, idx) {
                final c = corridors[idx];
                return GestureDetector(
                  onTap: () => _openCorridorDetails(c),
                  child: Container(
                    width: 250,
                    margin: const EdgeInsets.only(right: 10),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                c.name,
                                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              c.formattedAcquisitionProgress,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${c.type} • ${c.totalLandRequired} Ha Required',
                          style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${c.acquiredParcels}/${c.totalParcels} Parcels Acquired',
                              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'PARCELS ALONG CORRIDORS',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.textMuted),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
              itemCount: parcels.length,
              itemBuilder: (context, index) {
                final p = parcels[index];
                final statusEnum = AcquisitionStatus.fromString(p.status);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    dense: true,
                    title: Text('ULPIN ${p.ulpin} (${p.village})',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    subtitle: Text('Survey: ${p.surveyNumber} • Area: ${p.landAreaSqM.toStringAsFixed(0)} sq.m'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusEnum.backgroundColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        statusEnum.label,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusEnum.color),
                      ),
                    ),
                    onTap: () {
                      final matchingTask = tasks.firstWhere(
                        (t) => t.ulpin == p.ulpin || t.parcelId == p.ulpin,
                        orElse: () => FieldTaskModel(
                          id: 'TSK-${p.ulpin}',
                          ulpin: p.ulpin,
                          project: 'Corridor',
                          village: p.village,
                          district: p.district,
                          state: p.state,
                          surveyNumber: p.surveyNumber,
                          landAreaSqM: p.landAreaSqM,
                          taskType: 'Field Survey',
                          assignedDate: '2026-09-01',
                          dueDate: '2026-09-10',
                          status: p.status,
                          latitude: p.latitude,
                          longitude: p.longitude,
                          instructions: 'Ground inspection',
                        ),
                      );
                      Navigator.of(context).pushNamed(AppRoutes.taskDetails, arguments: matchingTask);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
