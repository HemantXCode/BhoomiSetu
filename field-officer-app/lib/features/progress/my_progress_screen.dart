import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/bhoomi_app_bar.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/loading_view.dart';
import '../dashboard/dashboard_controller.dart';

class MyProgressScreen extends ConsumerWidget {
  const MyProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashState = ref.watch(dashboardControllerProvider);
    final stats = dashState.stats;

    final double completionRate = stats.assigned > 0
        ? ((stats.completed + stats.verified) / stats.assigned) * 100
        : 0.0;

    return Scaffold(
      appBar: const BhoomiAppBar(
        title: 'My Work Progress',
        subtitle: 'Field Performance Analytics',
        showBack: true,
      ),
      body: dashState.isLoading
          ? const LoadingView(message: 'Calculating progress statistics...')
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Overall Completion Summary Banner Card
                  Card(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [AppColors.secondary, AppColors.secondaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'OVERALL SURVEY COMPLETION',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.primaryLight,
                              letterSpacing: 0.8,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${completionRate.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -1,
                                ),
                              ),
                              Text(
                                '${stats.completed + stats.verified} of ${stats.assigned} Parcels',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFCBD5E1),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: completionRate / 100,
                              minHeight: 8,
                              backgroundColor: Colors.white24,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Detailed Breakdown Grid
                  const Text('Lifecycle Stage Breakdown', style: AppTextStyles.h3),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          title: 'Assigned Total',
                          value: '${stats.assigned}',
                          icon: Icons.assignment_outlined,
                          accentColor: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: MetricCard(
                          title: 'In Progress',
                          value: '${stats.inProgress}',
                          icon: Icons.pending_actions,
                          accentColor: AppColors.info,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          title: 'Verified & Approved',
                          value: '${stats.verified}',
                          icon: Icons.verified,
                          accentColor: AppColors.success,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: MetricCard(
                          title: 'Pending CALA Review',
                          value: '${stats.completed}',
                          icon: Icons.hourglass_bottom,
                          accentColor: const Color(0xFF7C3AED),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          title: 'Pending Survey',
                          value: '${stats.pending}',
                          icon: Icons.schedule,
                          accentColor: AppColors.warning,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: MetricCard(
                          title: 'Rejected / Rework',
                          value: '${stats.rejected}',
                          icon: Icons.cancel_outlined,
                          accentColor: AppColors.danger,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Quality & Accuracy Metrics
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Survey Quality Benchmarks', style: AppTextStyles.h3),
                          const SizedBox(height: 14),
                          _buildQualityRow('Average GPS Accuracy', '±3.8 meters', Icons.gps_fixed),
                          _buildQualityRow('Photo Evidence Compliance', '100% (Geo-Tagged)', Icons.camera_alt_outlined),
                          _buildQualityRow('Sync Reliability', '100% Offline Queued', Icons.cloud_done_outlined),
                          _buildQualityRow('On-Time Completion', '94.2%', Icons.timer_outlined),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  Widget _buildQualityRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          const Spacer(),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ],
      ),
    );
  }
}
