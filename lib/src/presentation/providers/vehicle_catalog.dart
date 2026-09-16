import 'dart:async';

import 'package:flutter/foundation.dart';

import '../../core/data/repositories/vehicle_repository.dart';
import '../../core/di/injection_container.dart';
import '../../core/errors/app_exception.dart';
import '../../core/models/common/pagination_params.dart';
import '../../core/models/vehicle/vehicle.dart';
import '../../core/models/vehicle/vehicle_query.dart';
import '../../core/services/review_aggregates.dart';
import '../../core/services/vehicle_filter_options.dart';
import '../../core/utils/chained_paged_list.dart';
import '../../core/utils/paged_list.dart';
import '../../core/utils/safe_notifier.dart';

/// A customer-facing vehicle list: a [VehicleQuery] the API applies, loaded
/// 20 at a time. Shared by "Browse cars" and the search screen's Cars tab.
/// Every car is listed, available ones first: the API can't sort, so the list
/// is chained from status-filtered queries (available → other statuses →
/// switched off), each fetched only once the user scrolls past the previous.
class VehicleCatalog extends ChangeNotifier with SafeNotifier {
  VehicleCatalog({
    VehicleRepository? repository,
    VehicleFilterOptions? options,
    ReviewAggregates? ratings,
    this.ar = false,
  })  : _repo = repository ?? getIt<VehicleRepository>(),
        options = options ?? getIt<VehicleFilterOptions>(),
        _ratings = ratings ?? getIt<ReviewAggregates>();

  static const _pageSize = 20;
  static const _debounce = Duration(milliseconds: 350);

  final VehicleRepository _repo;
  final VehicleFilterOptions options;
  final ReviewAggregates _ratings;
  final bool ar;

  VehicleQuery _query = VehicleQuery.empty;
  VehicleQuery get query => _query;

  /// The query the loaded pages belong to; paging keeps using it while the
  /// user is still typing.
  VehicleQuery _loadedQuery = VehicleQuery.empty;

  late final ChainedPagedList<Vehicle> _paged = ChainedPagedList<Vehicle>(
    pageSize: _pageSize,
    keyOf: (v) => v.id,
    segments: _segments,
  );

  List<PageSegment<Vehicle>> _segments() {
    final q = _loadedQuery;
    PageFetcher<Vehicle> fetch(Map<String, Object> status) => (page, size) => _repo.getPaginated(
          PaginationParams(pageNumber: page, pageSize: size, searchFilter: q.toSearchFilter(extra: status)),
        );
    // Skip a query once earlier ones already account for every match.
    bool nothingLeft(int soFar) => _total != null && soFar >= _total!;
    final others = options.otherVehicleStatusIds;
    return [
      PageSegment(fetch: fetch({'isActive': true, 'statusId': VehicleFilterOptions.availableStatusId})),
      if (others != null)
        for (final id in others) PageSegment(fetch: fetch({'isActive': true, 'statusId': id}), skipIf: nothingLeft),
      PageSegment(fetch: fetch({'isActive': false}), skipIf: nothingLeft),
      // Status list unknown (guest): enabled cars in any other status,
      // picked out here. Only runs when the count says such cars exist.
      if (others == null)
        PageSegment(fetch: fetch({'isActive': true}), keep: (v) => !v.isAvailable, skipIf: nothingLeft),
    ];
  }

  /// Total matches across all statuses, from a 1-row count request.
  int? _total;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _started = false;
  bool get started => _started;

  List<Vehicle> get vehicles => _paged.items;

  /// Null until the count request answers (or when it failed).
  int? get totalCount => _total;
  bool get hasMore => _paged.hasMore;
  bool get isLoadingMore => _paged.isLoadingMore;
  bool get loadMoreFailed => _paged.loadMoreFailed;
  bool get canLoadMore => !_isLoading && _paged.canLoadMore;

  double? ratingFor(Vehicle v) => _ratings.vehicleAverage(v.id);

  Timer? _timer;
  int _token = 0;

  /// First load. [brandName] comes from brand tiles, which pass names; it's
  /// resolved to an id once the brand list is in, or searched as text when
  /// the list is unavailable (guests).
  Future<void> start({VehicleQuery initial = VehicleQuery.empty, String? brandName}) async {
    _started = true;
    _query = initial;
    if (!_ratings.isLoaded) _ratings.ensureLoaded().then((_) => safeNotify());
    // Brands resolve names; statuses shape the available-first ordering.
    // Both are cached for the session, so only the first screen waits.
    _isLoading = true;
    notifyListeners();
    await options.ensureLoaded();
    final name = brandName?.trim() ?? '';
    if (name.isNotEmpty && name.toLowerCase() != 'all') {
      final brand = options.brandNamed(name, ar: ar);
      _query = brand != null ? _query.withBrand(brand.id) : _query.withText(name);
    }
    await reload();
  }

  /// Free-text search, applied after a short pause in typing.
  void setText(String text) {
    if (text == _query.text) return;
    _query = _query.withText(text);
    notifyListeners();
    _timer?.cancel();
    _timer = Timer(_debounce, reload);
  }

  void setQuery(VehicleQuery next) {
    if (next == _query && next == _loadedQuery && _started) return;
    _started = true;
    _query = next;
    _timer?.cancel();
    reload();
  }

  Future<void> reload() async {
    _timer?.cancel();
    final token = ++_token;
    _loadedQuery = _query;
    _total = null;
    _paged.invalidate();
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await Future.wait([_paged.ensureFirstPage(), _count(token)]);
    } on AppException catch (e) {
      if (token == _token) _error = e.message;
    } catch (_) {
      if (token == _token) _error = 'error_occurred';
    } finally {
      if (token == _token) {
        _isLoading = false;
        safeNotify();
      }
    }
  }

  Future<void> _count(int token) async {
    try {
      final res = await _repo.getPaginated(PaginationParams(pageSize: 1, searchFilter: _loadedQuery.toSearchFilter()));
      if (token == _token) _total = res.totalCount;
    } catch (_) {
      // The count is a nicety; the list itself reports real failures.
    }
  }

  Future<void> loadMore() async {
    if (canLoadMore) await _track(_paged.loadMore());
  }

  /// After a failed page — bypasses the failure hold-off.
  Future<void> retryLoadMore() => _track(_paged.loadMore());

  Future<void> _track(Future<void> pending) async {
    notifyListeners();
    await pending;
    safeNotify();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
