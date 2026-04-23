import 'dart:async';

import 'package:flutter/material.dart';

import '../data/home_mock_data.dart';
import '../models/ad_item.dart';
import '../models/car_brand.dart';
import '../models/car_item.dart';
import '../models/driver_item.dart';

/// Owns all home-screen state: loading flag, ads carousel controller/timer,
/// brand selection, and mutable car list (favourites).
///
/// Animation controllers that need a [TickerProvider] (the hero banner fade)
/// stay in the screen `State` — provider pairs can't vend tickers cleanly.
class HomeProvider extends ChangeNotifier {
  HomeProvider() {
    _cars = buildFeaturedCars();
    _startLoadingTimer();
    _startAdsTimer();
  }

  // ── Loading ────────────────────────────────────────────────────
  bool _isLoading = true;
  bool get isLoading => _isLoading;
  Timer? _loadingTimer;

  void _startLoadingTimer() {
    _loadingTimer = Timer(const Duration(milliseconds: 1500), () {
      _isLoading = false;
      notifyListeners();
    });
  }

  // ── Brands ─────────────────────────────────────────────────────
  final List<CarBrand> brands = kHomeBrands;
  int _selectedBrandIndex = -1;
  int get selectedBrandIndex => _selectedBrandIndex;

  void toggleBrand(int index) {
    _selectedBrandIndex = _selectedBrandIndex == index ? -1 : index;
    notifyListeners();
  }

  // ── Cars ───────────────────────────────────────────────────────
  late final List<CarItem> _cars;
  List<CarItem> get cars => _cars;

  void toggleFavourite(String carId) {
    final idx = _cars.indexWhere((c) => c.id == carId);
    if (idx < 0) return;
    _cars[idx].isFavourite = !_cars[idx].isFavourite;
    notifyListeners();
  }

  // ── Drivers ────────────────────────────────────────────────────
  final List<DriverItem> nearbyDrivers = kNearbyDrivers;

  // ── Ads carousel ───────────────────────────────────────────────
  final List<AdItem> ads = kHomeAds;
  final PageController adsController = PageController(viewportFraction: 0.92);
  int _adsPage = 0;
  int get adsPage => _adsPage;
  Timer? _adsTimer;

  void _startAdsTimer() {
    _adsTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!adsController.hasClients) return;
      final next = (_adsPage + 1) % ads.length;
      adsController.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOutCubic,
      );
    });
  }

  void onAdsPageChanged(int i) {
    _adsPage = i;
    notifyListeners();
  }

  @override
  void dispose() {
    _loadingTimer?.cancel();
    _adsTimer?.cancel();
    adsController.dispose();
    super.dispose();
  }
}
