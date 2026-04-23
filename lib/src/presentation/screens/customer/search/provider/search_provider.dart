import 'package:flutter/material.dart';

import '../data/search_mock_data.dart';
import '../models/search_result_car.dart';
import '../models/search_result_driver.dart';

/// Owns search query + filter state and exposes filtered result lists.
class SearchProvider extends ChangeNotifier {
  static const defaultPriceRange = RangeValues(0, 500);

  // ── Query ────────────────────────────────────────
  final TextEditingController searchController = TextEditingController();
  final FocusNode focusNode = FocusNode();
  String _query = '';
  String get query => _query;

  void setQuery(String v) {
    _query = v;
    notifyListeners();
  }

  void clearQuery() {
    searchController.clear();
    _query = '';
    notifyListeners();
  }

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

  // ── Filtered results ─────────────────────────────
  List<SearchResultCar> get filteredCars {
    if (_typeFilter == 2) return const [];
    final q = _query.toLowerCase();
    return kSearchAllCars.where((c) {
      if (q.isNotEmpty && !c.name.toLowerCase().contains(q) && !c.brand.toLowerCase().contains(q)) {
        return false;
      }
      if (_selectedBrands.isNotEmpty && !_selectedBrands.contains(c.brand)) return false;
      if (c.pricePerDay < _priceRange.start || c.pricePerDay > _priceRange.end) return false;
      if (c.rating < _minRating) return false;
      return true;
    }).toList();
  }

  List<SearchResultDriver> get filteredDrivers {
    if (_typeFilter == 1) return const [];
    final q = _query.toLowerCase();
    return kSearchAllDrivers.where((d) {
      if (q.isNotEmpty && !d.name.toLowerCase().contains(q) && !d.speciality.toLowerCase().contains(q)) {
        return false;
      }
      if (d.pricePerDay < _priceRange.start || d.pricePerDay > _priceRange.end) return false;
      if (d.rating < _minRating) return false;
      return true;
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
