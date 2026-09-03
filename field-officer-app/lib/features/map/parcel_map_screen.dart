import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:field_officer_app/data/models/land_parcel_model.dart';
import 'package:field_officer_app/data/models/field_task_model.dart';
import 'package:field_officer_app/data/models/project_corridor_model.dart';
import 'package:field_officer_app/core/theme/app_colors.dart';
import 'package:field_officer_app/core/widgets/bhoomi_app_bar.dart';
import 'package:field_officer_app/core/providers/app_providers.dart';
import 'package:field_officer_app/features/tasks/tasks_controller.dart';
import 'project_corridor_controller.dart';
import 'widgets/project_selector_bar.dart';
import 'widgets/corridor_legend_widget.dart';
import 'widgets/project_corridor_bottom_sheet.dart';
import 'widgets/gis_layer_control_bottom_sheet.dart';
import 'widgets/ulpin_search_modal.dart';
import 'widgets/parcel_details_bottom_sheet.dart';
import 'widgets/mobile_gis_kpi_card.dart';

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

  // Layer Visibility Options
  GISLayerOptions _layerOptions = const GISLayerOptions();

  // Officer GPS Position
  LatLng? _officerLocation;
  bool _isGpsLoading = false;
  String? _gpsStatusMessage;

  // Center coordinate around Pune Corridor
  static const LatLng _defaultCenter = LatLng(18.5720, 73.7290);

  @override
  void initState() {
    super.initState();
    _fetchRealGpsLocation();
  }

  Future<void> _fetchRealGpsLocation() async {
    setState(() {
      _isGpsLoading = true;
      _gpsStatusMessage = 'Acquiring GPS...';
    });

    try {
      final locService = ref.read(locationServiceProvider);
      final result = await locService.getCurrentLocation();
      if (result.isSuccess && result.record != null) {
        if (mounted) {
          setState(() {
            _officerLocation = LatLng(result.record!.latitude, result.record!.longitude);
            _isGpsLoading = false;
            _gpsStatusMessage = 'GPS active (±${result.record!.accuracy.toStringAsFixed(1)}m)';
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _isGpsLoading = false;
            _gpsStatusMessage = result.error ?? 'GPS unavailable';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGpsLoading = false;
          _gpsStatusMessage = 'GPS error: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksControllerProvider);
    final tasks = tasksState.tasks;

    final corridorState = ref.watch(projectCorridorControllerProvider);
    final corridorCtrl = ref.read(projectCorridorControllerProvider.notifier);
    final visibleCorridors = corridorState.visibleCorridors;

    // Collect visible parcels based on project filter and layer options
    List<LandParcelModel> rawParcels = corridorState.visibleParcels;
    if (rawParcels.isEmpty) {
      // Fallback from tasks if corridors empty
      rawParcels = tasks.map((t) => LandParcelModel(
        ulpin: t.ulpin,
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
    }

    final displayedParcels = _layerOptions.showAffectedOnly
        ? rawParcels.where((p) => p.isAffected).toList()
        : rawParcels;

    // 1. Build Parcel Polygons (Layer 2)
    final polygons = <Polygon>[];
    if (_layerOptions.showParcels) {
      for (final parcel in displayedParcels) {
        if (parcel.polygon.isNotEmpty) {
          final isSelected = _selectedParcel?.ulpin == parcel.ulpin;
          final statusEnum = AcquisitionStatus.fromString(parcel.status);

          Color fillColor;
          Color borderColor;
          double borderWidth = isSelected ? 3.5 : 2.0;

          if (!_layerOptions.showAcquisitionColors) {
            fillColor = isSelected ? Colors.blue.withValues(alpha: 0.6) : Colors.blue.withValues(alpha: 0.2);
            borderColor = isSelected ? Colors.blue.shade900 : Colors.blue.shade700;
          } else {
            switch (statusEnum) {
              case AcquisitionStatus.acquired:
                fillColor = isSelected
                    ? const Color(0xFF22C55E).withValues(alpha: 0.70)
                    : const Color(0xFF22C55E).withValues(alpha: 0.40);
                borderColor = isSelected ? const Color(0xFF0F172A) : const Color(0xFF15803D);
                break;
              case AcquisitionStatus.inProgress:
                fillColor = isSelected
                    ? const Color(0xFFF97316).withValues(alpha: 0.70)
                    : const Color(0xFFF97316).withValues(alpha: 0.40);
                borderColor = isSelected ? const Color(0xFF0F172A) : const Color(0xFFC2410C);
                break;
              case AcquisitionStatus.pending:
                fillColor = isSelected
                    ? const Color(0xFFEF4444).withValues(alpha: 0.65)
                    : const Color(0xFFEF4444).withValues(alpha: 0.35);
                borderColor = isSelected ? const Color(0xFF0F172A) : const Color(0xFFDC2626);
                break;
            }
          }

          polygons.add(
            Polygon(
              points: parcel.polygon,
              color: fillColor,
              borderColor: borderColor,
              borderStrokeWidth: borderWidth,
              pattern: statusEnum == AcquisitionStatus.pending && !isSelected
                  ? StrokePattern.dashed(segments: const [6, 4])
                  : const StrokePattern.solid(),
            ),
          );
        }
      }
    }

    // 2. Build Polylines: RoW Buffer + Multi-Layer Highway Corridor (Layers 3 & 4)
    final polylines = <Polyline>[];
    if (_layerOptions.showCorridors) {
      for (final corridor in visibleCorridors) {
        final route = corridor.routeGeometry;

        // 2a. 70m Statutory RoW Prototype Band (Visibly overlapping parcels)
        if (route.isNotEmpty) {
          polylines.add(
            Polyline(
              points: route,
              strokeWidth: 34.0,
              color: const Color(0xFFFF6B00).withValues(alpha: 0.22),
              strokeCap: StrokeCap.round,
              strokeJoin: StrokeJoin.round,
            ),
          );
          // RoW boundary guide lines
          polylines.add(
            Polyline(
              points: route,
              strokeWidth: 1.5,
              color: const Color(0xFFC2410C).withValues(alpha: 0.60),
              strokeCap: StrokeCap.round,
              strokeJoin: StrokeJoin.round,
            ),
          );
        }

        // 2b. Multi-Layer Highway Road (Casing + Separator + Status Centerline)
        for (final segment in corridor.segments) {
          if (segment.routeGeometry.isNotEmpty) {
            // Dark outer casing
            polylines.add(
              Polyline(
                points: segment.routeGeometry,
                strokeWidth: 14.0,
                color: const Color(0xFF0F172A).withValues(alpha: 0.95),
                strokeCap: StrokeCap.round,
                strokeJoin: StrokeJoin.round,
              ),
            );
            // White road separator / divider
            polylines.add(
              Polyline(
                points: segment.routeGeometry,
                strokeWidth: 9.0,
                color: const Color(0xFFFFFFFF).withValues(alpha: 0.95),
                strokeCap: StrokeCap.round,
                strokeJoin: StrokeJoin.round,
              ),
            );
            // Status-colored highway centerline
            polylines.add(
              Polyline(
                points: segment.routeGeometry,
                strokeWidth: 5.0,
                color: segment.status.color,
                strokeCap: StrokeCap.round,
                strokeJoin: StrokeJoin.round,
              ),
            );
          }
        }
      }
    }

    // 3. Build Markers: ULPIN Labels + Corridor Endpoints + Officer GPS (Layers 5 & 6)
    final markers = <Marker>[];

    // 3a. Centroid ULPIN Labels
    if (_layerOptions.showUlpinLabels) {
      for (final parcel in displayedParcels) {
        final isSelected = _selectedParcel?.ulpin == parcel.ulpin;
        final statusEnum = AcquisitionStatus.fromString(parcel.status);
        final centroid = parcel.centroid;

        final shortUlpin = parcel.ulpin
            .replaceAll('ULPIN-MH-PUN-', '')
            .replaceAll('ULPIN-', '')
            .replaceAll('PUN-PRR-', 'P-')
            .replaceAll('PRR-', 'P-')
            .replaceAll('PNR-HAD-', 'HAD-')
            .replaceAll('PNR-CHK-', 'CHK-')
            .replaceAll('PNR-MCH-', 'MCH-')
            .replaceAll('PNR-SNG-', 'SNG-');

        markers.add(
          Marker(
            point: centroid,
            width: isSelected ? 120 : 64,
            height: isSelected ? 36 : 28,
            child: GestureDetector(
              onTap: () => _handleSelectParcel(parcel),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF0F172A)
                      : Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isSelected ? const Color(0xFF38BDF8) : statusEnum.color,
                    width: isSelected ? 2.0 : 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: statusEnum.color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 3),
                    Flexible(
                      child: Text(
                        isSelected ? '${parcel.ulpin} • ${parcel.areaHectares.toStringAsFixed(1)}Ha' : shortUlpin,
                        style: TextStyle(
                          fontSize: isSelected ? 9.5 : 8.5,
                          fontWeight: FontWeight.w800,
                          fontFamily: 'monospace',
                          color: isSelected ? Colors.white : AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }
    }

    // 3b. Corridor Endpoints (Point A & Point B)
    if (_layerOptions.showCorridors) {
      for (final corridor in visibleCorridors) {
        final isRail = corridor.type.toLowerCase().contains('rail');

        // Point A
        markers.add(
          Marker(
            point: corridor.startCoordinate,
            width: 100,
            height: 38,
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

        // Point B
        markers.add(
          Marker(
            point: corridor.endCoordinate,
            width: 100,
            height: 38,
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
    }

    // 3c. Field Officer Real GPS Marker
    if (_layerOptions.showOfficerGps && _officerLocation != null) {
      markers.add(
        Marker(
          point: _officerLocation!,
          width: 46,
          height: 46,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: const [
                    BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
                  ],
                ),
                child: const Icon(Icons.person, size: 16, color: Colors.white),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'YOU',
                  style: TextStyle(fontSize: 7, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Subtitle based on active project
    String subtitle = 'Project Land Acquisition GIS';
    if (corridorState.selectedProjectFilter != 'ALL' && visibleCorridors.isNotEmpty) {
      subtitle = visibleCorridors.first.name;
    }

    return Scaffold(
      appBar: BhoomiAppBar(
        title: 'Corridor & Parcel Map',
        subtitle: subtitle,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            tooltip: 'Search ULPIN',
            onPressed: () => _openSearchDialog(corridorState.visibleParcels),
          ),
          IconButton(
            icon: const Icon(Icons.layers_outlined, color: Colors.white),
            tooltip: 'GIS Layers',
            onPressed: _openLayersSheet,
          ),
          IconButton(
            icon: Icon(_isOfflineFallback ? Icons.map : Icons.grid_view, color: Colors.white),
            tooltip: 'Toggle Offline Vector Card View',
            onPressed: () => setState(() => _isOfflineFallback = !_isOfflineFallback),
          ),
        ],
      ),
      body: Stack(
        children: [
          // 1. Map Canvas or Offline Fallback Card View
          if (_isOfflineFallback)
            _buildOfflineMapView(visibleCorridors, displayedParcels, tasks)
          else
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _defaultCenter,
                initialZoom: 11.0,
                minZoom: 7.5,
                maxZoom: 18.0,
                onTap: (_, point) {
                  // Find if a parcel polygon contains or is closest to this tap
                  _handleMapTap(point, displayedParcels);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'in.gov.bhoomisetu.field_officer_app',
                ),
                PolygonLayer(polygons: polygons),
                PolylineLayer(polylines: polylines),
                MarkerLayer(markers: markers),
              ],
            ),

          // 2. Top Project Selector Bar (Horizontally scrollable, no overflow)
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

          // 3. Compact KPI Summary Ribbon (Below Project Selector)
          if (!_isOfflineFallback && visibleCorridors.isNotEmpty)
            Positioned(
              top: 62,
              left: 10,
              right: 10,
              child: MobileGisKpiCard(
                corridor: visibleCorridors.first,
                onExpand: () => _openCorridorDetails(visibleCorridors.first),
              ),
            ),

          // 4. Map Status Legend (Top Left under KPI card)
          if (!_isOfflineFallback)
            Positioned(
              top: 134,
              left: 10,
              child: CorridorLegendWidget(
                isCollapsed: _isLegendCollapsed,
                onToggleCollapse: () {
                  setState(() => _isLegendCollapsed = !_isLegendCollapsed);
                },
              ),
            ),

          // 5. Floating Action Buttons (Bottom Right)
          if (!_isOfflineFallback)
            Positioned(
              bottom: 20,
              right: 14,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Search FAB
                  FloatingActionButton.small(
                    heroTag: 'gis_search_fab',
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    tooltip: 'Search ULPIN',
                    onPressed: () => _openSearchDialog(corridorState.visibleParcels),
                    child: const Icon(Icons.search, size: 20),
                  ),
                  const SizedBox(height: 8),

                  // Layers FAB
                  FloatingActionButton.small(
                    heroTag: 'gis_layers_fab',
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.secondary,
                    tooltip: 'GIS Layers',
                    onPressed: _openLayersSheet,
                    child: const Icon(Icons.layers, size: 20),
                  ),
                  const SizedBox(height: 8),

                  // Fit Corridor FAB
                  FloatingActionButton.small(
                    heroTag: 'gis_fit_corridor_fab',
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    tooltip: 'Fit Active Corridor & RoW',
                    onPressed: () {
                      _focusMapOnFilter(corridorState.selectedProjectFilter, corridorState.corridors);
                    },
                    child: const Icon(Icons.crop_free, size: 20),
                  ),
                  const SizedBox(height: 8),

                  // Recenter GPS FAB (◎)
                  FloatingActionButton.small(
                    heroTag: 'gis_recenter_gps_fab',
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF10B981),
                    tooltip: 'Recenter on Officer GPS',
                    onPressed: () {
                      if (_officerLocation != null) {
                        _mapController.move(_officerLocation!, 15.0);
                      } else {
                        _fetchRealGpsLocation();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(_gpsStatusMessage ?? 'Fetching GPS coordinates...'),
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: _isGpsLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF10B981)),
                          )
                        : const Icon(Icons.my_location, size: 20),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _handleSelectParcel(LandParcelModel parcel) {
    setState(() {
      _selectedParcel = parcel;
    });

    ref.read(projectCorridorControllerProvider.notifier).highlightParcel(parcel.ulpin);
    _mapController.move(parcel.centroid, 14.2);

    _openParcelBottomSheet(parcel);
  }

  void _handleMapTap(LatLng tapPoint, List<LandParcelModel> parcels) {
    // Find closest parcel within threshold
    LandParcelModel? closestParcel;
    double minDistance = double.infinity;
    const Distance distance = Distance();

    for (final p in parcels) {
      final d = distance.as(LengthUnit.Meter, tapPoint, p.centroid);
      if (d < 500 && d < minDistance) {
        minDistance = d;
        closestParcel = p;
      }
    }

    if (closestParcel != null) {
      _handleSelectParcel(closestParcel);
    }
  }

  void _openParcelBottomSheet(LandParcelModel parcel) {
    final tasks = ref.read(tasksControllerProvider).tasks;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ParcelDetailsBottomSheet(
        parcel: parcel,
        tasks: tasks,
        onClose: () {
          Navigator.of(ctx).pop();
          setState(() => _selectedParcel = null);
        },
      ),
    );
  }

  void _openSearchDialog(List<LandParcelModel> parcels) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ULPINSearchModal(
        allParcels: parcels,
        onSelectParcel: _handleSelectParcel,
      ),
    );
  }

  void _openLayersSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => GISLayerControlBottomSheet(
        options: _layerOptions,
        onChanged: (newOptions) {
          setState(() {
            _layerOptions = newOptions;
          });
        },
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
      _mapController.move(const LatLng(18.5720, 73.7290), 11.2);
    } else if (filterId == 'PRJ-MH-PUN-002') {
      // Focus Pune-Nashik Rail
      _mapController.move(const LatLng(19.2200, 73.9500), 9.0);
    } else {
      // All Projects
      _mapController.move(_defaultCenter, 10.2);
    }
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
                  style: const TextStyle(fontSize: 7.5, fontWeight: FontWeight.w800, color: Colors.white70),
                ),
                Text(
                  locationName,
                  style: const TextStyle(fontSize: 9.5, fontWeight: FontWeight.w700, color: Colors.white),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: const Row(
              children: [
                Icon(Icons.wifi_off, size: 18, color: AppColors.warning),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Offline Mode: Cached GIS Corridors & Parcel Polygons',
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
                    title: Text('${p.ulpin} (${p.village})',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                    subtitle: Text('${p.surveyNumber} • Area: ${p.areaHectares.toStringAsFixed(2)} Ha (${p.landAreaSqM.toStringAsFixed(0)} sq.m)'),
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
                    onTap: () => _handleSelectParcel(p),
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
