// ignore_for_file: avoid_print
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../constants/endpoints.dart';
import 'api_interceptor.dart';
import 'auth_interceptor.dart';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;

  ApiClient(this._secureStorage) {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        validateStatus: (status) => status! < 500,
      ),
    );

    // The backend is served over HTTPS on a raw IP with a self-signed cert, so
    // its TLS handshake would fail in every build mode. Accept the bad cert for
    // that single host only (every other host stays fully verified). Applied in
    // all modes — not just debug — so release builds on device can connect.
    // TODO: remove this host bypass once the backend has a valid TLS cert.
    const trustedSelfSignedHost = '161.97.144.112';
    (_dio.httpClientAdapter as IOHttpClientAdapter).createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (X509Certificate cert, String host, int port) {
        final allow = host == trustedSelfSignedHost;
        if (allow && kDebugMode) {
          print('⚠️ WARNING: Bypassing SSL certificate verification for $host:$port');
        }
        return allow;
      };
      return client;
    };

    // Add interceptors
    _dio.interceptors.add(ApiInterceptor());
    _dio.interceptors.add(AuthInterceptor(_dio, _secureStorage));
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
