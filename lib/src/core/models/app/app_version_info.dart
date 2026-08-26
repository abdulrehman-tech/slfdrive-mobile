/// Latest published app version as returned by
/// `GET /api/app-version/check/{appName}`. Parsed leniently — the back-office
/// row may hold placeholder values (e.g. `version: "1"`, URLs `"1"`), and a
/// malformed row must never block the app.
class AppVersionInfo {
  final String? version;
  final int? buildNumber;
  final bool forceUpdate;
  final String? message;
  final String? playStoreUrl;
  final String? appStoreUrl;
  final bool isActive;

  const AppVersionInfo({
    this.version,
    this.buildNumber,
    this.forceUpdate = false,
    this.message,
    this.playStoreUrl,
    this.appStoreUrl,
    this.isActive = true,
  });

  factory AppVersionInfo.fromJson(Map<String, dynamic> json) {
    final rawBuild = json['buildNumber'];
    return AppVersionInfo(
      version: json['version']?.toString(),
      buildNumber: rawBuild is num ? rawBuild.toInt() : int.tryParse('${rawBuild ?? ''}'),
      forceUpdate: json['forceUpdate'] == true,
      message: json['message'] as String?,
      playStoreUrl: json['playStoreUrl'] as String?,
      appStoreUrl: json['appStoreUrl'] as String?,
      isActive: (json['isActive'] as bool?) ?? true,
    );
  }
}
