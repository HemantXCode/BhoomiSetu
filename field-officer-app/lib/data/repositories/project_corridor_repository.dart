import '../models/project_corridor_model.dart';
import '../datasources/mock/project_corridor_demo_data.dart';
import '../../core/network/api_client.dart';

abstract class IProjectCorridorRepository {
  Future<List<ProjectCorridorModel>> getCorridors({bool forceRefresh = false});
  Future<ProjectCorridorModel?> getCorridorById(String id);
}

/// Demo/Local implementation of [IProjectCorridorRepository].
/// Provides offline demo data for Pune Ring Road & Pune-Nashik Rail Corridor.
class DemoProjectCorridorRepository implements IProjectCorridorRepository {
  @override
  Future<List<ProjectCorridorModel>> getCorridors({bool forceRefresh = false}) async {
    // Return offline demo corridors
    return ProjectCorridorDemoData.getAllProjects();
  }

  @override
  Future<ProjectCorridorModel?> getCorridorById(String id) async {
    final all = ProjectCorridorDemoData.getAllProjects();
    try {
      return all.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

/// Remote API implementation for future FastAPI endpoint integration.
/// Can be plugged into Riverpod without touching any map UI code.
class ApiProjectCorridorRepository implements IProjectCorridorRepository {
  final ApiClient apiClient;
  final IProjectCorridorRepository fallback;

  ApiProjectCorridorRepository({
    required this.apiClient,
    required this.fallback,
  });

  @override
  Future<List<ProjectCorridorModel>> getCorridors({bool forceRefresh = false}) async {
    try {
      final response = await apiClient.get('/api/v1/projects/corridors');
      if (response.statusCode == 200 && response.data != null) {
        final list = response.data as List<dynamic>;
        return list.map((j) => ProjectCorridorModel.fromJson(j as Map<String, dynamic>)).toList();
      }
      return await fallback.getCorridors(forceRefresh: forceRefresh);
    } catch (_) {
      return await fallback.getCorridors(forceRefresh: forceRefresh);
    }
  }

  @override
  Future<ProjectCorridorModel?> getCorridorById(String id) async {
    try {
      final response = await apiClient.get('/api/v1/projects/corridors/$id');
      if (response.statusCode == 200 && response.data != null) {
        return ProjectCorridorModel.fromJson(response.data as Map<String, dynamic>);
      }
      return await fallback.getCorridorById(id);
    } catch (_) {
      return await fallback.getCorridorById(id);
    }
  }
}
