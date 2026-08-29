import 'dart:async';
import '../data/repositories/sync_repository.dart';
import '../core/constants/app_constants.dart';
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
  final StreamController<SyncState> _syncStateController = StreamController<SyncState>.broadcast();
  StreamSubscription? _connectivitySub;
  bool _isProcessing = false;

  SyncService({
    required this.syncRepository,
    required this.connectivityService,
  }) {
    _initAutoSync();
  }

  void _initAutoSync() {
    _connectivitySub = connectivityService.statusStream.listen((status) {
      if (status == ConnectionStatus.online) {
        // Auto sync when network connectivity returns
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

        // Simulate REST / API Gateway synchronization with idempotency header
        await Future.delayed(const Duration(milliseconds: 350));

        // Mark successfully synced
        await syncRepository.updateItemStatus(
          item.localId,
          'SYNCED',
          retryCount: item.retryCount + 1,
        );
        syncedCount++;
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
