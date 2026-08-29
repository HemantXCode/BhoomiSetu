import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../data/models/land_parcel_model.dart';
import '../../data/models/field_task_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/bhoomi_app_bar.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/bhoomi_button.dart';
import '../../core/routing/app_router.dart';
import '../tasks/tasks_controller.dart';

class ParcelMapScreen extends ConsumerStatefulWidget {
  const ParcelMapScreen({super.key});

  @override
  ConsumerState<ParcelMapScreen> createState() => _ParcelMapScreenState();
}

class _ParcelMapScreenState extends ConsumerState<ParcelMapScreen> {
  final MapController _mapController = MapController();
  LandParcelModel? _selectedParcel;
  bool _isOfflineFallback = false;

  // Center coordinate around Pune Ring Road (Bhugaon / Lavale sector)
  static const LatLng _puneCenter = LatLng(18.5124, 73.7314);
  static const LatLng _officerLocation = LatLng(18.5180, 73.7400);

  @override
  Widget build(BuildContext context) {
    final tasksState = ref.watch(tasksControllerProvider);
    final tasks = tasksState.tasks;

    final markers = tasks.map((task) {
      final isSelected = _selectedParcel?.parcelId == task.parcelId;
      return Marker(
        point: LatLng(task.latitude, task.longitude),
        width: 50,
        height: 50,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedParcel = LandParcelModel(
                parcelId: task.parcelId,
                surveyNumber: task.surveyNumber,
                village: task.village,
                district: task.district,
                state: task.state,
                landAreaSqM: task.landAreaSqM,
                latitude: task.latitude,
                longitude: task.longitude,
                landType: 'Agricultural',
                ownerName: 'Assigned Landowner',
                status: task.status,
              );
            });
            _mapController.move(LatLng(task.latitude, task.longitude), 14.5);
          },
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.secondary,
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                child: Text(
                  task.parcelId.replaceAll('PUN-', ''),
                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white),
                ),
              ),
              Icon(
                Icons.location_on,
                size: isSelected ? 28 : 22,
                color: isSelected ? AppColors.primary : AppColors.secondary,
              ),
            ],
          ),
        ),
      );
    }).toList();

    // Officer Location Marker
    markers.add(
      const Marker(
        point: _officerLocation,
        width: 40,
        height: 40,
        child: Column(
          children: [
            Icon(Icons.person_pin_circle, size: 28, color: Color(0xFF10B981)),
          ],
        ),
      ),
    );

    return Scaffold(
      appBar: BhoomiAppBar(
        title: 'Cadastral Parcel Map',
        subtitle: 'Pune Ring Road Corridor',
        actions: [
          IconButton(
            icon: Icon(_isOfflineFallback ? Icons.map : Icons.layers_outlined, color: Colors.white),
            tooltip: 'Toggle Offline Vector Card View',
            onPressed: () => setState(() => _isOfflineFallback = !_isOfflineFallback),
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
            _buildOfflineMapView(tasks)
          else
            FlutterMap(
              mapController: _mapController,
              options: const MapOptions(
                initialCenter: _puneCenter,
                initialZoom: 12.8,
                minZoom: 10.0,
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
                MarkerLayer(markers: markers),
              ],
            ),

          // Map Legend / Overlay
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.92),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: const Row(
                children: [
                  Icon(Icons.circle, size: 10, color: Color(0xFF10B981)),
                  SizedBox(width: 4),
                  Text('Officer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                  SizedBox(width: 8),
                  Icon(Icons.location_on, size: 12, color: AppColors.secondary),
                  SizedBox(width: 2),
                  Text('Parcels', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),

          // Selected Parcel Bottom Sheet Card
          if (_selectedParcel != null)
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Card(
                elevation: 6,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Parcel ${_selectedParcel!.parcelId}',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.secondary),
                              ),
                              Text(
                                '${_selectedParcel!.village} • Survey No: ${_selectedParcel!.surveyNumber}',
                                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                              ),
                            ],
                          ),
                          StatusBadge(status: _selectedParcel!.status, compact: true),
                        ],
                      ),
                      const Divider(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Area: ${_selectedParcel!.landAreaSqM} sq.m', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          Text(
                            'GPS: ${_selectedParcel!.latitude.toStringAsFixed(4)}, ${_selectedParcel!.longitude.toStringAsFixed(4)}',
                            style: const TextStyle(fontSize: 11, fontFamily: 'monospace', color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: BhoomiButton(
                              text: 'OPEN TASK',
                              height: 40,
                              onPressed: () {
                                final matchingTask = tasks.firstWhere(
                                  (t) => t.parcelId == _selectedParcel!.parcelId,
                                  orElse: () => tasks.first,
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
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOfflineMapView(List<FieldTaskModel> tasks) {
    return Container(
      color: const Color(0xFFF1F5F9),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warningBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Row(
              children: [
                Icon(Icons.wifi_off, size: 20, color: AppColors.warning),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Offline Cadastral Index (Cached Parcel Coordinates)',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF92400E)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final t = tasks[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text('Parcel ${t.parcelId} (${t.village})', style: const TextStyle(fontWeight: FontWeight.w700)),
                    subtitle: Text('Lat: ${t.latitude.toStringAsFixed(5)}, Lng: ${t.longitude.toStringAsFixed(5)}'),
                    trailing: StatusBadge(status: t.status, compact: true),
                    onTap: () {
                      Navigator.of(context).pushNamed(AppRoutes.taskDetails, arguments: t);
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
