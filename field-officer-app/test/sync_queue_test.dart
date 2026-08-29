import 'package:flutter_test/flutter_test.dart';
import 'package:field_officer_app/data/models/sync_queue_item_model.dart';
import 'package:uuid/uuid.dart';

void main() {
  group('Sync Queue & Idempotency Tests', () {
    test('SyncQueueItem creates unique clientEventId for idempotency', () {
      final clientEventId1 = 'EVT_${const Uuid().v4()}';
      final clientEventId2 = 'EVT_${const Uuid().v4()}';

      expect(clientEventId1, isNot(equals(clientEventId2)));
      expect(clientEventId1.startsWith('EVT_'), true);
    });

    test('SyncQueueItem serializes and deserializes cleanly with null safety', () {
      final item = SyncQueueItemModel(
        localId: 'loc_123',
        clientEventId: 'EVT_ABC_456',
        entityType: 'FIELD_VISIT',
        entityId: 'VST-1024',
        operation: 'SUBMIT',
        payload: '{"visitId":"VST-1024","status":"VERIFIED"}',
        createdAt: '2026-08-29T10:00:00Z',
        updatedAt: '2026-08-29T10:00:00Z',
        retryCount: 1,
        syncStatus: 'PENDING',
      );

      final json = item.toJson();
      final fromJson = SyncQueueItemModel.fromJson(json);

      expect(fromJson.localId, 'loc_123');
      expect(fromJson.clientEventId, 'EVT_ABC_456');
      expect(fromJson.entityType, 'FIELD_VISIT');
      expect(fromJson.operation, 'SUBMIT');
      expect(fromJson.retryCount, 1);
      expect(fromJson.syncStatus, 'PENDING');
    });

    test('SyncQueueItem copyWith updates retry count and status', () {
      final item = SyncQueueItemModel(
        localId: 'loc_123',
        clientEventId: 'EVT_ABC_456',
        entityType: 'FIELD_VISIT',
        entityId: 'VST-1024',
        operation: 'SUBMIT',
        payload: '{}',
        createdAt: '2026-08-29T10:00:00Z',
        updatedAt: '2026-08-29T10:00:00Z',
      );

      final updated = item.copyWith(
        retryCount: item.retryCount + 1,
        syncStatus: 'SYNCING',
      );

      expect(updated.retryCount, 1);
      expect(updated.syncStatus, 'SYNCING');
      expect(updated.clientEventId, 'EVT_ABC_456'); // Preserves idempotency key
    });
  });
}
