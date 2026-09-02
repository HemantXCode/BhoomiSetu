import 'dart:async';
import 'dart:convert';
import '../data/repositories/sync_repository.dart';
import '../core/constants/app_constants.dart';
import '../core/constants/api_endpoints.dart';
import '../core/network/api_client.dart';
import '../core/network/api_config.dart';
import 'connectivity_service.dart';

enum SyncState {
  idle,
  syncing,
  success,
  error,
}

class SyncService {
  final ISyncRepository syncRepository;
  final ConnectivityService connectivityService;
  final ApiClient? apiClient;
  final StreamController<SyncState> _syncStateController = StreamController<SyncState>.broadcast();
  StreamSubscription? _connectivitySub;
  bool _isProcessing = false;

  SyncService({
    required this.syncRepository,
    required this.connectivityService,
    this.apiClient,
  }) {
    _initAutoSync();
  }

  void _initAutoSync() {
    _connectivitySub = connectivityService.statusStream.listen((status) {
      if (status == ConnectionStatus.online) {
        syncNow();
      }
    });
  }

  Stream<SyncState> get syncStateStream => _syncStateController.stream;

  Future<int> syncNow() async {
    if (_isProcessing) return 0;
    _isProcessing = true;
    _syncStateController.add(SyncState.syncing);

    int syncedCount = 0;
    try {
      final pendingItems = await syncRepository.getPendingItems();
      if (pendingItems.isEmpty) {
        _syncStateController.add(SyncState.success);
        return 0;
      }

      if (!ApiConfig.isMockMode && apiClient != null) {
        // Send batch sync event request to FastAPI backend
        final eventsPayload = pendingItems.map((item) {
          Map<String, dynamic> parsedPayload = {};
          try {
            parsedPayload = jsonDecode(item.payload) as Map<String, dynamic>;
          } catch (_) {}

          final taskIdInt = int.tryParse(parsedPayload['taskId']?.toString() ?? '') ??
                            int.tryParse(parsedPayload['task_id']?.toString() ?? '') ??
                            int.tryParse(item.entityId) ?? 101;
          final ulpinStr = parsedPayload['ulpin']?.toString() ??
                           parsedPayload['parcelId']?.toString() ??
                           parsedPayload['parcel_id']?.toString() ?? '';
          final parcelIdInt = int.tryParse(ulpinStr) ?? 1;

          return {
            "client_event_id": item.clientEventId,
            "client_created_at": item.createdAt,
            "event_type": item.entityType,
            "payload": {
              "task_id": taskIdInt,
              "visit_id": 1,
              "ulpin": ulpinStr,
              "parcel_id": parcelIdInt,
              "checklist_data": parsedPayload['inspection'] ?? parsedPayload['checklist_data'] ?? {},
              "remarks": parsedPayload['remarks'] ?? "Offline field submission"
            }
          };
        }).toList();

        try {
          await apiClient!.post(
            ApiEndpoints.sync,
            data: {
              "device_id": "android-flutter-app",
              "sync_timestamp": DateTime.now().toUtc().toIso8601String(),
              "events": eventsPayload
            },
          );

          for (final item in pendingItems) {
            await syncRepository.updateItemStatus(item.localId, 'SYNCED', retryCount: item.retryCount + 1);
            syncedCount++;
          }
        } catch (e) {
          for (final item in pendingItems) {
            await syncRepository.updateItemStatus(
              item.localId,
              'FAILED',
              error: e.toString(),
              retryCount: item.retryCount + 1,
            );
          }
        }
      } else {
        // Standalone Mock Repository behavior
        for (final item in pendingItems) {
          if (item.retryCount >= AppConstants.maxSyncRetries) {
            await syncRepository.updateItemStatus(
              item.localId,
              'FAILED',
              error: 'Exceeded max retry attempts (${AppConstants.maxSyncRetries}).',
            );
            continue;
          }

          await syncRepository.updateItemStatus(item.localId, 'SYNCING');
          await Future.delayed(const Duration(milliseconds: 350));
          await syncRepository.updateItemStatus(
            item.localId,
            'SYNCED',
            retryCount: item.retryCount + 1,
          );
          syncedCount++;
        }
      }

      _syncStateController.add(SyncState.success);
    } catch (e) {
      _syncStateController.add(SyncState.error);
    } finally {
      _isProcessing = false;
      _syncStateController.add(SyncState.idle);
    }

    return syncedCount;
  }

  Future<bool> retryItem(String localId) async {
    try {
      await syncRepository.updateItemStatus(localId, 'SYNCING');
      await Future.delayed(const Duration(milliseconds: 400));
      await syncRepository.updateItemStatus(localId, 'SYNCED');
      return true;
    } catch (e) {
      await syncRepository.updateItemStatus(localId, 'FAILED', error: e.toString());
      return false;
    }
  }

  void dispose() {
    _connectivitySub?.cancel();
    _syncStateController.close();
  }
}
