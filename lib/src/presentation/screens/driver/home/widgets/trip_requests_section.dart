import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../models/trip_request.dart';
import '../provider/driver_home_provider.dart';

class TripRequestsSection extends StatelessWidget {
  final bool isDark;

  const TripRequestsSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final requests = context.watch<DriverHomeProvider>().requests;

    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'driver_new_requests'.tr(),
            style: TextStyle(
              fontSize: 18.r,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16.r),
          ...requests.map((trip) => TripRequestCard(trip: trip, isDark: isDark)),
        ],
      ),
    );
  }
}

class TripRequestCard extends StatelessWidget {
  final TripRequest trip;
  final bool isDark;

  const TripRequestCard({super.key, required this.trip, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.r),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10.r, offset: Offset(0, 4.r))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: const Color(0xFF4D63DD).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Iconsax.user, color: const Color(0xFF4D63DD), size: 20.r),
              ),
              SizedBox(width: 12.r),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.customer,
                      style: TextStyle(
                        fontSize: 15.r,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 4.r),
                    Text(
                      '${trip.distance} • ${trip.time} away',
                      style: TextStyle(fontSize: 13.r, color: isDark ? Colors.white60 : const Color(0xFF757575)),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 6.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'OMR ${trip.fare.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: const Color(0xFF4CAF50)),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.r),
          Row(
            children: [
              Icon(Iconsax.location, size: 16.r, color: const Color(0xFF4D63DD)),
              SizedBox(width: 8.r),
              Expanded(
                child: Text(
                  trip.pickup,
                  style: TextStyle(fontSize: 13.r, color: isDark ? Colors.white70 : const Color(0xFF555555)),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.r),
          Row(
            children: [
              Icon(Iconsax.location_tick, size: 16.r, color: const Color(0xFF4CAF50)),
              SizedBox(width: 8.r),
              Expanded(
                child: Text(
                  trip.destination,
                  style: TextStyle(fontSize: 13.r, color: isDark ? Colors.white70 : const Color(0xFF555555)),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.r),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => context.read<DriverHomeProvider>().removeRequest(trip),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.r),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'driver_decline'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w600, color: Colors.red),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.r),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    context.read<DriverHomeProvider>().removeRequest(trip);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('driver_accept_snack'.tr()),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.r),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF4D63DD), Color(0xFF677EF0)]),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'driver_accept'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
