import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../config/app_environment.dart';

String? get _trustedHost => AppEnvironment.current.selfSignedHost;

bool _allow(X509Certificate cert, String host, int port) {
  final trusted = _trustedHost;
  return trusted != null && host == trusted;
}

/// Trusts the environment's self-signed host on [dio]'s HttpClient. No-op when
/// the environment has no such host (prod).
void configureSelfSignedTls(Dio dio) {
  if (_trustedHost == null) return;
  final adapter = dio.httpClientAdapter;
  if (adapter is! IOHttpClientAdapter) return;
  adapter.createHttpClient = () {
    final client = HttpClient();
    client.badCertificateCallback = _allow;
    return client;
  };
}

class _SelfSignedHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback = _allow;
    return client;
  }
}

/// Trusts the environment's self-signed host for the default `HttpClient`
/// (image loading). No-op when the environment has no such host (prod).
void applySelfSignedHttpOverrides() {
  if (_trustedHost == null) return;
  HttpOverrides.global = _SelfSignedHttpOverrides();
}
