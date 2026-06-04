// Applies a global HttpOverrides (mobile/desktop only) that trusts the
// backend's self-signed TLS cert for the media host, so Image.network can load
// profile photos / documents from it. On web this is a no-op — image loading
// goes through the browser, not a Dart HttpClient.
//
// Conditional import mirrors `core/secrets/maps_loader.dart`.
export 'media_http_override_stub.dart'
    if (dart.library.io) 'media_http_override_io.dart';
