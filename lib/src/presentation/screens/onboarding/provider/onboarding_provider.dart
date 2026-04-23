import 'package:flutter/material.dart';

import '../data/onboarding_mock_data.dart';
import '../models/onboarding_page.dart';

class OnboardingProvider extends ChangeNotifier {
  OnboardingProvider() {
    _pages = OnboardingMockData.getPages();
  }

  late final List<OnboardingPage> _pages;
  int _currentPage = 0;

  List<OnboardingPage> get pages => _pages;
  int get currentPage => _currentPage;
  OnboardingPage get current => _pages[_currentPage];
  int get pageCount => _pages.length;
  bool get isLastPage => _currentPage == _pages.length - 1;
  bool get isFirstPage => _currentPage == 0;

  bool goNext() {
    if (_currentPage < _pages.length - 1) {
      _currentPage++;
      notifyListeners();
      return true;
    }
    return false;
  }

  void goBack() {
    if (_currentPage > 0) {
      _currentPage--;
      notifyListeners();
    }
  }
}
