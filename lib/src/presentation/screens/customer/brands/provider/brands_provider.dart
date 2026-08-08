import 'package:flutter/foundation.dart';

import '../../../../../core/data/repositories/lookup_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../models/brand.dart';

/// Loads active vehicle brands from the backend (`VehicleBrand/active`) and
/// filters them by the search query.
class BrandsProvider extends ChangeNotifier {
  BrandsProvider({LookupRepository? repository, bool ar = false})
      : _repository = repository ?? getIt<LookupRepository>(),
        _ar = ar {
    load();
  }

  final bool _ar;

  final LookupRepository _repository;

  final List<Brand> _all = [];
  String _query = '';
  bool _isLoading = false;
  String? _error;

  String get query => _query;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Brand> get filteredBrands {
    if (_query.trim().isEmpty) return List.unmodifiable(_all);
    final q = _query.toLowerCase();
    return _all.where((b) => b.name.toLowerCase().contains(q)).toList();
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final brands = await _repository.getActiveBrands();
      _all
        ..clear()
        ..addAll(brands.map((b) => Brand(
              name: b.displayName(ar: _ar),
              logoAsset: '',
              carsCount: 0,
              tagline: '',
            )));
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setQuery(String value) {
    if (_query == value) return;
    _query = value;
    notifyListeners();
  }

  void clearQuery() {
    if (_query.isEmpty) return;
    _query = '';
    notifyListeners();
  }
}
