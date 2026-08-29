import 'dart:convert';
import '../models/user_model.dart';
import '../datasources/mock/mock_data_source.dart';
import '../../core/storage/secure_storage_service.dart';
import '../../core/network/api_client.dart';
import '../../core/constants/api_endpoints.dart';
import '../../core/network/api_exceptions.dart';

abstract class IAuthRepository {
  Future<UserModel> login({required String email, required String password});
  Future<UserModel?> getCurrentUser();
  Future<bool> isLoggedIn();
  Future<void> logout();
}

class MockAuthRepository implements IAuthRepository {
  final SecureStorageService _secureStorage;

  MockAuthRepository({SecureStorageService? secureStorage})
      : _secureStorage = secureStorage ?? SecureStorageService();

  @override
  Future<UserModel> login({required String email, required String password}) async {
    // Simulate brief network latency
    await Future.delayed(const Duration(milliseconds: 600));

    // Validate demo or standard credentials
    if (email.trim().toLowerCase() == MockDataSource.defaultOfficer.email.toLowerCase() &&
        (password == 'demo@123' || password == 'password')) {
      final user = MockDataSource.defaultOfficer;
      await _secureStorage.saveAuthTokens(
        accessToken: user.token ?? 'mock_token',
        userId: user.id,
      );
      await _secureStorage.saveUserJson(jsonEncode(user.toJson()));
      return user;
    } else {
      throw ValidationException(message: 'Invalid credentials. Use field.demo@bhoomisetu.gov.in / demo@123');
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final userJson = await _secureStorage.getUserJson();
    if (userJson != null) {
      try {
        return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
      } catch (_) {}
    }
    return MockDataSource.defaultOfficer;
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _secureStorage.hasValidSession();
  }

  @override
  Future<void> logout() async {
    await _secureStorage.clearSession();
  }
}

class ApiAuthRepository implements IAuthRepository {
  final ApiClient _apiClient;
  final SecureStorageService _secureStorage;

  ApiAuthRepository({
    required ApiClient apiClient,
    SecureStorageService? secureStorage,
  })  : _apiClient = apiClient,
        _secureStorage = secureStorage ?? SecureStorageService();

  @override
  Future<UserModel> login({required String email, required String password}) async {
    final response = await _apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
    );

    final data = response.data as Map<String, dynamic>;
    final user = UserModel.fromJson(data['user'] as Map<String, dynamic>? ?? data);
    final accessToken = data['access_token'] as String? ?? user.token ?? '';

    await _secureStorage.saveAuthTokens(
      accessToken: accessToken,
      refreshToken: data['refresh_token'] as String?,
      userId: user.id,
    );
    await _secureStorage.saveUserJson(jsonEncode(user.toJson()));

    return user;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final userJson = await _secureStorage.getUserJson();
    if (userJson != null) {
      return UserModel.fromJson(jsonDecode(userJson) as Map<String, dynamic>);
    }
    return null;
  }

  @override
  Future<bool> isLoggedIn() async {
    return await _secureStorage.hasValidSession();
  }

  @override
  Future<void> logout() async {
    await _secureStorage.clearSession();
  }
}
