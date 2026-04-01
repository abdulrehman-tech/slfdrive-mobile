import 'package:dio/dio.dart';
import 'app_exception.dart';

class ErrorHandler {
  static AppException handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is AppException) {
      return error;
    } else {
      return AppException(message: error.toString());
    }
  }

  static AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(
          message: 'Connection timeout. Please try again.',
          messageAr: 'انتهت مهلة الاتصال. يرجى المحاولة مرة أخرى.',
        );

      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);

      case DioExceptionType.cancel:
        return AppException(message: 'Request cancelled', messageAr: 'تم إلغاء الطلب');

      case DioExceptionType.connectionError:
        return NetworkException(message: 'No internet connection', messageAr: 'لا يوجد اتصال بالإنترنت');

      default:
        return AppException(message: 'Something went wrong', messageAr: 'حدث خطأ ما');
    }
  }

  static AppException _handleResponseError(Response? response) {
    if (response == null) {
      return ServerException(message: 'No response from server');
    }

    final statusCode = response.statusCode;
    final data = response.data;

    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? 'An error occurred';
      final messageAr = data['messageAr'];
      final errors = data['errors'] != null ? List<String>.from(data['errors']) : null;

      switch (statusCode) {
        case 400:
          return ValidationException(message: message, messageAr: messageAr, errors: errors);
        case 401:
          return UnauthorizedException(message: message, messageAr: messageAr);
        case 403:
          return AppException(message: message, messageAr: messageAr, statusCode: 403);
        case 404:
          return AppException(message: message, messageAr: messageAr, statusCode: 404);
        case 500:
        case 502:
        case 503:
          return ServerException(message: message, messageAr: messageAr, statusCode: statusCode);
        default:
          return AppException(message: message, messageAr: messageAr, statusCode: statusCode);
      }
    }

    return ServerException(message: 'Server error', statusCode: statusCode);
  }
}
