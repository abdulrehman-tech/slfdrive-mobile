// Scoped self-signed TLS trust for the UAT host (mobile/desktop only).
//
// UAT is served from a raw IP with a self-signed cert, so both the Dio client
// and the default `HttpClient` (used by `Image.network` / cached images) must
// accept that one host's cert; every other host stays fully verified. Prod has
// no self-signed host, so these are no-ops there. On web the browser owns TLS,
// so there is nothing to override — conditional import mirrors
// `core/secrets/maps_loader.dart`.
export 'self_signed_tls_stub.dart'
    if (dart.library.io) 'self_signed_tls_io.dart';
