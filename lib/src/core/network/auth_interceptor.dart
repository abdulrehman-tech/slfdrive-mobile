import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants/endpoints.dart';
import '../../constants/storage_keys.dart';
import '../services/session_manager.dart';

class AuthInterceptor extends Interceptor {
  final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final SessionManager _sessionManager;

  AuthInterceptor(this._dio, this._secureStorage, this._sessionManager);

  // Paths are relative to ApiEndpoints.baseUrl (which already ends in `/api`).
  static const List<String> _authEndpoints = [
    ApiEndpoints.loginMobile,
    ApiEndpoints.refresh,
    ApiEndpoints.verifyOtp,
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

  // The base Dio uses `validateStatus: (s) => s < 500`, so a 401 arrives as a
  // *successful* response (onResponse), while a 500 (e.g. a rejected refresh
  // token) arrives as an error (onError). Both paths funnel through the same
  // handling. A 401 with an empty body would otherwise reach the repositories
  // and crash their `res.data as Map` casts ("… is not a subtype of Map") —
  // hence we always convert an unrecoverable 401 into a clean auth error.
  @override
  Future<void> onResponse(Response response, ResponseInterceptorHandler handler) async {
    if (response.statusCode == 401 && !_isAuthEndpoint(response.requestOptions.path)) {
      final refreshedResponse = await _handleTokenRefresh(response.requestOptions);
      if (refreshedResponse != null) {
        return handler.resolve(refreshedResponse);
      }
      return handler.reject(_sessionExpiredError(response.requestOptions));
    }
    super.onResponse(response, handler);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !_isAuthEndpoint(err.requestOptions.path)) {
      final refreshedResponse = await _handleTokenRefresh(err.requestOptions);
      if (refreshedResponse != null) {
        return handler.resolve(refreshedResponse);
      }
      return handler.reject(_sessionExpiredError(err.requestOptions));
    }
    super.onError(err, handler);
  }

  bool _isAuthEndpoint(String path) => _authEndpoints.any((e) => path.contains(e));

  /// A synthetic 401 whose body is a well-formed error envelope, so
  /// `ErrorHandler` maps it to a clean `UnauthorizedException` instead of the UI
  /// crashing on an empty body.
  DioException _sessionExpiredError(RequestOptions options) => DioException(
        requestOptions: options,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: options,
          statusCode: 401,
          data: {
            'isSuccess': false,
            'message': 'Your session has expired. Please sign in again.',
            'messageAr': 'انتهت صلاحية جلستك. يرجى تسجيل الدخول مرة أخرى.',
          },
        ),
      );

  Future<Response?> _handleTokenRefresh(RequestOptions requestOptions) async {
    final accessToken = await _secureStorage.read(key: StorageKeys.accessToken);
    final refreshToken = await _secureStorage.read(key: StorageKeys.refreshToken);

    // No refresh token: can't renew. Only treat this as an *expiry* (forcing a
    // logout) if the caller was actually signed in — a guest hitting a
    // protected endpoint just gets a clean auth error, no forced logout.
    if (refreshToken == null || refreshToken.isEmpty) {
      if (accessToken != null && accessToken.isNotEmpty) {
        await _clearTokens();
        _sessionManager.notifyExpired();
      }
      return null;
    }

    try {
      final response = await _dio.post(ApiEndpoints.refresh, data: {'refreshToken': refreshToken});

      final data = response.statusCode == 200 && response.data is Map && response.data['isSuccess'] == true
          ? response.data['data']
          : null;
      final newAccessToken = data is Map ? data['accessToken'] as String? : null;
      final newRefreshToken = data is Map ? data['refreshToken'] as String? : null;

      // Refresh failed (non-200, backend 500 on a stale refresh token, or an
      // empty token payload) → the session is unrecoverable: clear + signal.
      if (newAccessToken == null || newAccessToken.isEmpty) {
        await _clearTokens();
        _sessionManager.notifyExpired();
        return null;
      }

      await _secureStorage.write(key: StorageKeys.accessToken, value: newAccessToken);
      if (newRefreshToken != null && newRefreshToken.isNotEmpty) {
        await _secureStorage.write(key: StorageKeys.refreshToken, value: newRefreshToken);
      }

      final opts = Options(
        method: requestOptions.method,
        headers: {...requestOptions.headers, 'Authorization': 'Bearer $newAccessToken'},
      );

      return await _dio.request(
        requestOptions.path,
        options: opts,
        data: requestOptions.data,
        queryParameters: requestOptions.queryParameters,
      );
    } catch (e) {
      await _clearTokens();
      _sessionManager.notifyExpired();
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
