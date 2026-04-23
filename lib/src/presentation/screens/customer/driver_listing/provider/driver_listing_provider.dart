import 'package:flutter/foundation.dart';

import '../data/driver_listing_mock_data.dart';
import '../models/driver_item.dart';

class DriverListingProvider extends ChangeNotifier {
  DriverListingProvider({String? initialFilter}) : _selectedSpeciality = initialFilter ?? 'All';

  String _selectedSpeciality;
  String get selectedSpeciality => _selectedSpeciality;

  String _sortBy = 'popular';
  String get sortBy => _sortBy;

  List<String> get specialities => kDriverSpecialities;

  List<DriverItem> get filteredDrivers {
    var drivers = _selectedSpeciality == 'All'
        ? List<DriverItem>.from(kMockDrivers)
        : kMockDrivers.where((d) => d.speciality == _selectedSpeciality).toList();
    switch (_sortBy) {
      case 'price_low':
        drivers.sort((a, b) => a.pricePerDay.compareTo(b.pricePerDay));
        break;
      case 'price_high':
        drivers.sort((a, b) => b.pricePerDay.compareTo(a.pricePerDay));
        break;
      case 'rating':
        drivers.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'experience':
        drivers.sort((a, b) => b.yearsExperience.compareTo(a.yearsExperience));
        break;
    }
    return drivers;
  }

  void selectSpeciality(String speciality) {
    if (_selectedSpeciality == speciality) return;
    _selectedSpeciality = speciality;
    notifyListeners();
  }

  void setSortBy(String value) {
    if (_sortBy == value) return;
    _sortBy = value;
    notifyListeners();
  }
}
