import 'package:flutter/material.dart';

import '../data/driver_home_mock_data.dart';
import '../models/trip_request.dart';

class DriverHomeProvider extends ChangeNotifier {
  DriverHomeProvider()
    : _requests = List<TripRequest>.from(kMockTripRequests);

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  final double todayEarnings = kMockTodayEarnings;
  final int totalTrips = kMockTotalTrips;
  final double rating = kMockRating;

  final List<TripRequest> _requests;
  List<TripRequest> get requests => List.unmodifiable(_requests);

  void toggleOnline() {
    _isOnline = !_isOnline;
    notifyListeners();
  }

  void removeRequest(TripRequest trip) {
    _requests.remove(trip);
    notifyListeners();
  }
}
