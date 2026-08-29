import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/sync_queue_item_model.dart';
import '../../core/providers/app_providers.dart';
import '../../services/sync_service.dart';

class SyncQueueState {
  final bool isLoading;
  final List<SyncQueueItemModel> items;
  final SyncState syncState;
  final String? message;

  SyncQueueState({
    this.isLoading = false,
    this.items = const [],
    this.syncState = SyncState.idle,
    this.message,
  });

  SyncQueueState copyWith({
    bool? isLoading,
    List<SyncQueueItemModel>? items,
    SyncState? syncState,
    String? message,
  }) {
    return SyncQueueState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      syncState: syncState ?? this.syncState,
      message: message,
    );
  }
}

class SyncController extends StateNotifier<SyncQueueState> {
  final Ref _ref;

  SyncController(this._ref) : super(SyncQueueState(isLoading: true)) {
    loadQueue();
    _listenSyncState();
  }

  void _listenSyncState() {
    _ref.read(syncServiceProvider).syncStateStream.listen((state) {
      this.state = this.state.copyWith(syncState: state);
      if (state == SyncState.success || state == SyncState.idle) {
        loadQueue();
      }
    });
  }

  Future<void> loadQueue() async {
    state = state.copyWith(isLoading: true);
    final repo = _ref.read(syncRepositoryProvider);
    final list = await repo.getAllQueueItems();
    state = state.copyWith(isLoading: false, items: list);
  }

  Future<void> triggerSyncAll() async {
    final count = await _ref.read(syncServiceProvider).syncNow();
    await loadQueue();
    state = state.copyWith(message: 'Synced $count items successfully.');
  }

  Future<void> retryItem(String localId) async {
    await _ref.read(syncServiceProvider).retryItem(localId);
    await loadQueue();
  }

  Future<void> clearSynced() async {
    await _ref.read(syncRepositoryProvider).clearSyncedItems();
    await loadQueue();
  }
}

final syncControllerProvider =
    StateNotifierProvider<SyncController, SyncQueueState>((ref) {
  return SyncController(ref);
});
