import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../../../../core/data/repositories/driver_listing_repository.dart';
import '../../../../../core/data/repositories/vehicle_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/models/common/pagination_params.dart';
import '../../../../../core/models/driver/driver_listing_item.dart';
import '../../../../../core/models/vehicle/vehicle.dart';
import '../models/search_result_car.dart';
import '../models/search_result_driver.dart';

/// Owns search query + filter state and the server-backed result lists.
///
/// Free-text search is delegated to the backend via `searchFilter` on the
/// `Vehicle/paginated` and `Driver/paginated` endpoints (debounced). Price,
/// brand and rating filters the backend can't express are applied client-side
/// over the fetched page.
class SearchProvider extends ChangeNotifier {
  SearchProvider({
    VehicleRepository? vehicleRepository,
    DriverListingRepository? driverRepository,
  })  : _vehicles = vehicleRepository ?? getIt<VehicleRepository>(),
        _drivers = driverRepository ?? getIt<DriverListingRepository>() {
    _fetch();
  }

  static const defaultPriceRange = RangeValues(0, 500);
  static const _pageSize = 30;

  final VehicleRepository _vehicles;
  final DriverListingRepository _drivers;

  // ── Query ────────────────────────────────────────
  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  String _query = '';
  String get query => _query;
  Timer? _debounce;

  void setQuery(String v) {
    _query = v;
    notifyListeners();
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), _fetch);
  }

  void clearQuery() {
    searchController.clear();
    _query = '';
    notifyListeners();
    _debounce?.cancel();
    _fetch();
  }

  // ── Fetched data ─────────────────────────────────
  List<SearchResultCar> _carResults = const [];
  List<SearchResultDriver> _driverResults = const [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Distinct, sorted brand names present in the current car results — drives
  /// the brand chips in the filter sheet.
  List<String> get availableBrands {
    final set = <String>{
      for (final c in _carResults)
        if (c.brand.trim().isNotEmpty) c.brand.trim(),
    };
    final list = set.toList()..sort();
    return list;
  }

  String? _error;
  String? get error => _error;

  Future<void> _fetch() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    final q = _query.trim();
    // Backend expects searchFilter as a JSON object keyed by the searchable
    // column: vehicles match on `name`, drivers on `fullName`.
    final vehicleParams = PaginationParams(
      pageNumber: 1,
      pageSize: _pageSize,
      searchFilter: q.isEmpty ? null : jsonEncode({'name': q}),
    );
    final driverParams = PaginationParams(
      pageNumber: 1,
      pageSize: _pageSize,
      searchFilter: q.isEmpty ? null : jsonEncode({'fullName': q}),
    );
    // Run both concurrently but isolate failures: a driver-side error must not
    // wipe car results (and vice-versa). Only surface an error if BOTH fail.
    Object? vehicleError;
    Object? driverError;

    final vehicleFuture = _vehicles.getPaginated(vehicleParams).then((page) {
      _carResults = page.items.map(_mapCar).toList();
    }).catchError((Object e) {
      vehicleError = e;
      _carResults = const [];
    });

    final driverFuture = _drivers.getPaginated(driverParams).then((page) {
      // Customers can only hire freelance drivers; company-affiliated drivers
      // (allCompanyId != null) are excluded from search results.
      _driverResults =
          page.items.where((d) => d.allCompanyId == null).map(_mapDriver).toList();
    }).catchError((Object e) {
      driverError = e;
      _driverResults = const [];
    });

    await Future.wait([vehicleFuture, driverFuture]);

    // Only show a blocking error when nothing at all could be loaded.
    if (vehicleError != null && driverError != null) {
      final e = vehicleError!;
      _error = e is AppException ? e.message : e.toString();
    } else {
      _error = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> retry() => _fetch();

  SearchResultCar _mapCar(Vehicle v) => SearchResultCar(
        id: v.id.toString(),
        name: v.displayTitle(),
        imageUrl: v.primaryPhoto ?? '',
        pricePerDay: v.pricePerDay ?? 0,
        brand: v.brandName ?? '',
        rating: v.rating ?? 0,
        transmission: v.transmissionTypeName ?? '',
        seats: v.seats ?? 0,
        fuelType: v.fuelTypeName ?? '',
      );

  SearchResultDriver _mapDriver(DriverListingItem d) => SearchResultDriver(
        id: d.id.toString(),
        name: d.displayName(),
        avatarUrl: d.resolvedPhotoUrl ?? '',
        rating: d.rating ?? 0,
        trips: 0,
        speciality: d.locationName ?? '',
        pricePerDay: d.amountPerDay ?? 0,
        isOnline: d.isOnline,
      );

  // ── Filters ──────────────────────────────────────
  int _typeFilter = 0; // 0=All, 1=Cars, 2=Drivers
  int _durationFilter = 0;
  RangeValues _priceRange = defaultPriceRange;
  final Set<String> _selectedBrands = {};
  double _minRating = 0;

  int get typeFilter => _typeFilter;
  int get durationFilter => _durationFilter;
  RangeValues get priceRange => _priceRange;
  Set<String> get selectedBrands => _selectedBrands;
  double get minRating => _minRating;

  bool get hasActiveFilters =>
      _typeFilter != 0 ||
      _durationFilter != 0 ||
      _priceRange != defaultPriceRange ||
      _selectedBrands.isNotEmpty ||
      _minRating > 0;

  int get activeFilterCount {
    var c = 0;
    if (_typeFilter != 0) c++;
    if (_durationFilter != 0) c++;
    if (_priceRange != defaultPriceRange) c++;
    if (_selectedBrands.isNotEmpty) c++;
    if (_minRating > 0) c++;
    return c;
  }

  void applyFilters({
    required int type,
    required int duration,
    required RangeValues price,
    required Set<String> brands,
    required double rating,
  }) {
    _typeFilter = type;
    _durationFilter = duration;
    _priceRange = price;
    _selectedBrands
      ..clear()
      ..addAll(brands);
    _minRating = rating;
    notifyListeners();
  }

  void resetFilters() {
    _typeFilter = 0;
    _durationFilter = 0;
    _priceRange = defaultPriceRange;
    _selectedBrands.clear();
    _minRating = 0;
    notifyListeners();
  }

  // ── Filtered results (client-side over fetched page) ──
  List<SearchResultCar> get filteredCars {
    if (_typeFilter == 2) return const [];
    return _carResults.where((c) {
      if (_selectedBrands.isNotEmpty && !_selectedBrands.contains(c.brand)) return false;
      if (c.pricePerDay < _priceRange.start || c.pricePerDay > _priceRange.end) return false;
      // Ratings aren't yet served per-vehicle; only filter when a rating exists.
      if (_minRating > 0 && c.rating > 0 && c.rating < _minRating) return false;
      return true;
    }).toList();
  }

  List<SearchResultDriver> get filteredDrivers {
    if (_typeFilter == 1) return const [];
    return _driverResults.where((d) {
      if (d.pricePerDay < _priceRange.start || d.pricePerDay > _priceRange.end) return false;
      if (_minRating > 0 && d.rating > 0 && d.rating < _minRating) return false;
      return true;
    }).toList();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
