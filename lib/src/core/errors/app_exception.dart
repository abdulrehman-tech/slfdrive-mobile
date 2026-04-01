class AppException implements Exception {
  final String message;
  final String? messageAr;
  final int? statusCode;
  final List<String>? errors;

  AppException({required this.message, this.messageAr, this.statusCode, this.errors});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException({super.message = 'Network error occurred', super.messageAr});
}

class ServerException extends AppException {
  ServerException({super.message = 'Server error occurred', super.messageAr, super.statusCode});
}

class UnauthorizedException extends AppException {
  UnauthorizedException({super.message = 'Unauthorized access', super.messageAr}) : super(statusCode: 401);
}

class ValidationException extends AppException {
  ValidationException({super.message = 'Validation failed', super.messageAr, super.errors});
}

class TimeoutException extends AppException {
  TimeoutException({super.message = 'Request timeout', super.messageAr});
}
