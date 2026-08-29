import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/field_task_model.dart';
import '../../data/models/dashboard_stats_model.dart';
import '../../data/datasources/mock/mock_data_source.dart';
import '../../core/providers/app_providers.dart';

class DashboardState {
  final bool isLoading;
  final List<FieldTaskModel> todayTasks;
  final DashboardStatsModel stats;
  final String? errorMessage;

  DashboardState({
    this.isLoading = false,
    this.todayTasks = const [],
    DashboardStatsModel? stats,
    this.errorMessage,
  }) : stats = stats ?? DashboardStatsModel.empty();

  DashboardState copyWith({
    bool? isLoading,
    List<FieldTaskModel>? todayTasks,
    DashboardStatsModel? stats,
    String? errorMessage,
  }) {
    return DashboardState(
      isLoading: isLoading ?? this.isLoading,
      todayTasks: todayTasks ?? this.todayTasks,
      stats: stats ?? this.stats,
      errorMessage: errorMessage,
    );
  }
}

class DashboardController extends StateNotifier<DashboardState> {
  final Ref _ref;

  DashboardController(this._ref) : super(DashboardState(isLoading: true)) {
    loadDashboardData();
  }

  Future<void> loadDashboardData() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final tasks = await _ref.read(taskRepositoryProvider).getTasks();
      final pendingSync = await _ref.read(syncRepositoryProvider).getPendingSyncCount();
      final stats = MockDataSource.getDashboardStats(tasks, pendingSync);

      state = state.copyWith(
        isLoading: false,
        todayTasks: tasks.take(3).toList(),
        stats: stats,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }
}

final dashboardControllerProvider =
    StateNotifierProvider<DashboardController, DashboardState>((ref) {
  return DashboardController(ref);
});
