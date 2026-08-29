import '../constants/app_constants.dart';

class ApiConfig {
  static String baseUrl = AppConstants.defaultApiBaseUrl;
  static DataMode dataMode = DataMode.mock; // Default is mock for development

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static void setBaseUrl(String url) {
    baseUrl = url;
  }

  static void setDataMode(DataMode mode) {
    dataMode = mode;
  }

  static bool get isMockMode => dataMode == DataMode.mock;
}
