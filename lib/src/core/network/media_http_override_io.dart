import 'dart:io';

/// Host that serves uploaded media over a self-signed cert. Kept in sync with
/// `ApiEndpoints.mediaBaseUrl` / the trusted host in `api_client.dart`.
const String _trustedSelfSignedHost = 'dashboard.slf-drives.com';

/// Trusts the self-signed cert for the media host only — every other host stays
/// fully verified. Mirrors the per-host bypass already applied to the Dio
/// client, but for the default `HttpClient` that `Image.network` uses.
/// TODO: remove once the backend has a valid TLS cert.
class _MediaHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    final client = super.createHttpClient(context);
    client.badCertificateCallback =
        (X509Certificate cert, String host, int port) => host == _trustedSelfSignedHost;
    return client;
  }
}

void applySelfSignedMediaOverride() {
  HttpOverrides.global = _MediaHttpOverrides();
}
