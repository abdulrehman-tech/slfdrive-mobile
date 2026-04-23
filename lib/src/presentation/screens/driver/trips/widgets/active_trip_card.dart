import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../models/driver_trip.dart';

class ActiveTripCard extends StatelessWidget {
  final DriverTrip trip;
  final bool isDark;

  const ActiveTripCard({super.key, required this.trip, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.r),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: const Color(0xFF4D63DD).withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10.r,
            offset: Offset(0, 4.r),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStatusRow(),
          SizedBox(height: 16.r),
          _buildCustomerRow(),
          SizedBox(height: 16.r),
          _buildLocationRow(
            icon: Iconsax.location,
            iconColor: const Color(0xFF4D63DD),
            text: trip.pickup ?? '',
          ),
          SizedBox(height: 8.r),
          _buildLocationRow(
            icon: Iconsax.location_tick,
            iconColor: const Color(0xFF4CAF50),
            text: trip.destination,
          ),
          SizedBox(height: 16.r),
          _buildCompleteButton(context),
        ],
      ),
    );
  }

  Widget _buildStatusRow() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 6.r),
          decoration: BoxDecoration(
            color: const Color(0xFF4D63DD).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8.r,
                height: 8.r,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF4D63DD),
                ),
              ),
              SizedBox(width: 6.r),
              Text(
                'trips_in_progress'.tr(),
                style: TextStyle(
                  fontSize: 12.r,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4D63DD),
                ),
              ),
            ],
          ),
        ),
        const Spacer(),
        Text(
          trip.time,
          style: TextStyle(
            fontSize: 12.r,
            color: isDark ? Colors.white60 : const Color(0xFF757575),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerRow() {
    return Row(
      children: [
        Container(
          width: 44.r,
          height: 44.r,
          decoration: BoxDecoration(
            color: const Color(0xFF4D63DD).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Iconsax.user,
            color: const Color(0xFF4D63DD),
            size: 20.r,
          ),
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
                trip.distance ?? '',
                style: TextStyle(
                  fontSize: 13.r,
                  color: isDark ? Colors.white60 : const Color(0xFF757575),
                ),
              ),
            ],
          ),
        ),
        Text(
          'OMR ${trip.fare.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 16.r,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF4CAF50),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationRow({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16.r, color: iconColor),
        SizedBox(width: 8.r),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.r,
              color: isDark ? Colors.white70 : const Color(0xFF555555),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompleteButton(BuildContext context) {
    return GestureDetector(
      onTap: () => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('trips_complete_snack'.tr()),
          behavior: SnackBarBehavior.floating,
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12.r),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4D63DD), Color(0xFF677EF0)],
          ),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          'trips_complete'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.r,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
