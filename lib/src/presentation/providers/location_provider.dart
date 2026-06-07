import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../../constants/storage_keys.dart';
import '../../core/data/repositories/auth_repository.dart';

/// Backs the home app-bar location chip.
///
/// Two ways the location is set:
///  - [resolve] auto-detects via GPS + reverse geocoding on first mount
///    (best-effort: stays null on denied permission / disabled services / web).
///  - [applyPickedLocation] is called after the user picks a point on the map
///    picker; it updates the label + coordinates, persists them, and pushes the
///    coordinates to the backend (`POST /api/User/set-location`).
///
/// A previously picked location is rehydrated from secure storage on
/// construction so it survives an app restart instead of re-prompting GPS.
class LocationProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  final FlutterSecureStorage _storage;

  LocationProvider(this._authRepository, this._storage) {
    _loadPersisted();
  }

  String? _locationName;
  double? _lat;
  double? _lon;
  bool _loading = false;
  bool _denied = false;
  bool _saving = false;

  /// Resolved "City, Country" (or picked address) label, or null when unset.
  String? get locationName => _locationName;
  double? get lat => _lat;
  double? get lon => _lon;
  bool get loading => _loading;
  bool get saving => _saving;

  /// True when the user denied the location permission.
  bool get denied => _denied;

  /// True once a coordinate is known (from GPS or the picker).
  bool get hasCoordinates => _lat != null && _lon != null;

  /// Rehydrate a previously picked location so the chip shows it on cold start.
  Future<void> _loadPersisted() async {
    final label = await _storage.read(key: StorageKeys.userLocationLabel);
    final lat = double.tryParse(await _storage.read(key: StorageKeys.userLat) ?? '');
    final lon = double.tryParse(await _storage.read(key: StorageKeys.userLon) ?? '');
    if (label != null && label.isNotEmpty) _locationName = label;
    _lat = lat;
    _lon = lon;
    if (_locationName != null || _lat != null) notifyListeners();
  }

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
      _lat = pos.latitude;
      _lon = pos.longitude;

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

  /// Applies a location chosen on the map picker: updates the chip, persists it
  /// locally, and pushes the coordinates to the backend (best-effort — a failed
  /// API call still keeps the chosen location on screen). Returns true when the
  /// server save succeeded.
  Future<bool> applyPickedLocation({
    required double lat,
    required double lon,
    required String address,
  }) async {
    _lat = lat;
    _lon = lon;
    if (address.trim().isNotEmpty) _locationName = address.trim();
    _saving = true;
    notifyListeners();

    await _storage.write(key: StorageKeys.userLat, value: lat.toString());
    await _storage.write(key: StorageKeys.userLon, value: lon.toString());
    if (_locationName != null) {
      await _storage.write(key: StorageKeys.userLocationLabel, value: _locationName);
    }

    var saved = false;
    try {
      final idStr = await _storage.read(key: StorageKeys.userId);
      final userId = int.tryParse(idStr ?? '');
      if (userId != null) {
        await _authRepository.setUserLocation(userId: userId, lat: lat, lon: lon);
        saved = true;
      }
    } catch (e) {
      if (kDebugMode) debugPrint('setUserLocation failed: $e');
    } finally {
      _saving = false;
      notifyListeners();
    }
    return saved;
  }
}
