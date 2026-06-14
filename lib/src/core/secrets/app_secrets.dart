/// App-wide compile-time secrets.
///
/// Keys are supplied to the Flutter build via
/// `flutter run --dart-define-from-file=.env` (or one-off
/// `--dart-define=GOOGLE_MAPS_API_KEY=...`). The `.env` file is gitignored,
/// so no secret ever lands in source control.
///
/// Native platforms (Android manifest, iOS Info.plist) source the same values
/// from their own gitignored secret files — see `SECRETS.md`.
class AppSecrets {
  const AppSecrets._();

  /// Google Maps JS API key used only on web, where the Maps script tag is
  /// injected at runtime by `maps_loader_web.dart`. On iOS/Android the native
  /// SDK reads the key from Info.plist / AndroidManifest respectively, so this
  /// constant is unused there.
  static const String googleMapsApiKey = String.fromEnvironment('GOOGLE_MAPS_API_KEY');

  /// Key for the Places API (New) REST calls used by the location-picker search
  /// (see `PlacesService`). These run over plain HTTPS from the device, so the
  /// key must NOT carry an HTTP-referrer or Android/iOS application restriction
  /// (those block keyless-referer REST calls — `API_KEY_HTTP_REFERRER_BLOCKED`).
  /// Restrict it by API ("Places API (New)") instead. Falls back to
  /// [googleMapsApiKey] when unset (e.g. on web, where the web key's origin
  /// restriction already covers REST).
  static const String _placesApiKey = String.fromEnvironment('PLACES_API_KEY');
  static String get placesApiKey => _placesApiKey.isNotEmpty ? _placesApiKey : googleMapsApiKey;
}
