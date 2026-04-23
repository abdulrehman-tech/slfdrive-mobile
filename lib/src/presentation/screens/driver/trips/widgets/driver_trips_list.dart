import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/driver_trip.dart';
import 'active_trip_card.dart';
import 'cancelled_trip_card.dart';
import 'completed_trip_card.dart';

class DriverTripsList extends StatelessWidget {
  final List<DriverTrip> trips;
  final bool isDark;

  const DriverTripsList({
    super.key,
    required this.trips,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.r),
      child: Column(children: trips.map((t) => _cardFor(t)).toList()),
    );
  }

  Widget _cardFor(DriverTrip trip) {
    switch (trip.status) {
      case DriverTripStatus.active:
        return ActiveTripCard(trip: trip, isDark: isDark);
      case DriverTripStatus.completed:
        return CompletedTripCard(trip: trip, isDark: isDark);
      case DriverTripStatus.cancelled:
        return CancelledTripCard(trip: trip, isDark: isDark);
    }
  }
}
