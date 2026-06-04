import 'package:flutter/foundation.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

/// Resolves the device's current location into a short, human-readable label
/// (e.g. "Muscat, Oman") for the home app bar via GPS + reverse geocoding.
///
/// Best-effort: stays null on denied permission, disabled location services,
/// or web (the `geocoding` plugin has no web implementation), so the UI falls
/// back to its default localized label.
class LocationProvider extends ChangeNotifier {
  String? _locationName;
  bool _loading = false;
  bool _denied = false;

  /// Resolved "City, Country" label, or null when unavailable.
  String? get locationName => _locationName;
  bool get loading => _loading;

  /// True when the user denied the location permission.
  bool get denied => _denied;

  /// Requests permission (if needed), reads the current position, and reverse
  /// geocodes it. Notifies listeners on each state change. Safe to call
  /// repeatedly; no-ops while a resolve is already in flight.
  Future<void> resolve() async {
    if (_loading) return;
    _loading = true;
    notifyListeners();
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        _denied = true;
        return;
      }
      _denied = false;

      final pos = await Geolocator.getCurrentPosition();

      // The geocoding plugin throws on web — skip and keep the fallback label.
      if (kIsWeb) return;

      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isEmpty) return;
      final p = placemarks.first;

      final city = [p.locality, p.subAdministrativeArea, p.administrativeArea]
          .firstWhere((e) => (e ?? '').isNotEmpty, orElse: () => null);
      final parts = <String>[
        if ((city ?? '').isNotEmpty) city!,
        if ((p.country ?? '').isNotEmpty) p.country!,
      ];
      if (parts.isNotEmpty) _locationName = parts.join(', ');
    } catch (e) {
      if (kDebugMode) debugPrint('LocationProvider.resolve failed: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
