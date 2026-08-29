import 'package:sqflite/sqflite.dart';
import '../models/notification_model.dart';
import '../datasources/mock/mock_data_source.dart';
import '../../core/storage/database_helper.dart';

abstract class INotificationRepository {
  Future<List<NotificationModel>> getNotifications();
  Future<void> markAsRead(String id);
  Future<void> markAllAsRead();
  Future<int> getUnreadCount();
}

class MockNotificationRepository implements INotificationRepository {
  final DatabaseHelper _dbHelper;
  List<NotificationModel> _notifications = [];

  MockNotificationRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<List<NotificationModel>> getNotifications() async {
    try {
      final db = await _dbHelper.database;
      final maps = await db.query('notifications', orderBy: 'timestamp DESC');
      if (maps.isNotEmpty) {
        _notifications = maps.map((m) => NotificationModel.fromJson(m)).toList();
        return _notifications;
      }
    } catch (_) {}

    if (_notifications.isEmpty) {
      _notifications = MockDataSource.getInitialNotifications();
      // Seed SQLite
      try {
        final db = await _dbHelper.database;
        final batch = db.batch();
        for (final n in _notifications) {
          batch.insert('notifications', n.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
        }
        await batch.commit(noResult: true);
      } catch (_) {}
    }
    return _notifications;
  }

  @override
  Future<void> markAsRead(String id) async {
    final index = _notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      try {
        final db = await _dbHelper.database;
        await db.update('notifications', {'isRead': 1}, where: 'id = ?', whereArgs: [id]);
      } catch (_) {}
    }
  }

  @override
  Future<void> markAllAsRead() async {
    _notifications = _notifications.map((n) => n.copyWith(isRead: true)).toList();
    try {
      final db = await _dbHelper.database;
      await db.update('notifications', {'isRead': 1});
    } catch (_) {}
  }

  @override
  Future<int> getUnreadCount() async {
    final list = await getNotifications();
    return list.where((n) => !n.isRead).length;
  }
}
