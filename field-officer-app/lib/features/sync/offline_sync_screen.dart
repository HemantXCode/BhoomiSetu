import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/bhoomi_app_bar.dart';
import '../../core/widgets/bhoomi_button.dart';
import '../../core/widgets/status_badge.dart';
import '../../core/widgets/loading_view.dart';
import '../../core/providers/app_providers.dart';
import '../../services/sync_service.dart';
import 'sync_controller.dart';

class OfflineSyncScreen extends ConsumerWidget {
  const OfflineSyncScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final queueState = ref.watch(syncControllerProvider);
    final controller = ref.read(syncControllerProvider.notifier);
    final isOnlineAsync = ref.watch(isOnlineProvider);
    final isOnline = isOnlineAsync.asData?.value ?? true;

    final pendingItems = queueState.items.where((i) => i.syncStatus != 'SYNCED').toList();

    return Scaffold(
      appBar: BhoomiAppBar(
        title: 'Offline Sync Center',
        subtitle: isOnline ? 'Network Connected (Online)' : 'No Connection (Offline)',
        showBack: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.cleaning_services_outlined, color: Colors.white),
            tooltip: 'Clear Synced Items',
            onPressed: () => controller.clearSynced(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Network State Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: isOnline ? const Color(0xFFECFDF5) : const Color(0xFFFEF2F2),
            child: Row(
              children: [
                Icon(
                  isOnline ? Icons.wifi : Icons.wifi_off,
                  size: 20,
                  color: isOnline ? AppColors.success : AppColors.danger,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isOnline
                        ? 'Connected to BhoomiSetu Gateway. Ready for live sync.'
                        : 'Offline Mode Active. Field data is preserved securely in SQLite.',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isOnline ? AppColors.success : AppColors.danger,
                    ),
                  ),
                ),
                if (queueState.syncState == SyncState.syncing)
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Main Action Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: BhoomiButton(
                    text: queueState.syncState == SyncState.syncing
                        ? 'SYNCHRONIZING...'
                        : 'SYNC ALL QUEUED ITEMS',
                    icon: Icons.sync,
                    isLoading: queueState.syncState == SyncState.syncing,
                    onPressed: pendingItems.isEmpty ? null : () => controller.triggerSyncAll(),
                  ),
                ),
              ],
            ),
          ),

          // Queue Items List Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Synchronization Queue (${queueState.items.length})',
                  style: AppTextStyles.h3,
                ),
                Text(
                  '${pendingItems.length} Pending',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Queue Items List
          Expanded(
            child: queueState.isLoading
                ? const LoadingView(message: 'Loading sync queue...')
                : queueState.items.isEmpty
                    ? const EmptyStateView(
                        title: 'Sync Queue Is Empty',
                        message: 'All local field records and media are up to date.',
                        icon: Icons.cloud_done_outlined,
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: queueState.items.length,
                        itemBuilder: (context, index) {
                          final item = queueState.items[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            item.entityType == 'FIELD_VISIT'
                                                ? Icons.assignment_turned_in
                                                : item.entityType == 'EVIDENCE'
                                                    ? Icons.camera_alt
                                                    : Icons.upload_file,
                                            size: 18,
                                            color: AppColors.secondary,
                                          ),
                                          const SizedBox(width: 6),
                                          Text(
                                            '${item.operation}: ${item.entityType}',
                                            style: const TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.textPrimary,
                                            ),
                                          ),
                                        ],
                                      ),
                                      StatusBadge(status: item.syncStatus, compact: true),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Entity ID: ${item.entityId}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Idempotency Key: ${item.clientEventId}',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontFamily: 'monospace',
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                  if (item.lastError != null) ...[
                                    const SizedBox(height: 6),
                                    Text(
                                      'Error: ${item.lastError}',
                                      style: const TextStyle(fontSize: 11, color: AppColors.danger),
                                    ),
                                  ],
                                  const Divider(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Retries: ${item.retryCount}/5 • ${item.createdAt.substring(0, 10)}',
                                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                      ),
                                      if (item.syncStatus != 'SYNCED')
                                        TextButton.icon(
                                          icon: const Icon(Icons.refresh, size: 14, color: AppColors.primary),
                                          label: const Text(
                                            'Retry Item',
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                          onPressed: () => controller.retryItem(item.localId),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
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
