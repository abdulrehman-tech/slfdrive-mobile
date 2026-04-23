import 'package:flutter/material.dart';

import '../data/car_detail_mock_data.dart';

/// Owns image carousel index + favourite toggle for the car detail screen.
class CarDetailProvider extends ChangeNotifier {
  final List<String> images = kCarDetailImages;

  int _currentImageIndex = 0;
  int get currentImageIndex => _currentImageIndex;

  bool _isFavourite = false;
  bool get isFavourite => _isFavourite;

  void setImageIndex(int i) {
    if (_currentImageIndex == i) return;
    _currentImageIndex = i;
    notifyListeners();
  }

  void toggleFavourite() {
    _isFavourite = !_isFavourite;
    notifyListeners();
  }
}
