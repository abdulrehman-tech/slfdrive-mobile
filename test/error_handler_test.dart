import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slfdrive/src/core/errors/app_exception.dart';
import 'package:slfdrive/src/core/errors/error_handler.dart';

// No translations are loaded here, so `.tr()` returns the key itself.
const _unavailable = 'error_service_unavailable';

DioException _badResponse(int status, dynamic body) {
  final options = RequestOptions(path: '/api/x');
  return DioException(
    requestOptions: options,
    type: DioExceptionType.badResponse,
    response: Response(requestOptions: options, statusCode: status, data: body),
  );
}

void main() {
  test('a failed body cast never leaks its raw text', () {
    Object? caught;
    try {
      ('Not Found' as dynamic) as Map<String, dynamic>;
    } catch (e) {
      caught = e;
    }
    final e = ErrorHandler.handleError(caught);
    expect(e.message, _unavailable);
  });

  test('5xx hides the server message', () {
    final e = ErrorHandler.handleError(
      _badResponse(500, {'isSuccess': false, 'message': 'Object reference not set to an instance of an object.'}),
    );
    expect(e, isA<ServerException>());
    expect(e.message, _unavailable);
    expect(e.statusCode, 500);
  });

  test('4xx with an empty or non-JSON body is generic', () {
    expect(ErrorHandler.handleError(_badResponse(404, '')).message, _unavailable);
    expect(ErrorHandler.handleError(_badResponse(404, '<html></html>')).message, _unavailable);
  });

  test('4xx envelope keeps the server message', () {
    final e = ErrorHandler.handleError(
      _badResponse(400, {'isSuccess': false, 'message': 'Promo code expired', 'errors': ['expired']}),
    );
    expect(e, isA<ValidationException>());
    expect(e.message, 'Promo code expired');
    expect(e.errors, ['expired']);
  });

  test('ASP.NET ProblemDetails (errors is a map, no message) does not throw', () {
    final e = ErrorHandler.handleError(
      _badResponse(400, {
        'title': 'One or more validation errors occurred.',
        'status': 400,
        'errors': {
          'id': ['The value is not valid.'],
        },
      }),
    );
    expect(e.message, _unavailable);
    expect(e.errors, isNull);
  });

  test('timeouts and connection errors map to their own messages', () {
    final options = RequestOptions(path: '/api/x');
    expect(
      ErrorHandler.handleError(DioException(requestOptions: options, type: DioExceptionType.receiveTimeout)).message,
      'error_timeout',
    );
    expect(
      ErrorHandler.handleError(DioException(requestOptions: options, type: DioExceptionType.connectionError)).message,
      'error_no_internet',
    );
  });
}
