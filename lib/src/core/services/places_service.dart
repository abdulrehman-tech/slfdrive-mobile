import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../secrets/app_secrets.dart';

/// A single Places Autocomplete suggestion.
class PlacePrediction {
  final String placeId;
  final String primaryText;
  final String secondaryText;

  const PlacePrediction({
    required this.placeId,
    required this.primaryText,
    required this.secondaryText,
  });

  /// Combined label, e.g. "Muscat Grand Mall, Muscat, Oman".
  String get fullText =>
      secondaryText.isEmpty ? primaryText : '$primaryText, $secondaryText';
}

/// Resolved coordinates + address for a chosen place.
class PlaceDetails {
  final double lat;
  final double lon;
  final String address;

  const PlaceDetails({required this.lat, required this.lon, required this.address});
}

/// Thin client for the Google **Places API (New)** used by the location-picker
/// search bar (autocomplete + place details).
///
/// Uses its own [Dio] instance — NOT the app `ApiClient` — so it never carries
/// the SLF bearer token or hits the SLF base URL. The key comes from
/// [AppSecrets.placesApiKey] (supplied via `--dart-define-from-file=.env`).
/// All calls degrade gracefully to empty/null when the key is missing or the
/// request fails, so the picker still works via map-drag + reverse geocoding.
///
/// Requires "Places API (New)" enabled on the key, with restrictions that allow
/// REST calls from the target platform (no Android-app restriction for mobile
/// REST; add the web origin for web).
class PlacesService {
  PlacesService({Dio? dio})
      : _dio = dio ??
            Dio(BaseOptions(
              baseUrl: 'https://places.googleapis.com/v1',
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ));

  final Dio _dio;

  bool get _hasKey => AppSecrets.placesApiKey.isNotEmpty;

  /// Autocomplete predictions for [input]. Returns an empty list on empty key,
  /// short input, or any error.
  Future<List<PlacePrediction>> autocomplete(String input, {String? sessionToken}) async {
    if (!_hasKey || input.trim().length < 2) return const [];
    try {
      final res = await _dio.post(
        '/places:autocomplete',
        data: {
          'input': input,
          'sessionToken': ?sessionToken,
        },
        options: Options(headers: {
          'Content-Type': 'application/json',
          'X-Goog-Api-Key': AppSecrets.placesApiKey,
        }),
      );
      final data = res.data;
      if (data is! Map) return const [];
      final suggestions = data['suggestions'];
      if (suggestions is! List) return const [];
      final out = <PlacePrediction>[];
      for (final s in suggestions) {
        if (s is! Map) continue;
        final pp = s['placePrediction'];
        if (pp is! Map) continue;
        final placeId = pp['placeId'] as String?;
        if (placeId == null) continue;
        final structured = pp['structuredFormat'];
        String primary = '';
        String secondary = '';
        if (structured is Map) {
          primary = (structured['mainText'] is Map ? structured['mainText']['text'] : null) as String? ?? '';
          secondary = (structured['secondaryText'] is Map ? structured['secondaryText']['text'] : null) as String? ?? '';
        }
        if (primary.isEmpty) {
          primary = (pp['text'] is Map ? pp['text']['text'] : null) as String? ?? '';
        }
        if (primary.isEmpty) continue;
        out.add(PlacePrediction(placeId: placeId, primaryText: primary, secondaryText: secondary));
      }
      return out;
    } catch (e) {
      _logError('autocomplete', e);
      return const [];
    }
  }

  /// Resolves a place id into coordinates + formatted address, or null on error.
  Future<PlaceDetails?> details(String placeId, {String? sessionToken}) async {
    if (!_hasKey) return null;
    try {
      final res = await _dio.get(
        '/places/$placeId',
        queryParameters: {'sessionToken': ?sessionToken},
        options: Options(headers: {
          'X-Goog-Api-Key': AppSecrets.placesApiKey,
          'X-Goog-FieldMask': 'location,formattedAddress,displayName',
        }),
      );
      final data = res.data;
      if (data is! Map) return null;
      final loc = data['location'];
      if (loc is! Map) return null;
      final lat = (loc['latitude'] as num?)?.toDouble();
      final lon = (loc['longitude'] as num?)?.toDouble();
      if (lat == null || lon == null) return null;
      final address = (data['formattedAddress'] as String?) ??
          (data['displayName'] is Map ? data['displayName']['text'] as String? : null) ??
          '';
      return PlaceDetails(lat: lat, lon: lon, address: address);
    } catch (e) {
      _logError('details', e);
      return null;
    }
  }

  /// Logs the Google error body (not just the Dio wrapper) so a 403 reveals the
  /// real cause — e.g. "Places API (New) has not been used in project ..." or
  /// "requests from referer/app are blocked" (a platform restriction blocking
  /// REST calls).
  void _logError(String op, Object e) {
    if (!kDebugMode) return;
    if (e is DioException) {
      debugPrint('PlacesService.$op HTTP ${e.response?.statusCode}: ${e.response?.data}');
    } else {
      debugPrint('PlacesService.$op failed: $e');
    }
  }
}
