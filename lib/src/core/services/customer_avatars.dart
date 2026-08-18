import '../../constants/endpoints.dart';
import '../data/repositories/customer_repository.dart';

/// Resolves and caches a customer's profile photo URL by their user id.
///
/// The booking API carries the customer's name/phone but not their photo, so
/// driver-facing cards fetch it on demand from `GET /api/Customer/{id}`. Results
/// (including misses) are memoised so a request list resolves each customer once.
class CustomerAvatars {
  CustomerAvatars(this._customers);

  final CustomerRepository _customers;
  final Map<int, String?> _cache = {};
  final Map<int, Future<String?>> _inFlight = {};

  /// Absolute photo URL for [userId], or null when unknown / unavailable.
  /// Concurrent callers for the same customer share one request — the driver
  /// shell enriches whole booking pages in parallel, so without this a page
  /// with 200 bookings from 5 customers would fire 200 GETs instead of 5.
  Future<String?> photoUrl(int? userId) {
    if (userId == null) return Future.value(null);
    if (_cache.containsKey(userId)) return Future.value(_cache[userId]);
    return _inFlight[userId] ??=
        _resolve(userId).whenComplete(() => _inFlight.remove(userId));
  }

  Future<String?> _resolve(int userId) async {
    String? url;
    try {
      final c = await _customers.getById(userId);
      url = ApiEndpoints.resolveMediaUrl(c?.photoUrl);
    } catch (_) {
      url = null;
    }
    _cache[userId] = url;
    return url;
  }
}
