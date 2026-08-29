/// PROPOSED / AGREED API CONTRACTS (Versioned /api/v1)
/// These endpoints represent the expected REST contract with Aditya's Backend/API Gateway.
/// The Flutter application abstracts all requests behind the Repository pattern.
class ApiEndpoints {
  // Authentication
  static const String login = '/api/v1/auth/login';
  static const String refreshToken = '/api/v1/auth/refresh';
  static const String profile = '/api/v1/field/profile';

  // Tasks
  static const String tasks = '/api/v1/field/tasks';
  static String taskDetails(String id) => '/api/v1/field/tasks/$id';

  // Field Visits
  static const String visits = '/api/v1/field/visits';
  static String visitLocation(String id) => '/api/v1/field/visits/$id/location';
  static String visitEvidence(String id) => '/api/v1/field/visits/$id/evidence';
  static String visitInspection(String id) => '/api/v1/field/visits/$id/inspection';
  static String visitDocuments(String id) => '/api/v1/field/visits/$id/documents';
  static String visitSubmit(String id) => '/api/v1/field/visits/$id/submit';

  // Notifications
  static const String notifications = '/api/v1/field/notifications';
  static String markNotificationRead(String id) => '/api/v1/field/notifications/$id/read';
  static const String markAllNotificationsRead = '/api/v1/field/notifications/read-all';

  // Sync Batch Endpoint (Idempotent)
  static const String sync = '/api/v1/sync';

  // WebSocket (Abstraction)
  static const String wsEvents = '/ws/v1/field/events';
}
