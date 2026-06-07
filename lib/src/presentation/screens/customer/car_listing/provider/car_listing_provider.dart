import 'package:flutter/foundation.dart';

import '../../../../../core/data/repositories/lookup_repository.dart';
import '../../../../../core/data/repositories/vehicle_repository.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/models/common/pagination_params.dart';
import '../../../../../core/models/vehicle/vehicle.dart';
import '../models/car_item.dart';

/// Loads vehicle listings from the API and owns the brand filter + sort
/// selection for the car listing screen.
class CarListingProvider extends ChangeNotifier {
  final VehicleRepository _vehicleRepo;
  final LookupRepository _lookupRepo;
  final bool _ar;

  CarListingProvider({
    required VehicleRepository vehicleRepository,
    required LookupRepository lookupRepository,
    bool ar = false,
    String? initialBrand,
  })  : _vehicleRepo = vehicleRepository,
        _lookupRepo = lookupRepository,
        _ar = ar,
        _selectedBrand = initialBrand ?? 'All' {
    load();
  }

  static const int _pageSize = 50;

  // ---- State ----
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoadingMore = false;
  bool get isLoadingMore => _isLoadingMore;

  String? _error;
  String? get error => _error;

  List<String> _brands = const ['All'];
  List<String> get brands => _brands;

  String _selectedBrand;
  String get selectedBrand => _selectedBrand;

  String _sortBy = 'popular';
  String get sortBy => _sortBy;

  final List<Vehicle> _vehicles = [];
  int _pageNumber = 1;
  int _totalPages = 1;
  bool get hasMore => _pageNumber < _totalPages;

  // ---- Loading ----
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // Brands are non-fatal — a failure here still shows the vehicle list.
      _loadBrands();
      final page = await _vehicleRepo.getPaginated(
        PaginationParams(pageNumber: 1, pageSize: _pageSize, sortBy: _apiSortBy, sortOrder: _apiSortOrder),
      );
      _vehicles
        ..clear()
        ..addAll(page.items);
      _pageNumber = page.pageNumber;
      _totalPages = page.totalPages;
    } on AppException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Something went wrong';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() => load();

  Future<void> loadMore() async {
    if (_isLoadingMore || !hasMore) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      final page = await _vehicleRepo.getPaginated(
        PaginationParams(
          pageNumber: _pageNumber + 1,
          pageSize: _pageSize,
          sortBy: _apiSortBy,
          sortOrder: _apiSortOrder,
        ),
      );
      _vehicles.addAll(page.items);
      _pageNumber = page.pageNumber;
      _totalPages = page.totalPages;
    } on AppException catch (_) {
      // Keep what we have; surfacing a snackbar is the screen's call.
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> _loadBrands() async {
    try {
      final brands = await _lookupRepo.getActiveBrands();
      _brands = ['All', ...brands.map((b) => b.displayName(ar: _ar))];
    } catch (_) {
      // Non-fatal: keep the default ['All'].
    }
  }

  // ---- Filter / sort selection ----
  void selectBrand(String brand) {
    if (_selectedBrand == brand) return;
    _selectedBrand = brand;
    notifyListeners();
  }

  void setSort(String value) {
    if (_sortBy == value) return;
    _sortBy = value;
    notifyListeners();
  }

  String? get _apiSortBy => (_sortBy == 'price_low' || _sortBy == 'price_high') ? 'pricePerDay' : null;
  String? get _apiSortOrder => _sortBy == 'price_low'
      ? 'asc'
      : _sortBy == 'price_high'
          ? 'desc'
          : null;

  /// Brand-filtered + sorted view models for the current page(s).
  List<CarItem> get filteredCars {
    var items = _vehicles
        .where((v) => _selectedBrand == 'All' || (_ar ? v.brandNameAr : v.brandName) == _selectedBrand || v.brandName == _selectedBrand)
        .map((v) => CarItem.fromVehicle(v, ar: _ar))
        .toList();
    switch (_sortBy) {
      case 'price_low':
        items.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
        break;
      case 'price_high':
        items.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
        break;
    }
    return items;
  }
}
