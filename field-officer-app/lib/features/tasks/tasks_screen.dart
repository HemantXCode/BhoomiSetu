import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/bhoomi_app_bar.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/routing/app_router.dart';
import '../../core/utils/date_formatter.dart';
import 'tasks_controller.dart';

class TasksScreen extends ConsumerWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasksState = ref.watch(tasksControllerProvider);
    final controller = ref.read(tasksControllerProvider.notifier);

    return Scaffold(
      appBar: const BhoomiAppBar(
        title: 'Assigned Field Tasks',
        subtitle: 'Pune Ring Road Express Corridor',
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            color: Colors.white,
            child: TextField(
              onChanged: controller.searchTasks,
              decoration: InputDecoration(
                hintText: 'Search by ULPIN, Village, Survey No...',
                prefixIcon: const Icon(Icons.search, size: 20, color: AppColors.textMuted),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                filled: true,
                fillColor: const Color(0xFFF8FAFC),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: AppColors.cardBorder),
                ),
              ),
            ),
          ),

          // 2. Status Filter Chips
          Container(
            height: 48,
            color: Colors.white,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              children: [
                _buildFilterChip('ALL', 'All Tasks', tasksState.selectedStatusFilter, controller),
                _buildFilterChip('PENDING', 'Pending', tasksState.selectedStatusFilter, controller),
                _buildFilterChip('IN_PROGRESS', 'In Progress', tasksState.selectedStatusFilter, controller),
                _buildFilterChip('VERIFIED', 'Verified', tasksState.selectedStatusFilter, controller),
                _buildFilterChip('REJECTED', 'Rejected', tasksState.selectedStatusFilter, controller),
              ],
            ),
          ),
          const Divider(height: 1),

          // 3. Tasks List View
          Expanded(
            child: tasksState.isLoading
                ? const LoadingView(message: 'Retrieving assigned parcel tasks...')
                : tasksState.filteredTasks.isEmpty
                    ? const EmptyStateView(
                        title: 'No Matching Tasks Found',
                        message: 'Try clearing your search query or switching filters.',
                      )
                    : RefreshIndicator(
                        onRefresh: () => controller.loadTasks(forceRefresh: true),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: tasksState.filteredTasks.length,
                          itemBuilder: (context, index) {
                            final task = tasksState.filteredTasks[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.cardBorder),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Color(0x06000000),
                                    blurRadius: 6,
                                    offset: Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: InkWell(
                                onTap: () => Navigator.of(context).pushNamed(AppRoutes.taskDetails, arguments: task),
                                borderRadius: BorderRadius.circular(14),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Row 1: ULPIN Badge on Left, Status Badge on Right
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.center,
                                        children: [
                                          Flexible(
                                            child: Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4.5),
                                              decoration: BoxDecoration(
                                                color: AppColors.secondary,
                                                borderRadius: BorderRadius.circular(6),
                                              ),
                                              child: Text(
                                                task.ulpin,
                                                style: const TextStyle(
                                                  fontSize: 12.5,
                                                  fontWeight: FontWeight.w800,
                                                  color: Colors.white,
                                                  letterSpacing: 0.3,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          StatusBadge(status: task.status, compact: true),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Row 2: Village & Location
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on, size: 15, color: AppColors.primary),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              '${task.village}, ${task.district}',
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w700,
                                                color: AppColors.textPrimary,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),

                                      // Row 3: Task Description
                                      Text(
                                        'Task: ${task.taskType}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.textPrimary,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                      const SizedBox(height: 4),

                                      // Row 4: Survey Number & Area
                                      Row(
                                        children: [
                                          const Icon(Icons.crop_free, size: 14, color: AppColors.textMuted),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              'Survey No: ${task.surveyNumber} • ${task.landAreaSqM} sq.m',
                                              style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Divider(height: 20),

                                      // Row 5: Due Date and Details
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Row(
                                              children: [
                                                const Icon(Icons.event, size: 14, color: AppColors.textMuted),
                                                const SizedBox(width: 4),
                                                Expanded(
                                                  child: Text(
                                                    'Due: ${DateFormatter.formatDateString(task.dueDate)}',
                                                    style: const TextStyle(
                                                      fontSize: 12,
                                                      fontWeight: FontWeight.w600,
                                                      color: AppColors.textSecondary,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                    maxLines: 1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          const Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                'Details',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w700,
                                                  color: AppColors.primary,
                                                ),
                                              ),
                                              SizedBox(width: 2),
                                              Icon(Icons.arrow_forward, size: 14, color: AppColors.primary),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(
    String statusKey,
    String label,
    String currentFilter,
    TasksController controller,
  ) {
    final isSelected = currentFilter.toUpperCase() == statusKey.toUpperCase();
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) => controller.filterByStatus(statusKey),
        backgroundColor: const Color(0xFFF1F5F9),
        selectedColor: AppColors.primaryContainer,
        labelStyle: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? AppColors.primaryDark : AppColors.textSecondary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(
            color: isSelected ? AppColors.primary : AppColors.cardBorder,
            width: 1,
          ),
        ),
      ),
    );
  }
}
