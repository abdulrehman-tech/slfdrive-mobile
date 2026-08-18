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
  Future<int?>? _pending;

  /// Bumped by [clear] so a lookup that was in flight when the account changed
  /// can never cache or persist the previous account's id afterwards.
  int _gen = 0;

  /// The driver-entity id, or null when it can't be resolved (e.g. no signed-in
  /// user, or the driver record has no driverId). Best-effort and memoised;
  /// concurrent callers share a single in-flight lookup instead of each issuing
  /// their own `GET /api/Driver/{userId}`.
  Future<int?> driverId() {
    if (_cached != null) return Future.value(_cached);
    if (_pending != null) return _pending!;
    late final Future<int?> tracked;
    tracked = _resolve(_gen).whenComplete(() {
      // Keep the memo only on success so a transient failure can be retried;
      // only this lookup may clear the slot (a newer one may already own it).
      if (_cached == null && identical(_pending, tracked)) _pending = null;
    });
    return _pending = tracked;
  }

  Future<int?> _resolve(int gen) async {
    final stored = int.tryParse(await _storage.read(key: StorageKeys.driverId) ?? '');
    if (gen != _gen) return null; // account changed mid-flight — discard
    if (stored != null) return _cached = stored;

    final userId = int.tryParse(await _storage.read(key: StorageKeys.userId) ?? '');
    if (gen != _gen || userId == null) return null;

    try {
      final details = await _drivers.getById(userId);
      final id = details?.driverId;
      if (gen != _gen) return null;
      if (id != null) {
        await _storage.write(key: StorageKeys.driverId, value: id.toString());
        if (gen != _gen) return null;
        return _cached = id;
      }
    } catch (_) {
      // Best-effort: leave unresolved so the caller can fall back.
    }
    return null;
  }

  /// Drops the in-memory cache and orphans any in-flight lookup (the persisted
  /// key is cleared on logout by the auth layer). Call when switching accounts.
  void clear() {
    _gen++;
    _cached = null;
    _pending = null;
  }
}
