import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ApiConfig {
  static String baseUrl = AppConstants.defaultApiBaseUrl;
  static DataMode dataMode = DataMode.api; // Default is API repository for live FastAPI backend

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 15);

  static const String _keyBaseUrl = 'bhoomisetu_api_base_url';
  static const String _keyDataMode = 'bhoomisetu_data_mode';

  static Future<void> loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedUrl = prefs.getString(_keyBaseUrl);
      if (savedUrl != null && savedUrl.isNotEmpty) {
        baseUrl = savedUrl;
      }
      final savedMode = prefs.getString(_keyDataMode);
      if (savedMode == 'api') {
        dataMode = DataMode.api;
      } else {
        dataMode = DataMode.api; // Guaranteed live API backend runtime
      }
    } catch (_) {
      dataMode = DataMode.api;
    }
  }

  static Future<void> saveSettings(String url, DataMode mode) async {
    baseUrl = url;
    dataMode = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_keyBaseUrl, url);
      await prefs.setString(_keyDataMode, mode == DataMode.api ? 'api' : 'mock');
    } catch (_) {}
  }

  static void setBaseUrl(String url) {
    baseUrl = url;
  }

  static void setDataMode(DataMode mode) {
    dataMode = mode;
  }

  static bool get isMockMode => dataMode == DataMode.mock;
}
