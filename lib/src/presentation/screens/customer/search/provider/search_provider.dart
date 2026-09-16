import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../../core/data/repositories/driver_listing_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/models/common/pagination_params.dart';
import '../../../../../core/models/driver/driver_listing_item.dart';
import '../../../../../core/models/vehicle/vehicle_query.dart';
import '../../../../../core/services/recent_searches.dart';
import '../../../../../core/utils/paged_list.dart';
import '../../../../../core/utils/safe_notifier.dart';
import '../../../../providers/vehicle_catalog.dart';
import '../models/search_result_driver.dart';

/// Search screen state: the query text, a "discover" state until the user
/// types or picks a brand/type, then Cars and Drivers results — both filtered
/// by the API (`name` / `fullName`) and loaded 20 at a time.
class SearchProvider extends ChangeNotifier with SafeNotifier {
  SearchProvider({
    VehicleCatalog? cars,
    DriverListingRepository? driverRepository,
    RecentSearches? recentSearches,
    this.ar = false,
  })  : cars = cars ?? VehicleCatalog(ar: ar),
        _driverRepo = driverRepository ?? getIt<DriverListingRepository>(),
        _recentStore = recentSearches ?? RecentSearches() {
    this.cars.addListener(safeNotify);
    this.cars.options.ensureLoaded().then((_) => safeNotify());
    _recentStore.load().then((terms) {
      _recent = terms;
      safeNotify();
    });
  }

  final bool ar;
  final VehicleCatalog cars;
  final DriverListingRepository _driverRepo;
  final RecentSearches _recentStore;

  static const _debounce = Duration(milliseconds: 350);

  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  // ── Query ────────────────────────────────────────
  String _text = '';
  String get text => _text;
  Timer? _timer;

  /// Results were opened without text (a brand/type chip or "See all cars").
  bool _browsing = false;

  bool get showDiscover => _text.trim().isEmpty && !_browsing && !cars.query.hasFilters;

  void setText(String value) {
    _text = value;
    notifyListeners();
    _timer?.cancel();
    _timer = Timer(_debounce, _search);
  }

  /// Keyboard search: run now and remember the term.
  void submit(String value) {
    _text = value;
    _timer?.cancel();
    rememberQuery();
    _search();
  }

  void clearText() {
    searchController.clear();
    // Nothing left to show results for → back to discover.
    if (!cars.query.hasFilters) _browsing = false;
    setText('');
  }

  void useRecent(String term) {
    searchController.text = term;
    focusNode.unfocus();
    submit(term);
  }

  void browseBrand(int brandId) => _browse(cars.query.withBrand(brandId));
  void browseVehicleType(int typeId) => _browse(cars.query.withVehicleType(typeId));
  void browseAll() => _browse(VehicleQuery(text: _text.trim()));

  void _browse(VehicleQuery query) {
    _browsing = true;
    focusNode.unfocus();
    cars.setQuery(query.withText(_text.trim()));
    _reloadDrivers();
    notifyListeners();
  }

  void _search() {
    if (showDiscover) {
      notifyListeners();
      return;
    }
    cars.setQuery(cars.query.withText(_text.trim()));
    _reloadDrivers();
  }

  // ── Recent searches ──────────────────────────────
  List<String> _recent = const [];
  List<String> get recent => _recent;

  /// Saves the current text — on keyboard search or when a result is opened.
  Future<void> rememberQuery() async {
    if (_text.trim().length < 2) return;
    _recent = await _recentStore.add(_text);
    safeNotify();
  }

  Future<void> removeRecent(String term) async {
    _recent = await _recentStore.remove(term);
    safeNotify();
  }

  Future<void> clearRecent() async {
    await _recentStore.clear();
    _recent = const [];
    safeNotify();
  }

  // ── Drivers ──────────────────────────────────────
  String? _driverText;

  late final PagedList<DriverListingItem> _driverPages = PagedList<DriverListingItem>(
    pageSize: 20,
    keyOf: (d) => d.id,
    fetch: (page, size) => _driverRepo.getPaginated(PaginationParams(
      pageNumber: page,
      pageSize: size,
      searchFilter: (_driverText ?? '').isEmpty ? null : jsonEncode({'fullName': _driverText}),
    )),
  );

  bool _driversLoading = false;
  bool get driversLoading => _driversLoading;

  String? _driversError;
  String? get driversError => _driversError;

  int _driversToken = 0;

  Future<void> _reloadDrivers({bool force = false}) async {
    final next = _text.trim();
    // Brand/type filters don't apply to drivers — only a new text does.
    if (!force && next == _driverText) return;
    final token = ++_driversToken;
    _driverText = next;
    _driverPages.invalidate();
    _driversLoading = true;
    _driversError = null;
    notifyListeners();
    try {
      await _driverPages.ensureFirstPage();
    } on AppException catch (e) {
      if (token == _driversToken) _driversError = e.message;
    } catch (_) {
      if (token == _driversToken) _driversError = 'error_occurred';
    } finally {
      if (token == _driversToken) {
        _driversLoading = false;
        safeNotify();
      }
    }
  }

  Future<void> retryDrivers() => _reloadDrivers(force: true);

  /// Customers can only hire freelance drivers; company drivers are left out
  /// here (the API can't filter on a missing company).
  List<SearchResultDriver> get drivers =>
      _driverPages.items.where((d) => d.allCompanyId == null).map(_mapDriver).toList();

  /// Exact count once every page is in; unknown before (freelance filter).
  int? get driverCount => _driverPages.hasMore || _driversLoading ? null : drivers.length;

  /// Nothing to show yet but pages left to scan.
  bool get driversStillPaging => drivers.isEmpty && _driverPages.hasMore && !_driverPages.loadMoreFailed;

  bool get canLoadMoreDrivers => !_driversLoading && _driverPages.canLoadMore;
  bool get driversLoadingMore => _driverPages.isLoadingMore;
  bool get driversLoadMoreFailed => _driverPages.loadMoreFailed;

  Future<void> loadMoreDrivers() async {
    if (canLoadMoreDrivers) await _trackDrivers(_driverPages.loadMore());
  }

  Future<void> retryMoreDrivers() => _trackDrivers(_driverPages.loadMore());

  Future<void> _trackDrivers(Future<void> pending) async {
    notifyListeners();
    await pending;
    safeNotify();
  }

  SearchResultDriver _mapDriver(DriverListingItem d) => SearchResultDriver(
        id: d.id.toString(),
        name: d.displayName(ar: ar),
        avatarUrl: d.resolvedPhotoUrl ?? '',
        rating: d.rating ?? 0,
        trips: 0,
        speciality: (ar ? (d.locationNameAr ?? d.locationName) : d.locationName) ?? '',
        pricePerDay: d.amountPerDay ?? 0,
        isOnline: d.isOnline,
      );

  @override
  void dispose() {
    _timer?.cancel();
    cars.removeListener(safeNotify);
    cars.dispose();
    searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
