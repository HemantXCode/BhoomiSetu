import 'package:sqflite/sqflite.dart';
import '../models/field_task_model.dart';
import '../models/land_parcel_model.dart';
import '../datasources/mock/mock_data_source.dart';
import '../../core/storage/database_helper.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';

abstract class ITaskRepository {
  Future<List<FieldTaskModel>> getTasks({bool forceRefresh = false});
  Future<FieldTaskModel?> getTaskById(String taskId);
  Future<List<LandParcelModel>> getParcels();
  Future<void> updateTaskStatus(String taskId, String status, {String? syncStatus});
  Future<void> saveTasksToLocal(List<FieldTaskModel> tasks);
}

class MockTaskRepository implements ITaskRepository {
  final DatabaseHelper _dbHelper;
  List<FieldTaskModel> _memoryTasks = [];
  final List<LandParcelModel> _memoryParcels = MockDataSource.getInitialParcels();

  MockTaskRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<List<FieldTaskModel>> getTasks({bool forceRefresh = false}) async {
    try {
      final db = await _dbHelper.database;
      final List<Map<String, dynamic>> maps = await db.query('tasks');
      if (maps.isNotEmpty && !forceRefresh) {
        _memoryTasks = maps.map((m) => FieldTaskModel.fromJson(m)).toList();
        return _memoryTasks;
      }
    } catch (_) {}

    if (_memoryTasks.isEmpty || forceRefresh) {
      _memoryTasks = MockDataSource.getInitialTasks();
      await saveTasksToLocal(_memoryTasks);
    }
    return _memoryTasks;
  }

  @override
  Future<FieldTaskModel?> getTaskById(String taskId) async {
    final tasks = await getTasks();
    try {
      return tasks.firstWhere((t) => t.id == taskId || t.ulpin == taskId || t.parcelId == taskId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<LandParcelModel>> getParcels() async {
    return _memoryParcels;
  }

  @override
  Future<void> updateTaskStatus(String taskId, String status, {String? syncStatus}) async {
    final index = _memoryTasks.indexWhere((t) => t.id == taskId || t.ulpin == taskId || t.parcelId == taskId);
    if (index != -1) {
      _memoryTasks[index] = _memoryTasks[index].copyWith(
        status: status,
        syncStatus: syncStatus ?? _memoryTasks[index].syncStatus,
      );
      try {
        final db = await _dbHelper.database;
        await db.update(
          'tasks',
          _memoryTasks[index].toJson(),
          where: 'id = ?',
          whereArgs: [_memoryTasks[index].id],
        );
      } catch (_) {}
    }
  }

  @override
  Future<void> saveTasksToLocal(List<FieldTaskModel> tasks) async {
    try {
      final db = await _dbHelper.database;
      final batch = db.batch();
      for (final task in tasks) {
        batch.insert(
          'tasks',
          task.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (_) {}
  }
}

class ApiTaskRepository implements ITaskRepository {
  final ApiClient apiClient;
  final DatabaseHelper _dbHelper;

  ApiTaskRepository({
    required this.apiClient,
    DatabaseHelper? dbHelper,
  })  : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<List<FieldTaskModel>> getTasks({bool forceRefresh = false}) async {
    try {
      final response = await apiClient.get(ApiEndpoints.tasks);
      final rootMap = response.data as Map<String, dynamic>;
      final dataMap = rootMap['data'] as Map<String, dynamic>? ?? rootMap;
      final rawList = (dataMap['tasks'] as List<dynamic>?) ?? (rootMap['tasks'] as List<dynamic>?) ?? [];

      final tasks = rawList.map((json) => FieldTaskModel.fromJson(json as Map<String, dynamic>)).toList();
      await saveTasksToLocal(tasks);
      return tasks;
    } catch (e) {
      // Offline fallback: load from SQLite
      try {
        final db = await _dbHelper.database;
        final maps = await db.query('tasks');
        if (maps.isNotEmpty) {
          return maps.map((m) => FieldTaskModel.fromJson(m)).toList();
        }
      } catch (_) {}
      rethrow;
    }
  }

  @override
  Future<FieldTaskModel?> getTaskById(String taskId) async {
    try {
      final response = await apiClient.get(ApiEndpoints.taskDetails(taskId));
      final rootMap = response.data as Map<String, dynamic>;
      final dataMap = rootMap['data'] as Map<String, dynamic>? ?? rootMap;
      return FieldTaskModel.fromJson(dataMap);
    } catch (e) {
      try {
        final db = await _dbHelper.database;
        final maps = await db.query('tasks', where: 'id = ?', whereArgs: [taskId]);
        if (maps.isNotEmpty) {
          return FieldTaskModel.fromJson(maps.first);
        }
      } catch (_) {}
      return null;
    }
  }

  @override
  Future<List<LandParcelModel>> getParcels() async {
    try {
      final response = await apiClient.get(ApiEndpoints.geoParcels);
      final rootMap = response.data as Map<String, dynamic>;
      final dataMap = rootMap['data'] as Map<String, dynamic>? ?? rootMap;
      if (dataMap.containsKey('features') && dataMap['features'] is List) {
        final features = dataMap['features'] as List<dynamic>;
        if (features.isNotEmpty) {
          return features.map((f) {
            final feat = f as Map<String, dynamic>;
            final props = (feat['properties'] as Map<String, dynamic>?) ?? {};
            return LandParcelModel(
              ulpin: (props['ulpin'] ?? props['id'] ?? props['parcel_number'] ?? '').toString(),
              surveyNumber: props['survey_number'] as String? ?? '',
              village: props['village'] as String? ?? 'Haveli',
              district: props['district'] as String? ?? 'Pune',
              state: props['state'] as String? ?? 'Maharashtra',
              landAreaSqM: ((props['area_hectares'] as num?)?.toDouble() ?? 0.0) * 10000.0,
              latitude: 18.5204,
              longitude: 73.8567,
              landType: props['classification'] as String? ?? 'Agricultural',
              ownerName: props['owner_name'] as String? ?? '',
              status: props['status'] as String? ?? 'PENDING',
            );
          }).toList();
        }
      }
      return MockDataSource.getInitialParcels();
    } catch (_) {
      return MockDataSource.getInitialParcels();
    }
  }

  @override
  Future<void> updateTaskStatus(String taskId, String status, {String? syncStatus}) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        'tasks',
        {'status': status, 'syncStatus': syncStatus ?? 'SYNCED'},
        where: 'id = ?',
        whereArgs: [taskId],
      );
    } catch (_) {}
  }

  @override
  Future<void> saveTasksToLocal(List<FieldTaskModel> tasks) async {
    try {
      final db = await _dbHelper.database;
      final batch = db.batch();
      for (final task in tasks) {
        batch.insert('tasks', task.toJson(), conflictAlgorithm: ConflictAlgorithm.replace);
      }
      await batch.commit(noResult: true);
    } catch (_) {}
  }
}
