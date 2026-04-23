import 'package:flutter/foundation.dart';

import '../data/car_listing_mock_data.dart';
import '../models/car_item.dart';

/// Owns brand filter + sort selection for the car listing screen and
/// derives the filtered/sorted list of cars.
class CarListingProvider extends ChangeNotifier {
  CarListingProvider({String? initialBrand}) : _selectedBrand = initialBrand ?? 'All';

  final List<String> brands = kCarBrands;

  String _selectedBrand;
  String get selectedBrand => _selectedBrand;

  String _sortBy = 'popular';
  String get sortBy => _sortBy;

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

  List<CarItem> get filteredCars {
    var cars = _selectedBrand == 'All' ? List<CarItem>.from(kMockCars) : kMockCars.where((c) => c.brand == _selectedBrand).toList();
    switch (_sortBy) {
      case 'price_low':
        cars.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
        break;
      case 'price_high':
        cars.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
        break;
      case 'rating':
        cars.sort((a, b) => b.rating.compareTo(a.rating));
        break;
    }
    return cars;
  }
}
