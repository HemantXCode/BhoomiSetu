import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/field_task_model.dart';
import '../../data/models/field_visit_model.dart';
import '../../data/models/gps_record_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/bhoomi_app_bar.dart';
import '../../core/widgets/bhoomi_button.dart';
import '../../core/utils/geo_utils.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/providers/app_providers.dart';
import '../../core/routing/app_router.dart';
import 'field_visit_controller.dart';

class GPSCaptureScreen extends ConsumerStatefulWidget {
  final FieldTaskModel task;
  final FieldVisitModel visit;

  const GPSCaptureScreen({super.key, required this.task, required this.visit});

  @override
  ConsumerState<GPSCaptureScreen> createState() => _GPSCaptureScreenState();
}

class _GPSCaptureScreenState extends ConsumerState<GPSCaptureScreen> {
  bool _isAcquiring = false;
  GPSRecordModel? _gpsRecord;
  String? _statusMessage;

  @override
  void initState() {
    super.initState();
    _acquireLocation();
  }

  Future<void> _acquireLocation() async {
    setState(() {
      _isAcquiring = true;
      _statusMessage = 'Communicating with GNSS / GPS satellites...';
    });

    final locationService = ref.read(locationServiceProvider);
    final result = await locationService.getCurrentLocation(enableFallback: true);

    if (result.isSuccess && result.record != null) {
      final gps = result.record!;
      final distance = GeoUtils.calculateDistance(
        widget.task.latitude,
        widget.task.longitude,
        gps.latitude,
        gps.longitude,
      );
      final isWithin = GeoUtils.isWithinExpectedRange(distance);

      await ref.read(fieldVisitControllerProvider.notifier).updateGpsRecord(
            gps,
            distance: distance,
            withinRange: isWithin,
          );

      if (mounted) {
        setState(() {
          _isAcquiring = false;
          _gpsRecord = gps;
          _statusMessage = 'GPS Lock Established';
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _isAcquiring = false;
          _statusMessage = result.error ?? 'Unable to acquire satellite lock.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final visitState = ref.watch(fieldVisitControllerProvider);
    final isAccuracyLow = _gpsRecord != null && !GeoUtils.isAccuracyAcceptable(_gpsRecord?.accuracy);

    return Scaffold(
      appBar: BhoomiAppBar(
        title: 'GPS Coordinate Capture',
        subtitle: 'Parcel ${widget.task.parcelId}',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. GNSS Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              _gpsRecord != null ? Icons.satellite_alt : Icons.satellite_outlined,
                              size: 22,
                              color: _gpsRecord != null ? AppColors.success : AppColors.warning,
                            ),
                            const SizedBox(width: 8),
                            const Text('GNSS Satellite Lock', style: AppTextStyles.h3),
                          ],
                        ),
                        if (_isAcquiring)
                          const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        else
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 20, color: AppColors.primary),
                            tooltip: 'Refresh GPS',
                            onPressed: _acquireLocation,
                          ),
                      ],
                    ),
                    const Divider(height: 20),
                    Text(
                      _statusMessage ?? 'Acquiring high-precision coordinates...',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _gpsRecord != null ? AppColors.success : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Low Accuracy Warning Banner if applicable
            if (isAccuracyLow) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.warningBg,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.warning.withOpacity(0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, size: 22, color: AppColors.warning),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'GPS accuracy is low (${GeoUtils.formatAccuracy(_gpsRecord?.accuracy)}). Move to an open area with direct sky view and refresh.',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 2. Acquired Coordinates Table Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Captured Field Coordinates', style: AppTextStyles.h3),
                    const SizedBox(height: 14),
                    _buildCoordinateRow('Latitude', GeoUtils.formatCoordinate(_gpsRecord?.latitude), Icons.north),
                    _buildCoordinateRow('Longitude', GeoUtils.formatCoordinate(_gpsRecord?.longitude), Icons.east),
                    _buildCoordinateRow('GPS Accuracy', GeoUtils.formatAccuracy(_gpsRecord?.accuracy), Icons.gps_fixed, isHighlight: true),
                    _buildCoordinateRow('Altitude', _gpsRecord?.altitude != null ? '${_gpsRecord!.altitude!.toStringAsFixed(1)} m (MSL)' : '--', Icons.terrain),
                    _buildCoordinateRow('Capture Timestamp', DateFormatter.formatDateTime(_gpsRecord?.timestamp), Icons.access_time),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Cadastral Reference Comparison
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Cadastral Benchmark Reference', style: AppTextStyles.h3),
                    const SizedBox(height: 10),
                    Text(
                      'Expected Location (Cadastral Center): ${widget.task.latitude.toStringAsFixed(6)}, ${widget.task.longitude.toStringAsFixed(6)}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 6),
                    if (visitState.calculatedDistanceMeters != null) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: visitState.isWithinRange ? AppColors.successBg : AppColors.warningBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              visitState.isWithinRange ? Icons.check_circle : Icons.warning_amber,
                              size: 14,
                              color: visitState.isWithinRange ? AppColors.success : AppColors.warning,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Distance to Benchmark: ${visitState.calculatedDistanceMeters!.toStringAsFixed(1)}m (${visitState.isWithinRange ? "Within Expected Range" : "Outside Expected Range"})',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: visitState.isWithinRange ? AppColors.success : AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 4. Action Buttons
            BhoomiButton(
              text: 'CONFIRM GPS & PROCEED',
              icon: Icons.check,
              isLoading: _isAcquiring,
              onPressed: _gpsRecord == null
                  ? null
                  : () {
                      Navigator.of(context).pushNamed(
                        AppRoutes.parcelVerification,
                        arguments: {'task': widget.task, 'visit': widget.visit},
                      );
                    },
            ),
            const SizedBox(height: 10),
            BhoomiButton(
              text: 'RE-ACQUIRE GPS POSITION',
              type: ButtonType.outline,
              icon: Icons.my_location,
              onPressed: _acquireLocation,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCoordinateRow(String label, String value, IconData icon, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: AppColors.textMuted),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              fontFamily: 'monospace',
              color: isHighlight ? AppColors.primary : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
