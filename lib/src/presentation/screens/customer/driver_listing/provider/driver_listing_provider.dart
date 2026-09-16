import 'package:flutter/foundation.dart';

import '../../../../../core/data/repositories/driver_listing_repository.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/models/common/pagination_params.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/models/driver/driver_listing_item.dart';
import '../../../../../core/services/review_aggregates.dart';
import '../../../../../core/utils/paged_list.dart';
import '../models/driver_item.dart';

/// Vehicle-filter values for the chip bar.
///
/// The backend has no speciality concept, so we repurpose the filter chips to
/// a simple "All / Has Vehicle" toggle that uses [DriverListingItem.hasVehicle].
enum DriverVehicleFilter { all, hasVehicle }

/// Loads drivers page by page. The freelance/has-vehicle filters run
/// client-side (the backend can't filter on a missing company), relying on
/// `LoadMoreListener` paging on until the visible list fills up. No sorting:
/// the API ignores `sortBy`, and sorting only the loaded page would mislead.
class DriverListingProvider extends ChangeNotifier {
  final DriverListingRepository _repo;
  final bool _ar;
  final ReviewAggregates _ratings;

  DriverListingProvider({
    required DriverListingRepository repository,
    ReviewAggregates? reviewAggregates,
    bool ar = false,
  })  : _repo = repository,
        _ratings = reviewAggregates ?? getIt<ReviewAggregates>(),
        _ar = ar {
    load();
  }

  static const int _pageSize = 20;

  // ---- State ----
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  late final PagedList<DriverListingItem> _paged = PagedList<DriverListingItem>(
    pageSize: _pageSize,
    keyOf: (d) => d.id,
    fetch: (page, size) => _repo.getPaginated(PaginationParams(pageNumber: page, pageSize: size)),
  );

  bool get hasMore => _paged.hasMore;
  bool get isLoadingMore => _paged.isLoadingMore;
  bool get loadMoreFailed => _paged.loadMoreFailed;
  bool get canLoadMore => !_isLoading && _paged.canLoadMore;

  DriverVehicleFilter _vehicleFilter = DriverVehicleFilter.all;
  DriverVehicleFilter get vehicleFilter => _vehicleFilter;

  // ---- Load ----
  /// Ratings come from a shared session cache; when this screen is the first
  /// to need it, repaint once the fetch lands so cards swap "New" for stars.
  void _warmRatings() {
    if (_ratings.isLoaded) return;
    _ratings.ensureLoaded().then((_) {
      if (!_disposed) notifyListeners();
    });
  }

  bool _disposed = false;
  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// Re-fetches from page 1.
  Future<void> load() {
    _warmRatings();
    _paged.invalidate();
    return _sync();
  }

  Future<void> refresh() => load();

  int _syncToken = 0;

  /// Newest call wins: older ones stop at their next await and leave the final
  /// notify to it.
  Future<void> _sync() async {
    final token = ++_syncToken;
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _paged.ensureFirstPage();
    } on AppException catch (e) {
      if (token == _syncToken) _error = e.message;
    } catch (_) {
      if (token == _syncToken) _error = 'Something went wrong';
    } finally {
      if (token == _syncToken && !_disposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadMore() async {
    if (!canLoadMore) return;
    await _track(_paged.loadMore());
  }

  /// After a failed page — bypasses the failure hold-off.
  Future<void> retryLoadMore() => _track(_paged.loadMore());

  Future<void> _track(Future<void> pending) async {
    notifyListeners();
    await pending;
    if (!_disposed) notifyListeners();
  }

  // ---- Derived view-model list ----
  List<DriverItem> get filteredDrivers {
    return _paged.items
        // Only freelance drivers are listed; company-affiliated drivers
        // (allCompanyId != null) belong to a rental company and aren't bookable
        // directly by customers here.
        .where((d) => d.allCompanyId == null)
        .where((d) => _vehicleFilter == DriverVehicleFilter.all || d.hasVehicle)
        .map((d) => DriverItem.fromDriver(d, ar: _ar, rating: _ratings.driverAverage(d.driverId)))
        .toList();
  }

  // ---- Filter selection ----
  void selectVehicleFilter(DriverVehicleFilter filter) {
    if (_vehicleFilter == filter) return;
    _vehicleFilter = filter;
    notifyListeners();
  }
}
