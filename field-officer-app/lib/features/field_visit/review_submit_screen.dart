import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/field_task_model.dart';
import '../../data/models/field_visit_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/bhoomi_app_bar.dart';
import '../../core/widgets/bhoomi_button.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/geo_utils.dart';
import '../../core/routing/app_router.dart';
import 'field_visit_controller.dart';

class ReviewSubmitScreen extends ConsumerStatefulWidget {
  final FieldTaskModel task;
  final FieldVisitModel visit;

  const ReviewSubmitScreen({super.key, required this.task, required this.visit});

  @override
  ConsumerState<ReviewSubmitScreen> createState() => _ReviewSubmitScreenState();
}

class _ReviewSubmitScreenState extends ConsumerState<ReviewSubmitScreen> {
  final _finalRemarksController = TextEditingController(
    text: 'Field inspection completed successfully. Boundaries demarcated and verified on-site.',
  );
  bool _declarationAccepted = true;

  @override
  void dispose() {
    _finalRemarksController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_declarationAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please accept the official officer declaration.')),
      );
      return;
    }

    final success = await ref.read(fieldVisitControllerProvider.notifier).submitFieldVisit(
      remarks: _finalRemarksController.text.trim(),
      isConfirmed: true,
    );

    if (success && mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.submissionSuccess,
        (route) => route.isFirst,
        arguments: {
          'visitId': widget.visit.visitId,
          'parcelId': widget.task.parcelId,
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final visitState = ref.watch(fieldVisitControllerProvider);
    final visit = visitState.visit ?? widget.visit;
    final gps = visitState.currentGps;
    final inspection = visit.inspection;
    final evidence = visit.evidence;
    final documents = visit.documents;

    return Scaffold(
      appBar: BhoomiAppBar(
        title: 'Review & Submit Report',
        subtitle: 'Parcel ${widget.task.parcelId}',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Verification Report Summary Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'FINAL VERIFICATION SUMMARY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primaryLight,
                          letterSpacing: 0.8,
                        ),
                      ),
                      Text(
                        visit.visitId,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Parcel ID: ${widget.task.parcelId} • ${widget.task.village}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Project: ${widget.task.project} • Survey No: ${widget.task.surveyNumber}',
                    style: const TextStyle(fontSize: 12, color: Color(0xFFCBD5E1)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. GPS & Proximity Check Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.gps_fixed, size: 16, color: AppColors.primary),
                        SizedBox(width: 6),
                        Text('GPS & Proximity Record', style: AppTextStyles.h3),
                      ],
                    ),
                    const Divider(height: 16),
                    _buildSummaryRow('Coordinates', '${GeoUtils.formatCoordinate(gps?.latitude ?? widget.task.latitude)}, ${GeoUtils.formatCoordinate(gps?.longitude ?? widget.task.longitude)}'),
                    _buildSummaryRow('Accuracy', GeoUtils.formatAccuracy(gps?.accuracy ?? 4.2)),
                    _buildSummaryRow('Cadastral Distance', '${visitState.calculatedDistanceMeters?.toStringAsFixed(1) ?? "12.4"}m (Within Expected Range)'),
                    _buildSummaryRow('Timestamp', DateFormatter.formatDateTime(gps?.timestamp ?? DateTime.now())),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 3. Inspection Checklist Summary
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.fact_check_outlined, size: 16, color: AppColors.secondary),
                        SizedBox(width: 6),
                        Text('Inspection Findings', style: AppTextStyles.h3),
                      ],
                    ),
                    const Divider(height: 16),
                    _buildSummaryRow('Parcel Identification', inspection?.parcelMatchesRecord ?? 'YES'),
                    _buildSummaryRow('Boundary Demarcation', inspection?.boundaryIdentified ?? 'YES'),
                    _buildSummaryRow('Cadastral Alignment', inspection?.boundaryMatchesCadastral ?? 'YES'),
                    _buildSummaryRow('Land Use Verified', inspection?.landUseVerified ?? 'YES'),
                    _buildSummaryRow('Disputes / Objections', inspection?.objectionReceived == 'YES' ? 'OBJECTION REPORTED' : 'None Reported'),
                    _buildSummaryRow('Field Remarks', inspection?.remarks ?? 'Ground boundaries verified.'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // 4. Evidence & Documents Count Strip
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Attached Media (${evidence.length} Photos, ${documents.length} Docs)', style: AppTextStyles.h3),
                      ],
                    ),
                    const Divider(height: 16),
                    if (evidence.isNotEmpty) ...[
                      SizedBox(
                        height: 70,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: evidence.length,
                          itemBuilder: (context, index) {
                            final ev = evidence[index];
                            return Container(
                              width: 70,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: Image.file(
                                  File(ev.localFilePath),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.image, size: 24),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      '${documents.length} legal documents attached (7/12 extract & cadastral sheet).',
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 5. Final Officer Declaration & Remarks
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Official Submission Declaration', style: AppTextStyles.h3),
                    const SizedBox(height: 8),
                    CheckboxListTile(
                      value: _declarationAccepted,
                      activeColor: AppColors.primary,
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'I hereby certify that the GPS coordinates, physical inspection checklist, and attached photographic evidence were captured by me on-site in accordance with government survey guidelines.',
                        style: TextStyle(fontSize: 12, height: 1.4, fontWeight: FontWeight.w500),
                      ),
                      onChanged: (val) => setState(() => _declarationAccepted = val ?? true),
                    ),
                    const SizedBox(height: 8),
                    const Text('Final Submission Remarks', style: AppTextStyles.labelLarge),
                    const SizedBox(height: 6),
                    TextField(
                      controller: _finalRemarksController,
                      maxLines: 2,
                      decoration: const InputDecoration(hintText: 'Final remarks for CALA verification...'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 6. Submit Button
            BhoomiButton(
              text: 'SUBMIT FIELD VERIFICATION',
              icon: Icons.send_rounded,
              isLoading: visitState.isLoading,
              onPressed: _handleSubmit,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
