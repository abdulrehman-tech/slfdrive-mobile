import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

/// A captured device location.
class DeviceLocation {
  final double lat;
  final double lon;
  const DeviceLocation(this.lat, this.lon);
}

/// Thin wrapper around `geolocator` that runs the full foreground-permission
/// flow and returns `null` whenever a fix can't be obtained (services off,
/// permission denied, timeout). Callers treat location as best-effort — it is
/// never required to complete a flow.
class LocationService {
  const LocationService();

  /// Returns the current position, or `null` if unavailable. Never throws.
  ///
  /// Order: ensure the OS location service is on, then check/request the
  /// runtime permission. A `deniedForever` result returns `null` (the caller
  /// can point the user at app settings) rather than prompting in a loop.
  Future<DeviceLocation?> getCurrentLocation({
    Duration timeout = const Duration(seconds: 15),
  }) async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: timeout,
        ),
      );
      return DeviceLocation(pos.latitude, pos.longitude);
    } catch (e) {
      if (kDebugMode) debugPrint('LocationService.getCurrentLocation failed: $e');
      return null;
    }
  }
}
