/// Backend environment the build talks to. Selected at compile time via
/// `--dart-define=APP_ENV=uat|prod` (defaults to prod), so a single `.env`
/// can be shared and the UAT target is just another launch config
/// (see `.vscode/launch.json` → "SLF Drive UAT").
///
/// UAT is served from a raw IP with a self-signed certificate, so it also
/// carries the host the TLS bypass is scoped to — prod has none.
enum AppEnvironment {
  prod(
    apiBaseUrl: 'https://dashboard.slf-drives.com/api',
    mediaBaseUrl: 'https://dashboard.slf-drives.com',
    selfSignedHost: null,
  ),
  uat(
    apiBaseUrl: 'https://161.97.144.112/api',
    mediaBaseUrl: 'https://161.97.144.112',
    selfSignedHost: '161.97.144.112',
  );

  const AppEnvironment({
    required this.apiBaseUrl,
    required this.mediaBaseUrl,
    required this.selfSignedHost,
  });

  /// Base URL — includes the `/api` segment (see `ApiEndpoints.baseUrl`).
  final String apiBaseUrl;

  /// Media host (no `/api`); stored photo/document URLs are relative to it.
  final String mediaBaseUrl;

  /// Host whose self-signed TLS cert is trusted (UAT only), or null.
  final String? selfSignedHost;

  static const String _raw = String.fromEnvironment('APP_ENV', defaultValue: 'prod');

  /// The environment this build was compiled for.
  static AppEnvironment get current =>
      _raw.toLowerCase() == 'uat' ? AppEnvironment.uat : AppEnvironment.prod;

  bool get isProd => this == AppEnvironment.prod;
  bool get isUat => this == AppEnvironment.uat;
}
