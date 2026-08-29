enum DataMode {
  mock,
  api,
}

class AppConstants {
  static const String appName = 'BhoomiSetu';
  static const String appTagline = 'National Land Acquisition & Management System';
  static const String ministry = 'Ministry of Rural Development & Land Resources';
  static const String appVersion = '1.0.0 (SIH Field Build)';

  // Demo Credentials
  static const String demoEmail = 'field.demo@bhoomisetu.gov.in';
  static const String demoPassword = 'demo@123';
  static const String demoOfficerName = 'Rajesh Kumar';
  static const String demoOfficerId = 'FO-MH-PUN-0842';
  static const String demoDesignation = 'Senior Field Survey Officer';
  static const String demoState = 'Maharashtra';
  static const String demoDistrict = 'Pune';

  // Default API configuration
  static const String defaultApiBaseUrl = 'https://api.bhoomisetu.gov.in';

  // GPS Accuracy threshold in meters (threshold for warning banner)
  static const double gpsAccuracyThresholdMeters = 15.0;
  static const double parcelProximityThresholdMeters = 50.0;

  // Max sync retry count
  static const int maxSyncRetries = 5;
}
