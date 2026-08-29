import '../../models/user_model.dart';
import '../../models/field_task_model.dart';
import '../../models/land_parcel_model.dart';
import '../../models/project_model.dart';
import '../../models/dashboard_stats_model.dart';
import '../../models/notification_model.dart';
import '../../../core/constants/app_constants.dart';

class MockDataSource {
  static final UserModel defaultOfficer = UserModel(
    id: 'usr_01_rajesh',
    email: AppConstants.demoEmail,
    name: AppConstants.demoOfficerName,
    officerId: AppConstants.demoOfficerId,
    designation: AppConstants.demoDesignation,
    state: AppConstants.demoState,
    district: AppConstants.demoDistrict,
    phone: '+91 98230 45678',
    role: 'FIELD_OFFICER',
    token: 'mock_jwt_token_bhoomisetu_fo_0842',
  );

  static final ProjectModel puneRingRoadProject = ProjectModel(
    id: 'PRJ-MH-PUN-001',
    name: 'Pune Ring Road Express Corridor',
    code: 'PRR-EC-2026',
    state: 'Maharashtra',
    district: 'Pune',
    status: 'ACTIVE',
  );

  static List<FieldTaskModel> getInitialTasks() {
    return [
      FieldTaskModel(
        id: 'TSK-1024',
        parcelId: 'PUN-1024',
        project: 'Pune Ring Road Express Corridor',
        village: 'Bhugaon',
        district: 'Pune',
        state: 'Maharashtra',
        surveyNumber: '48/2A',
        landAreaSqM: 4250.0,
        taskType: 'Survey & Verification',
        assignedDate: '2026-08-27',
        dueDate: '2026-09-02',
        status: 'PENDING',
        latitude: 18.498214,
        longitude: 73.746820,
        instructions: 'Verify western boundary alignment against proposed corridor centerline. Confirm structure offset.',
        syncStatus: 'SYNCED',
      ),
      FieldTaskModel(
        id: 'TSK-1025',
        parcelId: 'PUN-1025',
        project: 'Pune Ring Road Express Corridor',
        village: 'Lavale',
        district: 'Pune',
        state: 'Maharashtra',
        surveyNumber: '112/1B',
        landAreaSqM: 8120.5,
        taskType: 'Boundary Verification',
        assignedDate: '2026-08-26',
        dueDate: '2026-08-30',
        status: 'IN_PROGRESS',
        latitude: 18.536240,
        longitude: 73.731410,
        instructions: 'Check agricultural demarcation markers and record geo-tagged boundary corner stones.',
        syncStatus: 'SYNCED',
      ),
      FieldTaskModel(
        id: 'TSK-1026',
        parcelId: 'PUN-1026',
        project: 'Pune Ring Road Express Corridor',
        village: 'Pirangut',
        district: 'Pune',
        state: 'Maharashtra',
        surveyNumber: '74/3',
        landAreaSqM: 6400.0,
        taskType: 'Land Inspection',
        assignedDate: '2026-08-28',
        dueDate: '2026-09-04',
        status: 'PENDING',
        latitude: 18.512450,
        longitude: 73.684520,
        instructions: 'Perform physical inspection checklist and confirm non-agricultural conversion certificate.',
        syncStatus: 'SYNCED',
      ),
      FieldTaskModel(
        id: 'TSK-1027',
        parcelId: 'PUN-1027',
        project: 'Pune Ring Road Express Corridor',
        village: 'Mulshi',
        district: 'Pune',
        state: 'Maharashtra',
        surveyNumber: '19/A',
        landAreaSqM: 12800.0,
        taskType: 'Cadastral Mapping',
        assignedDate: '2026-08-25',
        dueDate: '2026-09-05',
        status: 'PENDING',
        latitude: 18.503410,
        longitude: 73.518730,
        instructions: 'Map river boundary offset and record photographic evidence of flood-line markers.',
        syncStatus: 'SYNCED',
      ),
      FieldTaskModel(
        id: 'TSK-1028',
        parcelId: 'PUN-1028',
        project: 'Pune Ring Road Express Corridor',
        village: 'Haveli',
        district: 'Pune',
        state: 'Maharashtra',
        surveyNumber: '205/4',
        landAreaSqM: 3100.0,
        taskType: 'Encroachment Check',
        assignedDate: '2026-08-20',
        dueDate: '2026-08-25',
        status: 'VERIFIED',
        latitude: 18.461230,
        longitude: 73.862110,
        instructions: 'Field verification completed and approved by Competent Authority Land Acquisition (CALA).',
        syncStatus: 'SYNCED',
      ),
    ];
  }

