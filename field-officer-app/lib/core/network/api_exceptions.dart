class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic details;

  ApiException({
    required this.message,
    this.statusCode,
    this.details,
  });

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  UnauthorizedException({String message = 'Session expired. Please log in again.'})
      : super(message: message, statusCode: 401);
}

class ForbiddenException extends ApiException {
  ForbiddenException({String message = 'You do not have permission for this action.'})
      : super(message: message, statusCode: 403);
}

class ValidationException extends ApiException {
  ValidationException({required String message, dynamic details})
      : super(message: message, statusCode: 400, details: details);
}

class ServerException extends ApiException {
  ServerException({String message = 'Internal Server Error. Please try again later.'})
      : super(message: message, statusCode: 500);
}

class BackendUnavailableException extends ApiException {
  BackendUnavailableException({String? message})
      : super(
          message: message ?? 'Backend server unavailable. Please verify connection to the server.',
          statusCode: 503,
        );
}

class NetworkException extends ApiException {
  NetworkException({String message = 'Cannot connect to backend server. Please verify network or server URL.'})
      : super(message: message, statusCode: null);
}
