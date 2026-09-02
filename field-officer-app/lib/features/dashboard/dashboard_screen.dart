import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/bhoomi_app_bar.dart';
import '../../core/widgets/metric_card.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/offline_banner.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/routing/app_router.dart';
import '../../core/providers/app_providers.dart';
import '../auth/auth_controller.dart';
import 'dashboard_controller.dart';

class DashboardScreen extends ConsumerWidget {
  final Function(int)? onNavigateTab;

  const DashboardScreen({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);
    final dashState = ref.watch(dashboardControllerProvider);
    final isOnlineAsync = ref.watch(isOnlineProvider);
    final pendingSyncAsync = ref.watch(pendingSyncCountProvider);

    final isOffline = isOnlineAsync.asData?.value == false;
    final pendingCount = pendingSyncAsync.asData?.value ?? 0;
    final officer = authState.user;

    return Scaffold(
      appBar: BhoomiAppBar(
        title: AppConstants.appName,
        subtitle: AppConstants.appTagline,
        actions: [
          IconButton(
            icon: const Icon(Icons.sync, color: Colors.white),
            tooltip: 'Sync Center',
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.offlineSync),
          ),
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white),
                tooltip: 'Notifications',
                onPressed: () => Navigator.of(context).pushNamed(AppRoutes.notifications),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          // Offline / Sync status banner
          OfflineBanner(
            isOffline: isOffline,
            pendingCount: pendingCount,
            onSyncTap: () {
              ref.read(syncServiceProvider).syncNow();
            },
          ),

          Expanded(
            child: dashState.isLoading
                ? const LoadingView(message: 'Loading Field Officer Dashboard...')
                : RefreshIndicator(
                    onRefresh: () => ref.read(dashboardControllerProvider.notifier).loadDashboardData(),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. Officer Profile & GPS Status Card
                          _buildOfficerCard(context, officer),
                          const SizedBox(height: 16),

                          // 2. Overview Statistics (Assigned, In Progress, Verified, Pending)
                          _buildStatisticsSection(context, dashState),
                          const SizedBox(height: 20),

                          // 3. Quick Action Buttons
                          _buildQuickActions(context),
                          const SizedBox(height: 24),

                          // 4. Today's Assigned Tasks Header
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text("Today's Tasks", style: AppTextStyles.h3),
                              TextButton(
                                onPressed: () {
                                  if (onNavigateTab != null) {
                                    onNavigateTab!(1); // Go to Tasks tab
                                  }
                                },
                                child: const Row(
                                  children: [
                                    Text(
                                      'View All',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                    SizedBox(width: 2),
                                    Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),

                          // Today's Tasks List
                          if (dashState.todayTasks.isEmpty)
                            const EmptyStateView(
                              title: 'No Tasks For Today',
                              message: 'All assigned parcel inspections are completed.',
                            )
                          else
                            ...dashState.todayTasks.map((task) => _buildTaskCard(context, task)),

                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfficerCard(BuildContext context, dynamic officer) {
    return Card(
      elevation: 2,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.white24,
                  child: const Icon(Icons.person, size: 30, color: Colors.white),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hello, ${officer?.name ?? "Field Officer"}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${officer?.designation ?? "Revenue & Land Officer"}${officer?.officerId != null ? " • ${officer!.officerId}" : ""}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFCBD5E1),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(color: Colors.white24, height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: AppColors.primaryLight),
                    const SizedBox(width: 4),
                    Text(
                      officer?.district != null && officer?.state != null
                          ? '${officer!.district}, ${officer!.state}'
                          : (officer?.district ?? officer?.state ?? 'Government Jurisdiction'),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.25),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF10B981), width: 1),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.gps_fixed, size: 12, color: Color(0xFF34D399)),
                      SizedBox(width: 4),
                      Text(
                        'GPS Connected',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF34D399),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context, DashboardState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Acquisition Progress Overview', style: AppTextStyles.h3),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: MetricCard(
                title: 'Assigned',
                value: '${state.stats.assigned}',
                icon: Icons.assignment_outlined,
                accentColor: AppColors.secondaryLight,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MetricCard(
                title: 'In Progress',
                value: '${state.stats.inProgress}',
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
                title: 'Verified',
                value: '${state.stats.verified}',
                icon: Icons.verified_outlined,
                accentColor: AppColors.success,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: MetricCard(
                title: 'Pending Sync',
                value: '${state.stats.syncPending}',
                icon: Icons.cloud_sync_outlined,
                accentColor: AppColors.warning,
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.offlineSync),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    final actions = [
      {'title': 'Start Visit', 'icon': Icons.play_arrow_rounded, 'color': AppColors.primary, 'tab': 1},
      {'title': 'Tasks List', 'icon': Icons.format_list_bulleted, 'color': AppColors.secondary, 'tab': 1},
      {'title': 'Parcel Map', 'icon': Icons.map_outlined, 'color': const Color(0xFF0284C7), 'tab': 3},
      {'title': 'Sync Center', 'icon': Icons.cloud_upload_outlined, 'color': const Color(0xFF7C3AED), 'route': AppRoutes.offlineSync},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Field Operations', style: AppTextStyles.h3),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: actions.map((act) {
            return InkWell(
              onTap: () {
                if (act.containsKey('route')) {
                  Navigator.of(context).pushNamed(act['route'] as String);
                } else if (act.containsKey('tab') && onNavigateTab != null) {
                  onNavigateTab!(act['tab'] as int);
                }
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 78,
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.cardBorder),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (act['color'] as Color).withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(act['icon'] as IconData, size: 20, color: act['color'] as Color),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      act['title'] as String,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTaskCard(BuildContext context, dynamic task) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                'ULPIN: ${task.ulpin}',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.secondary),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            StatusBadge(status: task.status, compact: true),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Task: ${task.taskType} • Survey No: ${task.surveyNumber}',
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textPrimary),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                'Village: ${task.village}, ${task.district} • Area: ${task.landAreaSqM} sq.m',
                style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textMuted),
        onTap: () {
          Navigator.of(context).pushNamed(AppRoutes.taskDetails, arguments: task);
        },
      ),
    );
  }
}