  static List<LandParcelModel> getInitialParcels() {
    return [
      LandParcelModel(
        parcelId: 'PUN-1024',
        surveyNumber: '48/2A',
        village: 'Bhugaon',
        district: 'Pune',
        state: 'Maharashtra',
        landAreaSqM: 4250.0,
        latitude: 18.498214,
        longitude: 73.746820,
        landType: 'Agricultural (Irrigated)',
        ownerName: 'Suresh Babanrao Patil',
        status: 'PENDING',
      ),
      LandParcelModel(
        parcelId: 'PUN-1025',
        surveyNumber: '112/1B',
        village: 'Lavale',
        district: 'Pune',
        state: 'Maharashtra',
        landAreaSqM: 8120.5,
        latitude: 18.536240,
        longitude: 73.731410,
        landType: 'Agricultural (Dry Crop)',
        ownerName: 'Sunita Dinkar Gholap',
        status: 'IN_PROGRESS',
      ),
      LandParcelModel(
        parcelId: 'PUN-1026',
        surveyNumber: '74/3',
        village: 'Pirangut',
        district: 'Pune',
        state: 'Maharashtra',
        landAreaSqM: 6400.0,
        latitude: 18.512450,
        longitude: 73.684520,
        landType: 'Commercial / Warehouse',
        ownerName: 'Kishore Mahadev Jagtap',
        status: 'PENDING',
      ),
      LandParcelModel(
        parcelId: 'PUN-1027',
        surveyNumber: '19/A',
        village: 'Mulshi',
        district: 'Pune',
        state: 'Maharashtra',
        landAreaSqM: 12800.0,
        latitude: 18.503410,
        longitude: 73.518730,
        landType: 'Fallow / Forest Fringe',
        ownerName: 'Dattatray Anandrao Deshmukh',
        status: 'PENDING',
      ),
    ];
  }

  static List<NotificationModel> getInitialNotifications() {
    return [
      NotificationModel(
        id: 'notif_1',
        title: 'New Task Assigned',
        message: 'Parcel PUN-1026 (Pirangut) assigned for Land Inspection.',
        type: 'TASK_ASSIGNED',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        isRead: false,
        relatedId: 'TSK-1026',
      ),
      NotificationModel(
        id: 'notif_2',
        title: 'Verification Approved',
        message: 'Parcel PUN-1028 field report verified by CALA Officer.',
        type: 'VERIFICATION_UPDATE',
        timestamp: DateTime.now().subtract(const Duration(hours: 4)),
        isRead: false,
        relatedId: 'PUN-1028',
      ),
      NotificationModel(
        id: 'notif_3',
        title: 'Corridor Alignment Updated',
        message: 'Notice: Cadastral overlay buffer revised in Lavale sector.',
        type: 'GENERAL',
        timestamp: DateTime.now().subtract(const Duration(days: 1)),
        isRead: true,
        relatedId: 'PRJ-MH-PUN-001',
      ),
    ];
  }

  static DashboardStatsModel getDashboardStats(List<FieldTaskModel> tasks, int pendingSyncCount) {
    int assigned = tasks.length;
    int inProgress = tasks.where((t) => t.status == 'IN_PROGRESS').length;
    int completed = tasks.where((t) => t.status == 'VERIFIED' || t.status == 'PENDING_VERIFICATION').length;
    int verified = tasks.where((t) => t.status == 'VERIFIED').length;
    int pending = tasks.where((t) => t.status == 'PENDING').length;
    int rejected = tasks.where((t) => t.status == 'REJECTED').length;

    return DashboardStatsModel(
      assigned: assigned,
      inProgress: inProgress,
      completed: completed,
      verified: verified,
      pending: pending,
      rejected: rejected,
      syncPending: pendingSyncCount,
    );
  }
}
