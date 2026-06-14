import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../../constants/storage_keys.dart';
import '../../../../../core/di/injection_container.dart';
import '../models/fav_car.dart';
import '../models/fav_driver.dart';

/// Global, locally-persisted favourites store (the backend has no favourites
/// endpoint). Holds denormalized snapshots of favourited cars/drivers so the
/// favourites screen renders without re-fetching, and survives app restarts.
///
/// Also owns the favourites-screen filter index (0 = All, 1 = Cars, 2 = Drivers).
class FavoritesProvider extends ChangeNotifier {
  FavoritesProvider({FlutterSecureStorage? storage})
      : _storage = storage ?? getIt<FlutterSecureStorage>() {
    _load();
  }

  final FlutterSecureStorage _storage;

  final List<FavCar> _cars = [];
  final List<FavDriver> _drivers = [];
  int _filterIndex = 0;

  int get filterIndex => _filterIndex;
  List<FavCar> get cars => List.unmodifiable(_cars);
  List<FavDriver> get drivers => List.unmodifiable(_drivers);

  bool get showCars => _filterIndex == 0 || _filterIndex == 1;
  bool get showDrivers => _filterIndex == 0 || _filterIndex == 2;

  bool get isEmpty =>
      (showCars ? _cars.isEmpty : true) && (showDrivers ? _drivers.isEmpty : true);

  bool isCarFav(String id) => _cars.any((c) => c.id == id);
  bool isDriverFav(String id) => _drivers.any((d) => d.id == id);

  Future<void> _load() async {
    try {
      final carsRaw = await _storage.read(key: StorageKeys.favoriteCars);
      final driversRaw = await _storage.read(key: StorageKeys.favoriteDrivers);
      if (carsRaw != null && carsRaw.isNotEmpty) {
        final list = jsonDecode(carsRaw) as List;
        _cars
          ..clear()
          ..addAll(list.whereType<Map<String, dynamic>>().map(FavCar.fromJson));
      }
      if (driversRaw != null && driversRaw.isNotEmpty) {
        final list = jsonDecode(driversRaw) as List;
        _drivers
          ..clear()
          ..addAll(list.whereType<Map<String, dynamic>>().map(FavDriver.fromJson));
      }
      notifyListeners();
    } catch (_) {
      // Corrupt cache — ignore and start empty.
    }
  }

  Future<void> _persistCars() => _storage.write(
        key: StorageKeys.favoriteCars,
        value: jsonEncode(_cars.map((c) => c.toJson()).toList()),
      );

  Future<void> _persistDrivers() => _storage.write(
        key: StorageKeys.favoriteDrivers,
        value: jsonEncode(_drivers.map((d) => d.toJson()).toList()),
      );

  void setFilter(int index) {
    if (_filterIndex == index) return;
    _filterIndex = index;
    notifyListeners();
  }

  /// Toggles a car favourite. Returns the new favourited state.
  bool toggleCar(FavCar car) {
    final i = _cars.indexWhere((c) => c.id == car.id);
    final nowFav = i < 0;
    if (nowFav) {
      _cars.insert(0, car);
    } else {
      _cars.removeAt(i);
    }
    _persistCars();
    notifyListeners();
    return nowFav;
  }

  bool toggleDriver(FavDriver driver) {
    final i = _drivers.indexWhere((d) => d.id == driver.id);
    final nowFav = i < 0;
    if (nowFav) {
      _drivers.insert(0, driver);
    } else {
      _drivers.removeAt(i);
    }
    _persistDrivers();
    notifyListeners();
    return nowFav;
  }

  void removeCarAt(int index) {
    if (index < 0 || index >= _cars.length) return;
    _cars.removeAt(index);
    _persistCars();
    notifyListeners();
  }

  void removeDriverAt(int index) {
    if (index < 0 || index >= _drivers.length) return;
    _drivers.removeAt(index);
    _persistDrivers();
    notifyListeners();
  }
}
