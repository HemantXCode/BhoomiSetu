import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/field_task_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/bhoomi_app_bar.dart';
import '../../core/widgets/bhoomi_button.dart';
import '../../core/routing/app_router.dart';
import '../../core/utils/date_formatter.dart';
import 'field_visit_controller.dart';

class StartVisitScreen extends ConsumerStatefulWidget {
  final FieldTaskModel task;

  const StartVisitScreen({super.key, required this.task});

  @override
  ConsumerState<StartVisitScreen> createState() => _StartVisitScreenState();
}

class _StartVisitScreenState extends ConsumerState<StartVisitScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(fieldVisitControllerProvider.notifier).startOrResumeVisit(widget.task);
    });
  }

  @override
  Widget build(BuildContext context) {
    final visitState = ref.watch(fieldVisitControllerProvider);
    final visit = visitState.visit;

    return Scaffold(
      appBar: BhoomiAppBar(
        title: 'Start Field Visit',
        subtitle: 'Parcel ${widget.task.parcelId}',
        showBack: true,
      ),
      body: visitState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Visit Session Header
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: const [
                        BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'OFFICIAL FIELD SESSION',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryLight,
                                letterSpacing: 0.8,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                visit?.visitId ?? 'INITIALIZING',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'ULPIN: ${widget.task.ulpin} (${widget.task.village})',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Survey No: ${widget.task.surveyNumber} • Area: ${widget.task.landAreaSqM} sq.m',
                          style: const TextStyle(fontSize: 13, color: Color(0xFFCBD5E1)),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        const Divider(color: Colors.white24, height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Started: ${DateFormatter.formatDateTime(DateTime.now())}',
                                style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.shield_outlined, size: 14, color: AppColors.primaryLight),
                                SizedBox(width: 4),
                                Text(
                                  'Geo-Verified Session',
                                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primaryLight),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // 2. Field Verification Workflow Roadmap
                  const Text('Field Verification Workflow', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  _buildWorkflowStep('1', 'GPS Coordinate Capture', 'Acquire real device satellite coordinates on-site.', Icons.gps_fixed, isCurrent: true),
                  _buildWorkflowStep('2', 'Parcel Location Verification', 'Verify distance offset against assigned cadastral point.', Icons.check_circle_outline),
                  _buildWorkflowStep('3', '5-Section Inspection Checklist', 'Complete land condition, boundary, and dispute form.', Icons.fact_check_outlined),
                  _buildWorkflowStep('4', 'Photographic Evidence Capture', 'Capture geo-tagged photos of boundary and structures.', Icons.camera_alt_outlined),
                  _buildWorkflowStep('5', 'Document Review & Upload', 'Attach supporting ownership and survey documents.', Icons.upload_file_outlined),
                  _buildWorkflowStep('6', 'Officer Remarks & Final Submission', 'Review integrity check and digitally submit report.', Icons.send_outlined),

                  const SizedBox(height: 24),

                  // 3. CTA Button
                  BhoomiButton(
                    text: 'PROCEED TO GPS CAPTURE',
                    icon: Icons.my_location,
                    onPressed: () {
                      if (visit != null) {
                        Navigator.of(context).pushNamed(
                          AppRoutes.gpsCapture,
                          arguments: {'task': widget.task, 'visit': visit},
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  Widget _buildWorkflowStep(String number, String title, String subtitle, IconData icon, {bool isCurrent = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrent ? AppColors.primaryContainer.withOpacity(0.4) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isCurrent ? AppColors.primary : AppColors.cardBorder,
          width: isCurrent ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isCurrent ? AppColors.primary : const Color(0xFFE2E8F0),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isCurrent ? Colors.white : AppColors.textSecondary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isCurrent ? AppColors.primaryDark : AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
              ],
            ),
          ),
          Icon(icon, size: 20, color: isCurrent ? AppColors.primary : AppColors.textMuted),
        ],
      ),
    );
  }
}
