/// FastAPI REST Endpoints Contract (/api/v1)
class ApiEndpoints {
  // Authentication
  static const String login = '/api/v1/auth/login';
  static const String me = '/api/v1/auth/me';

  // Field Tasks
  static const String tasks = '/api/v1/field/tasks';
  static String taskDetails(String id) => '/api/v1/field/tasks/$id';

  // Field Visits & Submissions
  static const String visits = '/api/v1/field/visits';
  static String visitDetails(String id) => '/api/v1/field/visits/$id';
  static const String verifications = '/api/v1/field/verifications';
  static const String photos = '/api/v1/field/photos';
  static const String documentUpload = '/api/v1/documents/upload';

  // Sync Batch Endpoint (Idempotent)
  static const String sync = '/api/v1/field/sync';

  // Notifications
  static const String notifications = '/api/v1/notifications';

  // Geo / GIS Endpoints
  static const String geoParcels = '/api/v1/geo/parcels';
  static const String geoProjects = '/api/v1/geo/projects';

  // WebSockets
  static const String wsEvents = '/api/v1/ws';
}
