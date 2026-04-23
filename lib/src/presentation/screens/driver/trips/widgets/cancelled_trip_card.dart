import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../models/driver_trip.dart';

class CancelledTripCard extends StatelessWidget {
  final DriverTrip trip;
  final bool isDark;

  const CancelledTripCard({
    super.key,
    required this.trip,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.r),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.r),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48.r,
            height: 48.r,
            decoration: BoxDecoration(
              color: Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(Iconsax.close_circle, color: Colors.red, size: 22.r),
          ),
          SizedBox(width: 16.r),
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
                  'To: ${trip.destination}',
                  style: TextStyle(
                    fontSize: 13.r,
                    color: isDark ? Colors.white60 : const Color(0xFF757575),
                  ),
                ),
                SizedBox(height: 4.r),
                Text(
                  trip.reason ?? '',
                  style: TextStyle(fontSize: 12.r, color: Colors.red),
                ),
              ],
            ),
          ),
          Text(
            trip.time,
            style: TextStyle(
              fontSize: 12.r,
              color: isDark ? Colors.white60 : const Color(0xFF757575),
            ),
          ),
        ],
      ),
    );
  }
}
