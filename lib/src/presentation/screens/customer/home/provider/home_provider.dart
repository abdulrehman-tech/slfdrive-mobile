import 'package:flutter/material.dart';

import '../../../../../core/data/repositories/driver_listing_repository.dart';
import '../../../../../core/data/repositories/lookup_repository.dart';
import '../../../../../core/data/repositories/vehicle_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/models/common/pagination_params.dart';
import '../models/ad_item.dart';
import '../models/car_brand.dart';
import '../models/car_item.dart';
import '../models/driver_item.dart';

/// Owns all home-screen state: featured-cars / nearby-drivers live data,
/// brand selection, and the ads carousel controller/timer.
///
/// Cars and drivers load independently so a failure in one section does not
/// block the other. The brands list and ads remain static marketing data.
///
/// Animation controllers that need a [TickerProvider] (the hero banner fade)
/// stay in the screen [State] — provider pairs can't vend tickers cleanly.
class HomeProvider extends ChangeNotifier {
  HomeProvider({
    required VehicleRepository vehicleRepository,
    required DriverListingRepository driverRepository,
    bool ar = false,
  })  : _vehicleRepo = vehicleRepository,
        _driverRepo = driverRepository,
        _ar = ar {
    load();
  }

  final VehicleRepository _vehicleRepo;
  final DriverListingRepository _driverRepo;
  final bool _ar;

  // ── Cars ───────────────────────────────────────────────────────
  bool _carsLoading = true;
  bool get carsLoading => _carsLoading;

  String? _carsError;
  String? get carsError => _carsError;

  List<CarItem> _featuredCars = const [];
  List<CarItem> get featuredCars => _featuredCars;

  // Convenience alias used by widgets that already read `.cars`.
  List<CarItem> get cars => _featuredCars;

  // ── Drivers ────────────────────────────────────────────────────
  bool _driversLoading = true;
  bool get driversLoading => _driversLoading;

  String? _driversError;
  String? get driversError => _driversError;

  List<DriverItem> _nearbyDrivers = const [];
  List<DriverItem> get nearbyDrivers => _nearbyDrivers;

  // ── Brands (active vehicle brands from the API) ────────────────
  List<CarBrand> _brands = const [];
  List<CarBrand> get brands => _brands;
  int _selectedBrandIndex = -1;
  int get selectedBrandIndex => _selectedBrandIndex;

  void toggleBrand(int index) {
    _selectedBrandIndex = _selectedBrandIndex == index ? -1 : index;
    notifyListeners();
  }

  // ── Ads carousel ───────────────────────────────────────────────
  // No ads backend yet — empty until a real source exists; the carousel hides
  // itself when empty.
  final List<AdItem> ads = const [];
  final PageController adsController = PageController(viewportFraction: 0.92);
  int _adsPage = 0;
  int get adsPage => _adsPage;

  void onAdsPageChanged(int i) {
    _adsPage = i;
    notifyListeners();
  }

  // ── Data loading ───────────────────────────────────────────────

  /// Triggers a parallel load of featured cars and nearby drivers. Safe to
  /// call again as a refresh — both section states reset independently.
  Future<void> load() async {
    await Future.wait([_loadCars(), _loadDrivers(), _loadBrands()]);
  }

  Future<void> _loadBrands() async {
    try {
      final brands = await getIt<LookupRepository>().getActiveBrands();
      _brands = brands.map((b) => CarBrand(b.displayName(ar: _ar), '')).toList();
      notifyListeners();
    } catch (_) {
      // Brands are non-critical chrome; leave empty on failure.
    }
  }

  Future<void> _loadCars() async {
    _carsLoading = true;
    _carsError = null;
    notifyListeners();
    try {
      // lat/lon are null — LocationProvider only holds a display label, not
      // raw coordinates. The backend treats null as "return all nearest".
      final page = await _vehicleRepo.getNearest(
        params: const PaginationParams(pageSize: 10),
      );
      _featuredCars = page.items
          .map((v) => CarItem.fromVehicle(v, ar: _ar))
          .toList();
    } on AppException catch (e) {
      _carsError = e.message;
    } catch (_) {
      _carsError = 'Something went wrong';
    } finally {
      _carsLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadDrivers() async {
    _driversLoading = true;
    _driversError = null;
    notifyListeners();
    try {
      final page = await _driverRepo.getNearest(
        params: const PaginationParams(pageSize: 10),
      );
      _nearbyDrivers = page.items
          .map((d) => DriverItem.fromDriver(d, ar: _ar))
          .toList();
    } on AppException catch (e) {
      _driversError = e.message;
    } catch (_) {
      _driversError = 'Something went wrong';
    } finally {
      _driversLoading = false;
      notifyListeners();
    }
  }

  // ── Favourite toggle ───────────────────────────────────────────
  // The favourite state is local to the home screen's in-memory list. There is
  // no favourite-persist API integrated yet; the toggle mutates the view model
  // and notifies listeners so the heart icon animates immediately. Because the
  // list is rebuilt from the server on every load() call, toggled state is lost
  // on refresh — this matches the previous mock behaviour and will be replaced
  // once a favourites endpoint is wired up.

  void toggleFavourite(String carId) {
    final idx = _featuredCars.indexWhere((c) => c.id == carId);
    if (idx < 0) return;
    _featuredCars[idx].isFavourite = !_featuredCars[idx].isFavourite;
    notifyListeners();
  }

  // ── Convenience: combined loading flag used by the skeleton ────
  /// True while EITHER section is still in its first load (for skeleton /
  /// initial-load UX). Once both have resolved, use per-section states.
  bool get isLoading => _carsLoading && _driversLoading;

  @override
  void dispose() {
    adsController.dispose();
    super.dispose();
  }
}
