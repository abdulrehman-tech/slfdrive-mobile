import 'package:dio/dio.dart';

/// Web no-op: the browser owns TLS verification.
void configureSelfSignedTls(Dio dio) {}

/// Web no-op: image loading goes through the browser, not a Dart `HttpClient`.
void applySelfSignedHttpOverrides() {}
