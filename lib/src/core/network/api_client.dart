// ignore_for_file: avoid_print
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants/endpoints.dart';
import '../services/session_manager.dart';
import 'api_interceptor.dart';
import 'auth_interceptor.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final SessionManager _sessionManager;

  ApiClient(this._secureStorage, this._sessionManager) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        validateStatus: (status) => status! < 500,
      ),
    );

    // Add interceptors
    _dio.interceptors.add(ApiInterceptor());
    _dio.interceptors.add(AuthInterceptor(_dio, _secureStorage, _sessionManager));
  }

  Dio get dio => _dio;

  Future<Response> get(String path, {Map<String, dynamic>? queryParameters, Options? options}) async {
    return await _dio.get(path, queryParameters: queryParameters, options: options);
  }

  Future<Response> post(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    return await _dio.post(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> put(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    return await _dio.put(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> delete(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    return await _dio.delete(path, data: data, queryParameters: queryParameters, options: options);
  }

  Future<Response> patch(String path, {dynamic data, Map<String, dynamic>? queryParameters, Options? options}) async {
    return await _dio.patch(path, data: data, queryParameters: queryParameters, options: options);
  }

  /// POST request with multipart/form-data for file uploads
  Future<Response> postMultipart(String path, {required FormData data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(contentType: 'multipart/form-data', headers: {'Accept': 'application/json'}),
    );
  }

  /// PUT request with multipart/form-data for file uploads (profile updates)
  Future<Response> putMultipart(String path, {required FormData data, Map<String, dynamic>? queryParameters}) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: Options(contentType: 'multipart/form-data', headers: {'Accept': 'application/json'}),
    );
  }
}
