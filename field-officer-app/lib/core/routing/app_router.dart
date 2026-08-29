import 'package:flutter/material.dart';
import '../../data/models/field_task_model.dart';
import '../../data/models/field_visit_model.dart';
import '../../features/splash/splash_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/dashboard/main_navigation_wrapper.dart';
import '../../features/tasks/task_details_screen.dart';
import '../../features/field_visit/start_visit_screen.dart';
import '../../features/field_visit/gps_capture_screen.dart';
import '../../features/field_visit/parcel_verification_screen.dart';
import '../../features/inspection/inspection_form_screen.dart';
import '../../features/evidence/camera_capture_screen.dart';
import '../../features/evidence/evidence_gallery_screen.dart';
import '../../features/documents/document_upload_screen.dart';
import '../../features/field_visit/review_submit_screen.dart';
import '../../features/field_visit/submission_success_screen.dart';
import '../../features/notifications/notifications_screen.dart';
import '../../features/progress/my_progress_screen.dart';
import '../../features/sync/offline_sync_screen.dart';
import '../../features/settings/settings_screen.dart';

class AppRoutes {
  static const String splash = '/';
  static const String login = '/login';
  static const String main = '/main';
  static const String taskDetails = '/task-details';
  static const String startVisit = '/start-visit';
  static const String gpsCapture = '/gps-capture';
  static const String parcelVerification = '/parcel-verification';
  static const String inspectionForm = '/inspection-form';
  static const String cameraCapture = '/camera-capture';
  static const String evidenceGallery = '/evidence-gallery';
  static const String documentUpload = '/document-upload';
  static const String reviewSubmit = '/review-submit';
  static const String submissionSuccess = '/submission-success';
  static const String notifications = '/notifications';
  static const String myProgress = '/my-progress';
  static const String offlineSync = '/offline-sync';
  static const String settings = '/settings';
}

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case AppRoutes.login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case AppRoutes.main:
        final initialIndex = settings.arguments as int? ?? 0;
        return MaterialPageRoute(builder: (_) => MainNavigationWrapper(initialIndex: initialIndex));
      case AppRoutes.taskDetails:
        final task = settings.arguments as FieldTaskModel;
        return MaterialPageRoute(builder: (_) => TaskDetailsScreen(task: task));
      case AppRoutes.startVisit:
        final task = settings.arguments as FieldTaskModel;
        return MaterialPageRoute(builder: (_) => StartVisitScreen(task: task));
      case AppRoutes.gpsCapture:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => GPSCaptureScreen(
            task: args['task'] as FieldTaskModel,
            visit: args['visit'] as FieldVisitModel,
          ),
        );
      case AppRoutes.parcelVerification:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ParcelVerificationScreen(
            task: args['task'] as FieldTaskModel,
            visit: args['visit'] as FieldVisitModel,
          ),
        );
      case AppRoutes.inspectionForm:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => InspectionFormScreen(
            task: args['task'] as FieldTaskModel,
            visit: args['visit'] as FieldVisitModel,
          ),
        );
      case AppRoutes.cameraCapture:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => CameraCaptureScreen(
            task: args['task'] as FieldTaskModel,
            visit: args['visit'] as FieldVisitModel,
          ),
        );
      case AppRoutes.evidenceGallery:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => EvidenceGalleryScreen(
            task: args['task'] as FieldTaskModel,
            visit: args['visit'] as FieldVisitModel,
          ),
        );
      case AppRoutes.documentUpload:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => DocumentUploadScreen(
            task: args['task'] as FieldTaskModel,
            visit: args['visit'] as FieldVisitModel,
          ),
        );
      case AppRoutes.reviewSubmit:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => ReviewSubmitScreen(
            task: args['task'] as FieldTaskModel,
            visit: args['visit'] as FieldVisitModel,
          ),
        );
      case AppRoutes.submissionSuccess:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => SubmissionSuccessScreen(
            visitId: args['visitId'] as String,
            parcelId: args['parcelId'] as String,
          ),
        );
      case AppRoutes.notifications:
        return MaterialPageRoute(builder: (_) => const NotificationsScreen());
      case AppRoutes.myProgress:
        return MaterialPageRoute(builder: (_) => const MyProgressScreen());
      case AppRoutes.offlineSync:
        return MaterialPageRoute(builder: (_) => const OfflineSyncScreen());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsScreen());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('Route not found: ${settings.name}')),
          ),
        );
    }
  }
}
