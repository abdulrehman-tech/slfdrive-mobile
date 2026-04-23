import 'package:flutter/material.dart';

import '../data/favorites_mock_data.dart';
import '../models/fav_car.dart';
import '../models/fav_driver.dart';

/// Owns filter tab state and the favorited car/driver lists.
///
/// Filter index: 0 = All, 1 = Cars, 2 = Drivers.
class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider() {
    _cars = List.of(kMockFavCars);
    _drivers = List.of(kMockFavDrivers);
  }

  int _filterIndex = 0;
  int get filterIndex => _filterIndex;

  late List<FavCar> _cars;
  List<FavCar> get cars => List.unmodifiable(_cars);

  late List<FavDriver> _drivers;
  List<FavDriver> get drivers => List.unmodifiable(_drivers);

  bool get showCars => _filterIndex == 0 || _filterIndex == 1;
  bool get showDrivers => _filterIndex == 0 || _filterIndex == 2;

  bool get isEmpty =>
      (showCars ? _cars.isEmpty : true) && (showDrivers ? _drivers.isEmpty : true);

  void setFilter(int index) {
    if (_filterIndex == index) return;
    _filterIndex = index;
    notifyListeners();
  }

  void removeCarAt(int index) {
    if (index < 0 || index >= _cars.length) return;
    _cars.removeAt(index);
    notifyListeners();
  }

  void removeDriverAt(int index) {
    if (index < 0 || index >= _drivers.length) return;
    _drivers.removeAt(index);
    notifyListeners();
  }
}
