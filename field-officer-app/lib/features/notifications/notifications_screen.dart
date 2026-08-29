import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/bhoomi_app_bar.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/utils/date_formatter.dart';
import 'notifications_controller.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifState = ref.watch(notificationsControllerProvider);
    final controller = ref.read(notificationsControllerProvider.notifier);

    return Scaffold(
      appBar: BhoomiAppBar(
        title: 'Notifications',
        subtitle: '${notifState.unreadCount} unread alerts',
        showBack: true,
        actions: [
          if (notifState.unreadCount > 0)
            TextButton(
              onPressed: () => controller.markAllAsRead(),
              child: const Text(
                'Mark All Read',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
              ),
            ),
        ],
      ),
      body: notifState.isLoading
          ? const LoadingView(message: 'Loading notifications...')
          : notifState.notifications.isEmpty
              ? const EmptyStateView(
                  title: 'No Notifications',
                  message: 'You have no unread field task notifications.',
                  icon: Icons.notifications_off_outlined,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: notifState.notifications.length,
                  itemBuilder: (context, index) {
                    final n = notifState.notifications[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      color: n.isRead ? Colors.white : const Color(0xFFF0FDF4),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: n.isRead ? const Color(0xFFF1F5F9) : AppColors.primaryContainer,
                          child: Icon(
                            n.type == 'TASK_ASSIGNED'
                                ? Icons.assignment
                                : n.type == 'VERIFICATION_UPDATE'
                                    ? Icons.verified
                                    : Icons.notifications,
                            color: n.isRead ? AppColors.textMuted : AppColors.primaryDark,
                            size: 20,
                          ),
                        ),
                        title: Text(
                          n.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 3),
                            Text(
                              n.message,
                              style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              DateFormatter.formatDateTime(n.timestamp),
                              style: const TextStyle(fontSize: 10, color: AppColors.textMuted),
                            ),
                          ],
                        ),
                        trailing: n.isRead
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.check_circle_outline, size: 18, color: AppColors.primary),
                                tooltip: 'Mark as read',
                                onPressed: () => controller.markAsRead(n.id),
                              ),
                      ),
                    );
                  },
                ),
    );
  }
}
