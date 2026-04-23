import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../provider/driver_home_provider.dart';

class EarningsCard extends StatelessWidget {
  final bool isDark;

  const EarningsCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final earnings = context.watch<DriverHomeProvider>().todayEarnings;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.r),
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4D63DD), Color(0xFF677EF0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(color: const Color(0xFF4D63DD).withValues(alpha: 0.3), blurRadius: 20.r, offset: Offset(0, 8.r)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'driver_today_earnings'.tr(),
                  style: TextStyle(fontSize: 14.r, color: Colors.white.withValues(alpha: 0.8)),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 6.r),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    '+12%',
                    style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.r),
            Text(
              'OMR ${earnings.toStringAsFixed(2)}',
              style: TextStyle(fontSize: 32.r, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 20.r),
            Row(
              children: const [
                _EarningsBar(day: 'Mon', height: 0.6),
                _EarningsBar(day: 'Tue', height: 0.8),
                _EarningsBar(day: 'Wed', height: 0.4),
                _EarningsBar(day: 'Thu', height: 0.9),
                _EarningsBar(day: 'Fri', height: 0.7),
                _EarningsBar(day: 'Sat', height: 0.5),
                _EarningsBar(day: 'Sun', height: 1.0, isToday: true),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EarningsBar extends StatelessWidget {
  final String day;
  final double height;
  final bool isToday;

  const _EarningsBar({required this.day, required this.height, this.isToday = false});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            height: 40.r * height,
            decoration: BoxDecoration(
              color: isToday ? Colors.white : Colors.white.withValues(alpha: 0.3),
              borderRadius: BorderRadius.vertical(top: Radius.circular(4.r)),
            ),
          ),
          SizedBox(height: 8.r),
          Text(
            day,
            style: TextStyle(
              fontSize: 10.r,
              fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
              color: isToday ? Colors.white : Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
