import 'package:flutter/material.dart';
import '../../data/models/field_task_model.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/widgets/bhoomi_app_bar.dart';
import '../../core/widgets/bhoomi_button.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/routing/app_router.dart';

class TaskDetailsScreen extends StatelessWidget {
  final FieldTaskModel task;

  const TaskDetailsScreen({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: BhoomiAppBar(
        title: 'Task Details',
        subtitle: 'Parcel ${task.parcelId}',
        showBack: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Parcel Header Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'ULPIN: ${task.ulpin}',
                                style: AppTextStyles.h3,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Survey Number: ${task.surveyNumber}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        StatusBadge(status: task.status, compact: true),
                      ],
                    ),
                    const Divider(height: 24),
                    _buildInfoRow(Icons.account_tree_outlined, 'Project', task.project),
                    _buildInfoRow(Icons.location_city_outlined, 'Village / Taluka', '${task.village}, ${task.district}'),
                    _buildInfoRow(Icons.map_outlined, 'District & State', '${task.district}, ${task.state}'),
                    _buildInfoRow(Icons.aspect_ratio_outlined, 'Land Area', '${task.landAreaSqM} sq. meters'),
                    _buildInfoRow(Icons.my_location_outlined, 'Assigned GPS', '${task.latitude.toStringAsFixed(5)}, ${task.longitude.toStringAsFixed(5)}'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 2. Task Assignment Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Assignment Schedule', style: AppTextStyles.h3),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildDateBox('Assigned Date', DateFormatter.formatDateString(task.assignedDate), Icons.calendar_today),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildDateBox('Due Date', DateFormatter.formatDateString(task.dueDate), Icons.event_available, isDue: true),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 3. Field Instructions Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.notes, size: 20, color: AppColors.secondary),
                        SizedBox(width: 8),
                        Text('Field Survey Instructions', style: AppTextStyles.h3),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: Text(
                        task.instructions.isNotEmpty
                            ? task.instructions
                            : 'Perform on-site GPS capture, boundary corner verification, owner document validation, and take high-resolution geo-tagged photographs.',
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // 4. Start Field Visit CTA
            BhoomiButton(
              text: 'START FIELD VISIT',
              icon: Icons.play_arrow_rounded,
              onPressed: () {
                Navigator.of(context).pushNamed(AppRoutes.startVisit, arguments: task);
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.textMuted),
          const SizedBox(width: 8),
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textMuted),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateBox(String label, String date, IconData icon, {bool isDue = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDue ? AppColors.primaryContainer.withOpacity(0.4) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isDue ? AppColors.primary.withOpacity(0.3) : AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: isDue ? AppColors.primaryDark : AppColors.textMuted),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDue ? AppColors.primaryDark : AppColors.textMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            date,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: isDue ? AppColors.primaryDark : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
