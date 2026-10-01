import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'app_exception.dart';

class ErrorHandler {
  static AppException handleError(dynamic error) {
    if (error is DioException) {
      return _handleDioError(error);
    } else if (error is AppException) {
      return error;
    } else {
      // Anything else is a programming-level failure the user can do nothing
      // with — typically a `res.data as Map` cast on a 404/empty/HTML body from
      // an endpoint that is missing in this environment. Never surface the raw
      // text ("type 'String' is not a subtype of …").
      debugPrint('[ErrorHandler] Unexpected ${error.runtimeType}: $error');
      return AppException(message: 'error_service_unavailable'.tr());
    }
  }

  static AppException _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutException(message: 'error_timeout'.tr());

      case DioExceptionType.badResponse:
        return _handleResponseError(error.response);

      case DioExceptionType.cancel:
        return AppException(message: 'Request cancelled', messageAr: 'تم إلغاء الطلب');

      case DioExceptionType.connectionError:
        return NetworkException(message: 'error_no_internet'.tr());

      default:
        return AppException(message: 'error_occurred'.tr());
    }
  }

  static AppException _handleResponseError(Response? response) {
    final unavailable = 'error_service_unavailable'.tr();
    if (response == null) {
      return ServerException(message: unavailable);
    }

    final statusCode = response.statusCode;
    final data = response.data;

    // 5xx bodies carry server internals (exception text, stack traces), not
    // something written for the user — always show the generic message.
    if (statusCode != null && statusCode >= 500) {
      return ServerException(message: unavailable, statusCode: statusCode);
    }

    if (data is Map<String, dynamic>) {
      final message = _text(data['message']) ?? unavailable;
      final messageAr = _text(data['messageAr']);
      // The API envelope sends `errors` as a list; ASP.NET's own validation
      // responses (ProblemDetails) send a map — only the former is usable.
      final rawErrors = data['errors'];
      final errors = rawErrors is List ? rawErrors.map((e) => e.toString()).toList() : null;

      switch (statusCode) {
        case 400:
          return ValidationException(message: message, messageAr: messageAr, errors: errors);
        case 401:
          return UnauthorizedException(message: message, messageAr: messageAr);
        default:
          return AppException(message: message, messageAr: messageAr, statusCode: statusCode);
      }
    }

    // Empty / plain-text / HTML body (e.g. a 404 from the gateway).
    return ServerException(message: unavailable, statusCode: statusCode);
  }

  static String? _text(dynamic value) => value is String && value.trim().isNotEmpty ? value : null;
}
