import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/earnings_period.dart';

class EarningsTotalCard extends StatelessWidget {
  final EarningsSnapshot snapshot;

  const EarningsTotalCard({super.key, required this.snapshot});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.r),
      child: Container(
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4D63DD), Color(0xFF677EF0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4D63DD).withValues(alpha: 0.3),
              blurRadius: 20.r,
              offset: Offset(0, 8.r),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'earnings_total'.tr(),
                  style: TextStyle(
                    fontSize: 14.r,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.r,
                    vertical: 6.r,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.arrow_up,
                        size: 14.r,
                        color: Colors.white,
                      ),
                      SizedBox(width: 4.r),
                      Text(
                        '+12%',
                        style: TextStyle(
                          fontSize: 12.r,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.r),
            Text(
              'OMR ${snapshot.total.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 36.r,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 8.r),
            Text(
              '${snapshot.trips} trips • ${snapshot.hours} hours',
              style: TextStyle(
                fontSize: 14.r,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
