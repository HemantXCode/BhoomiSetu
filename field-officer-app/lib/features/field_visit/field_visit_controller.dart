import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/field_task_model.dart';
import '../../data/models/field_visit_model.dart';
import '../../data/models/gps_record_model.dart';
import '../../data/models/inspection_model.dart';
import '../../data/models/evidence_model.dart';
import '../../data/models/document_model.dart';
import '../../core/providers/app_providers.dart';
import '../auth/auth_controller.dart';
import '../tasks/tasks_controller.dart';

class FieldVisitState {
  final bool isLoading;
  final FieldVisitModel? visit;
  final FieldTaskModel? task;
  final GPSRecordModel? currentGps;
  final double? calculatedDistanceMeters;
  final bool isWithinRange;
  final String? errorMessage;

  FieldVisitState({
    this.isLoading = false,
    this.visit,
    this.task,
    this.currentGps,
    this.calculatedDistanceMeters,
    this.isWithinRange = false,
    this.errorMessage,
  });

  FieldVisitState copyWith({
    bool? isLoading,
    FieldVisitModel? visit,
    FieldTaskModel? task,
    GPSRecordModel? currentGps,
    double? calculatedDistanceMeters,
    bool? isWithinRange,
    String? errorMessage,
  }) {
    return FieldVisitState(
      isLoading: isLoading ?? this.isLoading,
      visit: visit ?? this.visit,
      task: task ?? this.task,
      currentGps: currentGps ?? this.currentGps,
      calculatedDistanceMeters: calculatedDistanceMeters ?? this.calculatedDistanceMeters,
      isWithinRange: isWithinRange ?? this.isWithinRange,
      errorMessage: errorMessage,
    );
  }
}

class FieldVisitController extends StateNotifier<FieldVisitState> {
  final Ref _ref;

  FieldVisitController(this._ref) : super(FieldVisitState());

  Future<FieldVisitModel> startOrResumeVisit(FieldTaskModel task) async {
    state = state.copyWith(isLoading: true, task: task, errorMessage: null);
    try {
      final authUser = _ref.read(authControllerProvider).user;
      final officerId = authUser?.officerId ?? 'FO-MH-PUN-0842';

      final visit = await _ref.read(fieldVisitRepositoryProvider).createOrGetVisit(
            taskId: task.id,
            parcelId: task.parcelId,
            officerId: officerId,
          );

      // Update task status to IN_PROGRESS
      await _ref.read(taskRepositoryProvider).updateTaskStatus(task.id, 'IN_PROGRESS');
      _ref.read(tasksControllerProvider.notifier).loadTasks();

      state = state.copyWith(isLoading: false, visit: visit);
      return visit;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> updateGpsRecord(GPSRecordModel gps, {double? distance, bool? withinRange}) async {
    if (state.visit == null) return;
    await _ref.read(fieldVisitRepositoryProvider).updateVisitLocation(state.visit!.visitId, gps);

    final updatedVisit = state.visit!.copyWith(
      latitude: gps.latitude,
      longitude: gps.longitude,
      gpsAccuracy: gps.accuracy,
      altitude: gps.altitude,
    );

    state = state.copyWith(
      visit: updatedVisit,
      currentGps: gps,
      calculatedDistanceMeters: distance,
      isWithinRange: withinRange ?? true,
    );
  }

  Future<void> saveInspection(InspectionModel inspection) async {
    if (state.visit == null) return;
    await _ref.read(fieldVisitRepositoryProvider).updateInspection(state.visit!.visitId, inspection);
    state = state.copyWith(visit: state.visit!.copyWith(inspection: inspection));
  }

  Future<void> addPhotoEvidence(EvidenceModel evidence) async {
    if (state.visit == null) return;
    await _ref.read(fieldVisitRepositoryProvider).addEvidence(evidence);
    final list = await _ref.read(fieldVisitRepositoryProvider).getEvidenceForVisit(state.visit!.visitId);
    state = state.copyWith(visit: state.visit!.copyWith(evidence: list));
  }

  Future<void> removePhotoEvidence(String photoId, String filePath) async {
    if (state.visit == null) return;
    await _ref.read(fieldVisitRepositoryProvider).removeEvidence(photoId);
    await _ref.read(cameraServiceProvider).deleteLocalFile(filePath);
    final list = await _ref.read(fieldVisitRepositoryProvider).getEvidenceForVisit(state.visit!.visitId);
    state = state.copyWith(visit: state.visit!.copyWith(evidence: list));
  }

  Future<void> addDocument(DocumentModel document) async {
    if (state.visit == null) return;
    await _ref.read(fieldVisitRepositoryProvider).addDocument(document);
    final list = await _ref.read(fieldVisitRepositoryProvider).getDocumentsForVisit(state.visit!.visitId);
    state = state.copyWith(visit: state.visit!.copyWith(documents: list));
  }

  Future<void> removeDocument(String documentId) async {
    if (state.visit == null) return;
    await _ref.read(fieldVisitRepositoryProvider).removeDocument(documentId);
    final list = await _ref.read(fieldVisitRepositoryProvider).getDocumentsForVisit(state.visit!.visitId);
    state = state.copyWith(visit: state.visit!.copyWith(documents: list));
  }

  Future<bool> submitFieldVisit({String? remarks, bool isConfirmed = true}) async {
    if (state.visit == null) return false;
    state = state.copyWith(isLoading: true);
    try {
      await _ref.read(fieldVisitRepositoryProvider).submitVisit(
            state.visit!.visitId,
            remarks: remarks,
            isConfirmed: isConfirmed,
          );

      // Update task status to PENDING_VERIFICATION
      if (state.task != null) {
        await _ref.read(taskRepositoryProvider).updateTaskStatus(
              state.task!.id,
              'PENDING_VERIFICATION',
            );
        _ref.read(tasksControllerProvider.notifier).loadTasks();
      }

      state = state.copyWith(isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      return false;
    }
  }
}

final fieldVisitControllerProvider =
    StateNotifierProvider<FieldVisitController, FieldVisitState>((ref) {
  return FieldVisitController(ref);
});
