import 'dart:math' as math;

import 'package:geocoding/geocoding.dart';

import '../data/repositories/lookup_repository.dart';
import '../models/lookup/location_option.dart';

/// Turns a raw `lat/lon` into a human-readable place name.
///
/// The booking API carries only coordinates (no address text), so driver-facing
/// cards would otherwise show "23.5880, 58.3829". This resolves a coordinate to
/// a name with graceful degradation:
///   1. Native reverse geocoding (`geocoding` plugin) — real street/area name.
///      Unsupported on web/desktop, where it throws and we fall through.
///   2. Nearest serviceable area from `/api/Location/active` (client-side
///      great-circle match) — e.g. "Bawshar, Muscat".
///   3. The compact coordinate string, as a last resort.
///
/// Results are cached per (4-dp) coordinate so a list of cards resolves each
/// unique point once.
class PlaceNamer {
  PlaceNamer(this._lookup);

  final LookupRepository _lookup;

  List<LocationOption>? _areas;
  final Map<String, String> _cache = {};

  /// Resolves [lat]/[lon] to a place name, or '' when either is missing.
  Future<String> describe(double? lat, double? lon) async {
    if (lat == null || lon == null) return '';
    final key = _key(lat, lon);
    final hit = _cache[key];
    if (hit != null) return hit;

    String? name = await _reverseGeocode(lat, lon);
    if (name == null) {
      await _ensureAreas();
      name = _nearestArea(lat, lon);
    }
    name ??= key;
    _cache[key] = name;
    return name;
  }

  Future<String?> _reverseGeocode(double lat, double lon) async {
    try {
      final marks = await placemarkFromCoordinates(lat, lon);
      if (marks.isEmpty) return null;
      final m = marks.first;
      final parts = <String?>[m.subLocality, m.locality, m.administrativeArea]
          .map((s) => s?.trim())
          .where((s) => s != null && s.isNotEmpty)
          .cast<String>()
          .toSet()
          .toList();
      if (parts.isEmpty) return null;
      return parts.take(2).join(', ');
    } catch (_) {
      // Plugin unavailable (web/desktop) or no network — defer to the fallback.
      return null;
    }
  }

  String? _nearestArea(double lat, double lon) {
    final areas = _areas;
    if (areas == null || areas.isEmpty) return null;
    LocationOption? best;
    double bestKm = double.infinity;
    for (final a in areas) {
      final alat = a.lat;
      final alon = a.lon;
      if (alat == null || alon == null) continue;
      final km = _haversineKm(lat, lon, alat, alon);
      if (km < bestKm) {
        bestKm = km;
        best = a;
      }
    }
    return best?.label;
  }

  Future<void> _ensureAreas() async {
    if (_areas != null) return;
    try {
      _areas = await _lookup.getActiveLocations();
    } catch (_) {
      _areas = const [];
    }
  }

  String _key(double lat, double lon) =>
      '${lat.toStringAsFixed(4)}, ${lon.toStringAsFixed(4)}';

  double _haversineKm(double lat1, double lon1, double lat2, double lon2) {
    const r = 6371.0; // earth radius km
    final dLat = _rad(lat2 - lat1);
    final dLon = _rad(lon2 - lon1);
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(lat1)) * math.cos(_rad(lat2)) * math.sin(dLon / 2) * math.sin(dLon / 2);
    return r * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
  }

  double _rad(double deg) => deg * math.pi / 180.0;
}
