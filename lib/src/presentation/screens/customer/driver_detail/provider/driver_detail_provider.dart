import 'package:flutter/material.dart';

import '../../../../../core/data/repositories/driver_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/app_exception.dart';
import '../models/driver_profile.dart';

/// Loads a single driver from `GET /api/Driver/{id}` and exposes it as the
/// screen's `DriverProfile` view model.
class DriverDetailProvider extends ChangeNotifier {
  DriverDetailProvider({required this.driverId, DriverRepository? repository})
      : _repository = repository ?? getIt<DriverRepository>() {
    scroll.addListener(_onScroll);
    load();
  }

  final int driverId;
  final DriverRepository _repository;

  DriverProfile? _profile;
  DriverProfile? get profile => _profile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  bool _isFavourite = false;
  bool get isFavourite => _isFavourite;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final details = await _repository.getById(driverId);
      if (details == null) {
        _error = 'Driver not found';
      } else {
        _profile = DriverProfile.fromDetails(details);
      }
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleFavourite() {
    _isFavourite = !_isFavourite;
    notifyListeners();
  }

  final ScrollController scroll = ScrollController();
  double _scrollOffset = 0;
  double get scrollOffset => _scrollOffset;

  void _onScroll() {
    final next = scroll.offset.clamp(0, 240).toDouble();
    if ((next - _scrollOffset).abs() > 0.5) {
      _scrollOffset = next;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }
}
