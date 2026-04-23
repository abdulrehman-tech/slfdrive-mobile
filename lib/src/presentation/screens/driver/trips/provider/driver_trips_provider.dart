import 'package:flutter/foundation.dart';

import '../data/driver_trips_mock_data.dart';
import '../models/driver_trip.dart';

class DriverTripsProvider extends ChangeNotifier {
  DriverTripsProvider({List<DriverTrip>? trips})
    : _trips = List.of(trips ?? buildMockDriverTrips());

  final List<DriverTrip> _trips;
  int _tabIndex = 0; // 0=active, 1=completed, 2=cancelled

  static const tabKeys = [
    'trips_active',
    'trips_completed',
    'trips_cancelled',
  ];

  static const statusMap = [
    DriverTripStatus.active,
    DriverTripStatus.completed,
    DriverTripStatus.cancelled,
  ];

  static const emptyTitles = [
    'trips_no_active',
    'trips_no_completed',
    'trips_no_cancelled',
  ];

  static const emptySubs = [
    'trips_no_active_desc',
    'trips_no_completed_desc',
    'trips_no_cancelled_desc',
  ];

  int get tabIndex => _tabIndex;
  List<DriverTrip> get trips => List.unmodifiable(_trips);

  List<DriverTrip> get filteredTrips =>
      _trips.where((t) => t.status == statusMap[_tabIndex]).toList();

  int countForTab(int index) =>
      _trips.where((t) => t.status == statusMap[index]).length;

  void setTab(int index) {
    if (_tabIndex == index) return;
    _tabIndex = index;
    notifyListeners();
  }
}
