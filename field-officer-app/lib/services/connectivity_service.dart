import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import '../core/network/api_config.dart';

enum ConnectionStatus {
  online,
  offline,
}

class ConnectivityService {
  final Connectivity _connectivity;
  final Dio _healthDio;
  final StreamController<ConnectionStatus> _statusController =
      StreamController<ConnectionStatus>.broadcast();
  ConnectionStatus _currentStatus = ConnectionStatus.online;

  ConnectivityService({Connectivity? connectivity, Dio? dio})
      : _connectivity = connectivity ?? Connectivity(),
        _healthDio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 4),
                receiveTimeout: const Duration(seconds: 4),
              ),
            ) {
    _init();
  }

  void _init() {
    _connectivity.onConnectivityChanged.listen((_) {
      checkConnectivity();
    });
    checkConnectivity();
  }

  Future<ConnectionStatus> checkConnectivity() async {
    // If running in Mock mode, always treat as online
    if (ApiConfig.isMockMode) {
      _setStatus(ConnectionStatus.online);
      return ConnectionStatus.online;
    }

    try {
      final healthUrl = '${ApiConfig.baseUrl}/health';
      final response = await _healthDio.get(healthUrl);
      if (response.statusCode == 200) {
        _setStatus(ConnectionStatus.online);
        return ConnectionStatus.online;
      }
    } catch (_) {
      // Backend ping failed
    }

    _setStatus(ConnectionStatus.offline);
    return ConnectionStatus.offline;
  }

  void _setStatus(ConnectionStatus status) {
    if (status != _currentStatus) {
      _currentStatus = status;
      _statusController.add(_currentStatus);
    }
  }

  bool get isOnline => _currentStatus == ConnectionStatus.online;
  bool get isOffline => _currentStatus == ConnectionStatus.offline;
  Stream<ConnectionStatus> get statusStream => _statusController.stream;

  void dispose() {
    _statusController.close();
  }
}
