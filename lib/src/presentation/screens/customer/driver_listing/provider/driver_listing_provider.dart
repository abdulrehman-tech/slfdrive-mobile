import 'package:flutter/foundation.dart';

import '../../../../../core/data/repositories/driver_listing_repository.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/models/common/pagination_params.dart';
import '../../../../../core/models/driver/driver_listing_item.dart';
import '../models/driver_item.dart';

/// Vehicle-filter values for the chip bar.
///
/// The backend has no speciality concept, so we repurpose the filter chips to
/// a simple "All / Has Vehicle" toggle that uses [DriverListingItem.hasVehicle].
enum DriverVehicleFilter { all, hasVehicle }

class DriverListingProvider extends ChangeNotifier {
  final DriverListingRepository _repo;
  final bool _ar;

  DriverListingProvider({
    required DriverListingRepository repository,
    bool ar = false,
  })  : _repo = repository,
        _ar = ar {
    load();
  }

  static const int _pageSize = 50;

  // ---- State ----
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  final List<DriverListingItem> _drivers = [];

  DriverVehicleFilter _vehicleFilter = DriverVehicleFilter.all;
  DriverVehicleFilter get vehicleFilter => _vehicleFilter;

  String _sortBy = 'popular';
  String get sortBy => _sortBy;

  // ---- Load ----
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final page = await _repo.getPaginated(
        PaginationParams(
          pageNumber: 1,
          pageSize: _pageSize,
          sortBy: _apiSortBy,
          sortOrder: _apiSortOrder,
        ),
      );
      _drivers
        ..clear()
        ..addAll(page.items);
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

  // ---- Sort → API field mapping ----
  String? get _apiSortBy {
    switch (_sortBy) {
      case 'price_low':
      case 'price_high':
        return 'amountPerDay';
      case 'experience':
        return 'yearsOfExperience';
      default:
        return null;
    }
  }

  String? get _apiSortOrder {
    switch (_sortBy) {
      case 'price_low':
        return 'asc';
      case 'price_high':
        return 'desc';
      case 'experience':
        return 'desc';
      default:
        return null;
    }
  }

  // ---- Derived view-model list ----
  List<DriverItem> get filteredDrivers {
    var items = _drivers
        .where((d) =>
            _vehicleFilter == DriverVehicleFilter.all || d.hasVehicle)
        .map((d) => DriverItem.fromDriver(d, ar: _ar))
        .toList();

    switch (_sortBy) {
      case 'price_low':
        items.sort((a, b) {
          if (a.pricePerDay == null && b.pricePerDay == null) return 0;
          if (a.pricePerDay == null) return 1;
          if (b.pricePerDay == null) return -1;
          return a.pricePerDay!.compareTo(b.pricePerDay!);
        });
        break;
      case 'price_high':
        items.sort((a, b) {
          if (a.pricePerDay == null && b.pricePerDay == null) return 0;
          if (a.pricePerDay == null) return 1;
          if (b.pricePerDay == null) return -1;
          return b.pricePerDay!.compareTo(a.pricePerDay!);
        });
        break;
      case 'experience':
        items.sort((a, b) {
          if (a.yearsExperience == null && b.yearsExperience == null) return 0;
          if (a.yearsExperience == null) return 1;
          if (b.yearsExperience == null) return -1;
          return b.yearsExperience!.compareTo(a.yearsExperience!);
        });
        break;
    }
    return items;
  }

  // ---- Filter / sort selection ----
  void selectVehicleFilter(DriverVehicleFilter filter) {
    if (_vehicleFilter == filter) return;
    _vehicleFilter = filter;
    notifyListeners();
  }

  void setSortBy(String value) {
    if (_sortBy == value) return;
    _sortBy = value;
    notifyListeners();
  }
}
