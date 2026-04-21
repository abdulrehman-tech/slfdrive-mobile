// Platform-dispatched Google Maps loader.
//
// Web needs the Maps JS SDK `<script>` tag loaded before any `GoogleMap`
// widget is mounted. To keep the API key out of `web/index.html`, the
// `_web` implementation injects the script at runtime using the value from
// `--dart-define=GOOGLE_MAPS_API_KEY=...`. All other platforms are no-ops:
// Android/iOS load the SDK from their native config (manifest / Info.plist).

export 'maps_loader_stub.dart'
    if (dart.library.js_interop) 'maps_loader_web.dart';
