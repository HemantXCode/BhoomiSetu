import 'package:dio/dio.dart';
import 'api_config.dart';
import 'api_exceptions.dart';
import '../storage/secure_storage_service.dart';

class ApiClient {
  late final Dio _dio;
  final SecureStorageService _secureStorage;

  ApiClient({
    Dio? dio,
    SecureStorageService? secureStorage,
  }) : _secureStorage = secureStorage ?? SecureStorageService() {
    _dio = dio ??
        Dio(
          BaseOptions(
            baseUrl: ApiConfig.baseUrl,
            connectTimeout: ApiConfig.connectTimeout,
            receiveTimeout: ApiConfig.receiveTimeout,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Sync Base URL with current ApiConfig
          options.baseUrl = ApiConfig.baseUrl;

          // Attach Authorization Bearer token if present
          final token = await _secureStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          final customException = _handleDioError(error);
          return handler.reject(
            DioException(
              requestOptions: error.requestOptions,
              error: customException,
              response: error.response,
              type: error.type,
            ),
          );
        },
      ),
    );
  }

  ApiException _handleDioError(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout ||
        error.type == DioExceptionType.connectionError) {
      return NetworkException(
        message: 'Cannot connect to backend server at ${ApiConfig.baseUrl}. Please verify Wi-Fi or USB connection.',
      );
    }

    final statusCode = error.response?.statusCode;
    final data = error.response?.data;
    final message = (data is Map && data['message'] != null)
        ? data['message'].toString()
        : 'An error occurred (${statusCode ?? 'unknown'})';

    switch (statusCode) {
      case 401:
        return UnauthorizedException(message: message);
      case 403:
        return ForbiddenException(message: message);
      case 400:
      case 422:
        return ValidationException(message: message, details: data);
      case 500:
      case 502:
      case 503:
        return ServerException(message: message);
      default:
        return ApiException(message: message, statusCode: statusCode);
    }
  }

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.get<T>(path, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ApiException(message: e.message ?? 'Unknown GET error');
    }
  }

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.post<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ApiException(message: e.message ?? 'Unknown POST error');
    }
  }

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await _dio.put<T>(path, data: data, queryParameters: queryParameters, options: options);
    } on DioException catch (e) {
      throw e.error as ApiException? ?? ApiException(message: e.message ?? 'Unknown PUT error');
    }
  }
}
