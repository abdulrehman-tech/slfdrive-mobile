import 'package:flutter/foundation.dart';

import '../../../../../core/data/repositories/vehicle_repository.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/models/vehicle/vehicle.dart';

/// Loads a single vehicle by [vehicleId] and owns the image-carousel index
/// and favourite toggle for the car detail screen.
class CarDetailProvider extends ChangeNotifier {
  final VehicleRepository _vehicleRepo;
  final int _vehicleId;
  final bool _ar;

  CarDetailProvider({
    required VehicleRepository vehicleRepository,
    required int vehicleId,
    bool ar = false,
  })  : _vehicleRepo = vehicleRepository,
        _vehicleId = vehicleId,
        _ar = ar {
    load();
  }

  // ---- State ----
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Vehicle? _vehicle;
  Vehicle? get vehicle => _vehicle;

  bool get ar => _ar;

  List<String> get images => _vehicle?.photoUrls ?? const [];

  int _currentImageIndex = 0;
  int get currentImageIndex => _currentImageIndex;

  bool _isFavourite = false;
  bool get isFavourite => _isFavourite;

  // ---- Loading ----
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _vehicle = await _vehicleRepo.getById(_vehicleId);
      if (_vehicle == null) {
        _error = 'Vehicle not found';
      }
    } on AppException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Something went wrong';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---- Image carousel ----
  void setImageIndex(int i) {
    if (_currentImageIndex == i) return;
    _currentImageIndex = i;
    notifyListeners();
  }

  // ---- Favourite ----
  void toggleFavourite() {
    _isFavourite = !_isFavourite;
    notifyListeners();
  }
}
