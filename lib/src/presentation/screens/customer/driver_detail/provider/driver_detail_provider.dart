import 'package:flutter/material.dart';

import '../data/driver_detail_mock_data.dart';
import '../models/driver_profile.dart';

class DriverDetailProvider extends ChangeNotifier {
  DriverDetailProvider({DriverProfile? profile}) : profile = profile ?? kMockDriverProfile {
    scroll.addListener(_onScroll);
  }

  final DriverProfile profile;

  bool _isFavourite = false;
  bool get isFavourite => _isFavourite;

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
