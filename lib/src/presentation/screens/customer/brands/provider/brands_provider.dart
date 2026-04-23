import 'package:flutter/foundation.dart';

import '../data/brands_mock_data.dart';
import '../models/brand.dart';

class BrandsProvider extends ChangeNotifier {
  String _query = '';

  String get query => _query;

  List<Brand> get filteredBrands {
    if (_query.trim().isEmpty) return kAllBrands;
    final q = _query.toLowerCase();
    return kAllBrands.where((b) => b.name.toLowerCase().contains(q)).toList();
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
