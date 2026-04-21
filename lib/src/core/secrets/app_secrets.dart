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
}
