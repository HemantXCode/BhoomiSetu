import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/field_task_model.dart';
import '../../core/providers/app_providers.dart';

class TasksState {
  final bool isLoading;
  final List<FieldTaskModel> tasks;
  final List<FieldTaskModel> filteredTasks;
  final String searchQuery;
  final String selectedStatusFilter;
  final String? errorMessage;

  TasksState({
    this.isLoading = false,
    this.tasks = const [],
    this.filteredTasks = const [],
    this.searchQuery = '',
    this.selectedStatusFilter = 'ALL',
    this.errorMessage,
  });

  TasksState copyWith({
    bool? isLoading,
    List<FieldTaskModel>? tasks,
    List<FieldTaskModel>? filteredTasks,
    String? searchQuery,
    String? selectedStatusFilter,
    String? errorMessage,
  }) {
    return TasksState(
      isLoading: isLoading ?? this.isLoading,
      tasks: tasks ?? this.tasks,
      filteredTasks: filteredTasks ?? this.filteredTasks,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedStatusFilter: selectedStatusFilter ?? this.selectedStatusFilter,
      errorMessage: errorMessage,
    );
  }
}

class TasksController extends StateNotifier<TasksState> {
  final Ref _ref;

  TasksController(this._ref) : super(TasksState(isLoading: true)) {
    loadTasks();
  }

  Future<void> loadTasks({bool forceRefresh = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final tasks = await _ref.read(taskRepositoryProvider).getTasks(forceRefresh: forceRefresh);
      state = state.copyWith(
        isLoading: false,
        tasks: tasks,
        filteredTasks: _applyFilter(tasks, state.searchQuery, state.selectedStatusFilter),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void searchTasks(String query) {
    state = state.copyWith(
      searchQuery: query,
      filteredTasks: _applyFilter(state.tasks, query, state.selectedStatusFilter),
    );
  }

  void filterByStatus(String status) {
    state = state.copyWith(
      selectedStatusFilter: status,
      filteredTasks: _applyFilter(state.tasks, state.searchQuery, status),
    );
  }

  List<FieldTaskModel> _applyFilter(List<FieldTaskModel> allTasks, String query, String status) {
    var result = List<FieldTaskModel>.from(allTasks);

    if (status != 'ALL') {
      result = result.where((t) => t.status.toUpperCase() == status.toUpperCase()).toList();
    }

    if (query.trim().isNotEmpty) {
      final q = query.toLowerCase().trim();
      result = result.where((t) {
        return t.parcelId.toLowerCase().contains(q) ||
            t.village.toLowerCase().contains(q) ||
            t.surveyNumber.toLowerCase().contains(q) ||
            t.taskType.toLowerCase().contains(q);
      }).toList();
    }

    return result;
  }
}

final tasksControllerProvider = StateNotifierProvider<TasksController, TasksState>((ref) {
  return TasksController(ref);
});
