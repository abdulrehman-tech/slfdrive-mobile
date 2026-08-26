/// Whether the installed build is behind the published one.
///
/// Versions are compared segment-wise and numerically, so `"1"` equals
/// `"1.0.0"` and `"1.0.10"` beats `"1.0.9"`. Non-numeric segments count as 0.
/// When the versions tie, a higher [latestBuild] still counts as outdated.
/// A missing/garbage [latestVersion] never reports outdated — the back-office
/// row may be a placeholder and must not lock users out.
bool isAppOutdated({
  required String currentVersion,
  required int currentBuild,
  required String? latestVersion,
  required int? latestBuild,
}) {
  final latest = _segments(latestVersion);
  if (latest == null) return false;
  final current = _segments(currentVersion) ?? const [0];

  final len = latest.length > current.length ? latest.length : current.length;
  for (var i = 0; i < len; i++) {
    final l = i < latest.length ? latest[i] : 0;
    final c = i < current.length ? current[i] : 0;
    if (l != c) return l > c;
  }
  return latestBuild != null && latestBuild > currentBuild;
}

List<int>? _segments(String? v) {
  if (v == null) return null;
  final trimmed = v.trim();
  if (trimmed.isEmpty) return null;
  // Ignore a trailing "+build" (pubspec style) — build is compared separately.
  final core = trimmed.split('+').first;
  final parts = core.split('.');
  if (!parts.any((p) => int.tryParse(p.trim()) != null)) return null;
  return parts.map((p) => int.tryParse(p.trim()) ?? 0).toList();
}
