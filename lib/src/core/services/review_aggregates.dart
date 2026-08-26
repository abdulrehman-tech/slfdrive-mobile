import '../data/repositories/review_repository.dart';
import '../models/review/review.dart';

/// Client-side per-vehicle / per-driver rating aggregates.
///
/// Neither `Vehicle/paginated` nor `Driver/paginated` returns a rating, and
/// per-entity `/stats` calls would be one request per card. Instead this loads
/// `GET /api/Review/active` once (deduped, cached for the app session) and
/// answers lookups synchronously from the nested `booking.vehicleId` /
/// `booking.driverId` on each review row. Lookups return null/empty until
/// [ensureLoaded] completes (or when the fetch fails, e.g. a guest's 401) —
/// callers then fall back to the "New" placeholder.
class ReviewAggregates {
  ReviewAggregates(this._reviews);

  final ReviewRepository _reviews;

  List<Review> _cache = const [];
  bool _loaded = false;
  Future<void>? _inFlight;

  bool get isLoaded => _loaded;
  List<Review> get all => _cache;

  /// Loads the review list once; concurrent callers share the same request.
  /// Never throws — a failure just leaves the cache empty.
  Future<void> ensureLoaded({bool force = false}) {
    if (_loaded && !force) return Future.value();
    return _inFlight ??= _load();
  }

  Future<void> _load() async {
    try {
      final rows = await _reviews.active();
      _cache = rows.where((r) => r.isActive).toList()
        ..sort((a, b) => (b.createdAt ?? '').compareTo(a.createdAt ?? ''));
      _loaded = true;
    } catch (_) {
      // Keep whatever we had; lookups degrade to "no rating".
    } finally {
      _inFlight = null;
    }
  }

  /// Drop the cache so the next [ensureLoaded] refetches (after a new review).
  void invalidate() => _loaded = false;

  List<Review> forVehicle(int? vehicleId) =>
      vehicleId == null ? const [] : _cache.where((r) => r.vehicleId == vehicleId).toList();

  /// [driverId] is the driver ENTITY id (`DriverListingItem.driverId`), which
  /// is what bookings reference — not the listing/user id.
  List<Review> forDriver(int? driverId) =>
      driverId == null ? const [] : _cache.where((r) => r.driverId == driverId).toList();

  double? vehicleAverage(int? vehicleId) => average(forVehicle(vehicleId));
  double? driverAverage(int? driverId) => average(forDriver(driverId));

  static double? average(List<Review> reviews) {
    if (reviews.isEmpty) return null;
    final sum = reviews.fold<int>(0, (a, r) => a + r.rating);
    return sum / reviews.length;
  }

  /// Star-count histogram ordered [5★, 4★, 3★, 2★, 1★].
  static List<int> distribution(List<Review> reviews) {
    final counts = [0, 0, 0, 0, 0];
    for (final r in reviews) {
      counts[5 - r.rating.clamp(1, 5)]++;
    }
    return counts;
  }
}
