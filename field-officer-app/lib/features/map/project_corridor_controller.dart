import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/project_corridor_model.dart';
import '../../data/models/land_parcel_model.dart';
import '../../core/providers/app_providers.dart';

class ProjectCorridorState {
  final bool isLoading;
  final List<ProjectCorridorModel> corridors;
  final String selectedProjectFilter; // 'ALL' or project ID (e.g. 'PRJ-MH-PUN-001')
  final ProjectCorridorModel? inspectedCorridor;
  final String? highlightedParcelId;
  final String? errorMessage;

  ProjectCorridorState({
    this.isLoading = false,
    this.corridors = const [],
    this.selectedProjectFilter = 'ALL',
    this.inspectedCorridor,
    this.highlightedParcelId,
    this.errorMessage,
  });

  ProjectCorridorState copyWith({
    bool? isLoading,
    List<ProjectCorridorModel>? corridors,
    String? selectedProjectFilter,
    ProjectCorridorModel? inspectedCorridor,
    bool clearInspectedCorridor = false,
    String? highlightedParcelId,
    bool clearHighlightedParcel = false,
    String? errorMessage,
  }) {
    return ProjectCorridorState(
      isLoading: isLoading ?? this.isLoading,
      corridors: corridors ?? this.corridors,
      selectedProjectFilter: selectedProjectFilter ?? this.selectedProjectFilter,
      inspectedCorridor: clearInspectedCorridor ? null : (inspectedCorridor ?? this.inspectedCorridor),
      highlightedParcelId: clearHighlightedParcel ? null : (highlightedParcelId ?? this.highlightedParcelId),
      errorMessage: errorMessage,
    );
  }

  /// Active corridors based on current filter
  List<ProjectCorridorModel> get visibleCorridors {
    if (selectedProjectFilter == 'ALL') {
      return corridors;
    }
    return corridors.where((c) => c.id == selectedProjectFilter).toList();
  }

  /// All parcels associated with active project filter
  List<LandParcelModel> get visibleParcels {
    if (selectedProjectFilter == 'ALL') {
      return corridors.expand((c) => c.parcels).toList();
    }
    final match = corridors.where((c) => c.id == selectedProjectFilter);
    return match.expand((c) => c.parcels).toList();
  }
}

class ProjectCorridorController extends StateNotifier<ProjectCorridorState> {
  final Ref _ref;

  ProjectCorridorController(this._ref) : super(ProjectCorridorState(isLoading: true)) {
    loadCorridors();
  }

  Future<void> loadCorridors({bool forceRefresh = false}) async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final repo = _ref.read(projectCorridorRepositoryProvider);
      final list = await repo.getCorridors(forceRefresh: forceRefresh);
      state = state.copyWith(
        isLoading: false,
        corridors: list,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void selectProjectFilter(String filterId) {
    ProjectCorridorModel? matchingCorridor;
    if (filterId != 'ALL') {
      matchingCorridor = state.corridors.firstWhere(
        (c) => c.id == filterId,
        orElse: () => state.corridors.first,
      );
    }

    state = state.copyWith(
      selectedProjectFilter: filterId,
      inspectedCorridor: matchingCorridor,
      clearHighlightedParcel: true,
    );
  }

  void inspectCorridor(ProjectCorridorModel corridor) {
    state = state.copyWith(
      inspectedCorridor: corridor,
      selectedProjectFilter: corridor.id,
    );
  }

  void clearInspectedCorridor() {
    state = state.copyWith(clearInspectedCorridor: true);
  }

  void highlightParcel(String? parcelId) {
    if (parcelId == null) {
      state = state.copyWith(clearHighlightedParcel: true);
    } else {
      state = state.copyWith(highlightedParcelId: parcelId);
    }
  }
}

final projectCorridorControllerProvider =
    StateNotifierProvider<ProjectCorridorController, ProjectCorridorState>((ref) {
  return ProjectCorridorController(ref);
});
