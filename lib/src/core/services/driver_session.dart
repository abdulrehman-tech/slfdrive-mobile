import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../constants/storage_keys.dart';
import '../data/repositories/driver_repository.dart';

/// Resolves and caches the signed-in driver's *driver-entity id* — the value
/// bookings reference as `driverId`, distinct from the stored user id.
///
/// `Booking/my/paginated` filters a driver's assigned bookings by `driverId`,
/// not `userId` (the latter is the booking's customer). We obtain it once from
/// `GET /api/Driver/{userId}` (`DriverDetails.driverId`) and cache it in secure
/// storage so subsequent loads skip the lookup.
class DriverSession {
  DriverSession(this._drivers, this._storage);

  final DriverRepository _drivers;
  final FlutterSecureStorage _storage;

  int? _cached;

  /// The driver-entity id, or null when it can't be resolved (e.g. no signed-in
  /// user, or the driver record has no driverId). Best-effort and memoised.
  Future<int?> driverId() async {
    if (_cached != null) return _cached;

    final stored = int.tryParse(await _storage.read(key: StorageKeys.driverId) ?? '');
    if (stored != null) return _cached = stored;

    final userId = int.tryParse(await _storage.read(key: StorageKeys.userId) ?? '');
    if (userId == null) return null;

    try {
      final details = await _drivers.getById(userId);
      final id = details?.driverId;
      if (id != null) {
        await _storage.write(key: StorageKeys.driverId, value: id.toString());
        return _cached = id;
      }
    } catch (_) {
      // Best-effort: leave unresolved so the caller can fall back.
    }
    return null;
  }

  /// Drops the in-memory cache (the persisted key is cleared on logout by the
  /// auth layer). Call when switching accounts.
  void clear() => _cached = null;
}
