enum DataMode {
  mock,
  api,
}

class AppConstants {
  static const String appName = 'BhoomiSetu';
  static const String appTagline = 'National Land Acquisition & Management System';
  static const String ministry = 'Ministry of Rural Development & Land Resources';
  static const String appVersion = '1.0.1 (SIH Field Build #20260901.05)';

  // Demo Credentials (Match FastAPI Seed Users)
  static const String demoEmail = 'field.demo@example.com';
  static const String demoPassword = 'Demo@12345';
  static const String demoOfficerName = 'Suresh Patil';
  static const String demoOfficerId = 'FO-MH-PUN-0842';
  static const String demoDesignation = 'Sub-Divisional Field Officer';
  static const String demoState = 'Maharashtra';
  static const String demoDistrict = 'Pune';

  // Default API Base URL (FastAPI Backend / ADB Reverse / Localhost)
  static const String defaultApiBaseUrl = 'http://127.0.0.1:8000';

  // GPS Accuracy threshold in meters (threshold for warning banner)
  static const double gpsAccuracyThresholdMeters = 15.0;
  static const double parcelProximityThresholdMeters = 50.0;

  // Max sync retry count
  static const int maxSyncRetries = 5;
}
