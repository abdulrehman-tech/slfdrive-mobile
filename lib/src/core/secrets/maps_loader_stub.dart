import 'dart:async';

/// No-op on non-web platforms. Android & iOS load the Google Maps SDK from
/// their native config (manifest / Info.plist) at app start.
Future<void> ensureGoogleMapsLoaded() async {}
