import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/field_task_model.dart';
import '../../data/models/field_visit_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/bhoomi_app_bar.dart';
import '../../core/widgets/bhoomi_button.dart';
import '../../core/routing/app_router.dart';
import 'field_visit_controller.dart';

class ParcelVerificationScreen extends ConsumerStatefulWidget {
  final FieldTaskModel task;
  final FieldVisitModel visit;

  const ParcelVerificationScreen({super.key, required this.task, required this.visit});

  @override
  ConsumerState<ParcelVerificationScreen> createState() => _ParcelVerificationScreenState();
}

class _ParcelVerificationScreenState extends ConsumerState<ParcelVerificationScreen> {
  bool _isConfirmed = true;
  final _remarksController = TextEditingController();

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final visitState = ref.watch(fieldVisitControllerProvider);
    final distance = visitState.calculatedDistanceMeters ?? 0.0;
    final isWithin = visitState.isWithinRange;

    return Scaffold(
      appBar: BhoomiAppBar(
        title: 'Parcel Verification',
        subtitle: 'Parcel ${widget.task.parcelId}',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Parcel Proximity Verification Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      alignment: WrapAlignment.spaceBetween,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        const Text('Cadastral Alignment Check', style: AppTextStyles.h3),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: isWithin ? AppColors.successBg : AppColors.warningBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: isWithin ? AppColors.success : AppColors.warning),
                          ),
                          child: Text(
                            isWithin ? 'WITHIN EXPECTED RANGE' : 'OUTSIDE EXPECTED RANGE',
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              color: isWithin ? AppColors.success : AppColors.warning,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    _buildVerificationRow('Assigned Reference Location', '${widget.task.latitude.toStringAsFixed(6)}, ${widget.task.longitude.toStringAsFixed(6)}'),
                    _buildVerificationRow('Captured Field GPS Location', '${visitState.currentGps?.latitude.toStringAsFixed(6) ?? widget.task.latitude.toStringAsFixed(6)}, ${visitState.currentGps?.longitude.toStringAsFixed(6) ?? widget.task.longitude.toStringAsFixed(6)}'),
                    _buildVerificationRow('Calculated Proximity Offset', '${distance.toStringAsFixed(1)} meters', isHighlight: true),
                    _buildVerificationRow('Survey & Village Records', '${widget.task.village}, Survey No: ${widget.task.surveyNumber}'),
                    _buildVerificationRow('Total Land Parcel Area', '${widget.task.landAreaSqM} sq. meters'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Official Boundary Notice Disclaimer
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, size: 18, color: AppColors.textMuted),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'GPS distance confirms proximity to assigned cadastral centroid. Final legal boundary demarcation is subject to official joint measurements and DGPS cadastral records.',
                      style: TextStyle(fontSize: 11.5, height: 1.4, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Officer Confirmation Selection
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Officer Verification Determination', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    RadioListTile<bool>(
                      value: true,
                      groupValue: _isConfirmed,
                      title: const Text(
                        'Confirm On-Site Parcel Alignment',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      subtitle: const Text(
                        'Ground features and reference points match cadastral records.',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => _isConfirmed = val ?? true),
                    ),
                    const Divider(height: 8),
                    RadioListTile<bool>(
                      value: false,
                      groupValue: _isConfirmed,
                      title: const Text(
                        'Mark Location Mismatch / Discrepancy',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.danger),
                      ),
                      subtitle: const Text(
                        'Physical parcel or markers deviate significantly from survey record.',
                        style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                      ),
                      activeColor: AppColors.danger,
                      contentPadding: EdgeInsets.zero,
                      onChanged: (val) => setState(() => _isConfirmed = val ?? false),
                    ),
                    const SizedBox(height: 12),
                    const Text('Officer Verification Notes (Optional)', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _remarksController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Ground boundaries match village map corner stones.',
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 4. CTA Button
            BhoomiButton(
              text: 'CONTINUE TO INSPECTION FORM',
              icon: Icons.assignment_turned_in_outlined,
              onPressed: () {
                Navigator.of(context).pushNamed(
                  AppRoutes.inspectionForm,
                  arguments: {'task': widget.task, 'visit': widget.visit},
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 5,
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isHighlight ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
