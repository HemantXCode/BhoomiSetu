import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../models/sync_queue_item_model.dart';
import '../../core/storage/database_helper.dart';

abstract class ISyncRepository {
  Future<void> queueOperation({
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
  });

  Future<List<SyncQueueItemModel>> getPendingItems();
  Future<List<SyncQueueItemModel>> getAllQueueItems();
  Future<int> getPendingSyncCount();
  Future<void> updateItemStatus(String localId, String status, {String? error, int? retryCount});
  Future<void> removeSyncItem(String localId);
  Future<void> clearSyncedItems();
}

class SyncRepository implements ISyncRepository {
  final DatabaseHelper _dbHelper;

  SyncRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<void> queueOperation({
    required String entityType,
    required String entityId,
    required String operation,
    required String payload,
  }) async {
    final db = await _dbHelper.database;
    final now = DateTime.now().toUtc().toIso8601String();
    final clientEventId = 'EVT_${const Uuid().v4()}'; // Unique idempotency key

    final item = SyncQueueItemModel(
      localId: const Uuid().v4(),
      clientEventId: clientEventId,
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      payload: payload,
      createdAt: now,
      updatedAt: now,
      retryCount: 0,
      syncStatus: 'PENDING',
    );

    await db.insert(
      'sync_queue',
      item.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<List<SyncQueueItemModel>> getPendingItems() async {
    final db = await _dbHelper.database;
    final maps = await db.query(
      'sync_queue',
      where: 'syncStatus = ? OR syncStatus = ?',
      whereArgs: ['PENDING', 'FAILED'],
      orderBy: 'createdAt ASC',
    );
    return maps.map((m) => SyncQueueItemModel.fromJson(m)).toList();
  }

  @override
  Future<List<SyncQueueItemModel>> getAllQueueItems() async {
    final db = await _dbHelper.database;
    final maps = await db.query('sync_queue', orderBy: 'createdAt DESC');
    return maps.map((m) => SyncQueueItemModel.fromJson(m)).toList();
  }

  @override
  Future<int> getPendingSyncCount() async {
    final db = await _dbHelper.database;
    final count = Sqflite.firstIntValue(await db.rawQuery(
      "SELECT COUNT(*) FROM sync_queue WHERE syncStatus IN ('PENDING', 'FAILED')",
    ));
    return count ?? 0;
  }

  @override
  Future<void> updateItemStatus(
    String localId,
    String status, {
    String? error,
    int? retryCount,
  }) async {
    final db = await _dbHelper.database;
    final values = <String, dynamic>{
      'syncStatus': status,
      'updatedAt': DateTime.now().toUtc().toIso8601String(),
    };
    if (error != null) values['lastError'] = error;
    if (retryCount != null) values['retryCount'] = retryCount;

    await db.update('sync_queue', values, where: 'localId = ?', whereArgs: [localId]);
  }

  @override
  Future<void> removeSyncItem(String localId) async {
    final db = await _dbHelper.database;
    await db.delete('sync_queue', where: 'localId = ?', whereArgs: [localId]);
  }

  @override
  Future<void> clearSyncedItems() async {
    final db = await _dbHelper.database;
    await db.delete('sync_queue', where: 'syncStatus = ?', whereArgs: ['SYNCED']);
  }
}
