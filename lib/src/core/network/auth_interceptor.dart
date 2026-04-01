import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants/storage_keys.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  AuthInterceptor(this._dio, this._secureStorage);

  static const List<String> _authEndpoints = [
    '/api/Auth/login-mobile',
    '/api/Auth/refresh',
    '/api/Auth/verify-otp',
  ];

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    if (!_authEndpoints.any((endpoint) => options.path.contains(endpoint))) {
      final accessToken = await _secureStorage.read(key: StorageKeys.accessToken);
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
      }
    }
    super.onRequest(options, handler);
  }

  @override
  Future<void> onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (response.statusCode == 401) {
      final isAuthEndpoint = _authEndpoints.any((endpoint) => response.requestOptions.path.contains(endpoint));

      if (!isAuthEndpoint) {
        final refreshedResponse = await _handleTokenRefresh(response.requestOptions);
        if (refreshedResponse != null) {
          return handler.resolve(refreshedResponse);
        }
      }
    }
    super.onResponse(response, handler);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final isAuthEndpoint = _authEndpoints.any((endpoint) => err.requestOptions.path.contains(endpoint));

      if (!isAuthEndpoint) {
        final refreshedResponse = await _handleTokenRefresh(err.requestOptions);
        if (refreshedResponse != null) {
          return handler.resolve(refreshedResponse);
        }
      }
    }
    super.onError(err, handler);
  }

  Future<Response?> _handleTokenRefresh(RequestOptions requestOptions) async {
    final refreshToken = await _secureStorage.read(key: StorageKeys.refreshToken);

    if (refreshToken == null) {
      await _clearTokens();
      return null;
    }

    try {
      final response = await _dio.post('/api/Auth/refresh', data: {'refreshToken': refreshToken});

      if (response.statusCode == 200 && response.data is Map && response.data['isSuccess'] == true) {
        final data = response.data['data'];
        final newAccessToken = data['accessToken'];
        final newRefreshToken = data['refreshToken'];

        await _secureStorage.write(key: StorageKeys.accessToken, value: newAccessToken);
        await _secureStorage.write(key: StorageKeys.refreshToken, value: newRefreshToken);

        final opts = Options(
          method: requestOptions.method,
          headers: {...requestOptions.headers, 'Authorization': 'Bearer $newAccessToken'},
        );

        final cloneReq = await _dio.request(
          requestOptions.path,
          options: opts,
          data: requestOptions.data,
          queryParameters: requestOptions.queryParameters,
        );

        return cloneReq;
      } else {
        await _clearTokens();
        return null;
      }
    } catch (e) {
      await _clearTokens();
      return null;
    }
  }

  Future<void> _clearTokens() async {
    await _secureStorage.delete(key: StorageKeys.accessToken);
    await _secureStorage.delete(key: StorageKeys.refreshToken);
    await _secureStorage.delete(key: StorageKeys.userId);
    await _secureStorage.delete(key: StorageKeys.userEmail);
    await _secureStorage.delete(key: StorageKeys.isLoggedIn);
  }
}
