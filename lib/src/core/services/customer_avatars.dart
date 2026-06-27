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

  /// Absolute photo URL for [userId], or null when unknown / unavailable.
  Future<String?> photoUrl(int? userId) async {
    if (userId == null) return null;
    if (_cache.containsKey(userId)) return _cache[userId];
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
