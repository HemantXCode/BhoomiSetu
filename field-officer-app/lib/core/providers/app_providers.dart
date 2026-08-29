import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage_service.dart';
import '../storage/database_helper.dart';
import '../network/api_client.dart';
import '../network/api_config.dart';
import '../../services/connectivity_service.dart';
import '../../services/location_service.dart';
import '../../services/camera_service.dart';
import '../../services/sync_service.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/task_repository.dart';
import '../../data/repositories/sync_repository.dart';
import '../../data/repositories/field_visit_repository.dart';
import '../../data/repositories/notification_repository.dart';

// Storage & Services
final secureStorageProvider = Provider<SecureStorageService>((ref) {
  return SecureStorageService();
});

final dbHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

final apiClientProvider = Provider<ApiClient>((ref) {
  final storage = ref.watch(secureStorageProvider);
  return ApiClient(secureStorage: storage);
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

final locationServiceProvider = Provider<LocationService>((ref) {
  return LocationService();
});

final cameraServiceProvider = Provider<CameraService>((ref) {
  return CameraService();
});

// Repositories
final syncRepositoryProvider = Provider<ISyncRepository>((ref) {
  final dbHelper = ref.watch(dbHelperProvider);
  return SyncRepository(dbHelper: dbHelper);
});

final syncServiceProvider = Provider<SyncService>((ref) {
  final syncRepo = ref.watch(syncRepositoryProvider);
  final connectivity = ref.watch(connectivityServiceProvider);
  final service = SyncService(syncRepository: syncRepo, connectivityService: connectivity);
  ref.onDispose(() => service.dispose());
  return service;
});

final authRepositoryProvider = Provider<IAuthRepository>((ref) {
  final storage = ref.watch(secureStorageProvider);
  final apiClient = ref.watch(apiClientProvider);

  if (ApiConfig.isMockMode) {
    return MockAuthRepository(secureStorage: storage);
  } else {
    return ApiAuthRepository(apiClient: apiClient, secureStorage: storage);
  }
});

final taskRepositoryProvider = Provider<ITaskRepository>((ref) {
  final dbHelper = ref.watch(dbHelperProvider);
  final apiClient = ref.watch(apiClientProvider);

  if (ApiConfig.isMockMode) {
    return MockTaskRepository(dbHelper: dbHelper);
  } else {
    return ApiTaskRepository(apiClient: apiClient, dbHelper: dbHelper);
  }
});

final fieldVisitRepositoryProvider = Provider<IFieldVisitRepository>((ref) {
  final dbHelper = ref.watch(dbHelperProvider);
  final syncRepo = ref.watch(syncRepositoryProvider);
  final apiClient = ref.watch(apiClientProvider);

  final mockRepo = MockFieldVisitRepository(dbHelper: dbHelper, syncRepository: syncRepo);
  if (ApiConfig.isMockMode) {
    return mockRepo;
  } else {
    return ApiFieldVisitRepository(apiClient: apiClient, localFallback: mockRepo);
  }
});

final notificationRepositoryProvider = Provider<INotificationRepository>((ref) {
  final dbHelper = ref.watch(dbHelperProvider);
  return MockNotificationRepository(dbHelper: dbHelper);
});

// Connectivity State Provider
final isOnlineProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.statusStream.map((status) => status == ConnectionStatus.online);
});

// Pending Sync Count Stream Provider
final pendingSyncCountProvider = FutureProvider.autoDispose<int>((ref) async {
  final repo = ref.watch(syncRepositoryProvider);
  return await repo.getPendingSyncCount();
});
