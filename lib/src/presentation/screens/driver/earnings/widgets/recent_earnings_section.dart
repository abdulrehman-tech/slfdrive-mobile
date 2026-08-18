import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/earnings_period.dart';
import 'recent_earning_tile.dart';

class RecentEarningsSection extends StatelessWidget {
  final List<RecentEarning> earnings;
  final bool isDark;

  const RecentEarningsSection({
    super.key,
    required this.earnings,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'earnings_recent'.tr(),
            style: TextStyle(
              fontSize: 18.r,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16.r),
          if (earnings.isEmpty)
            _EmptyRecent(isDark: isDark)
          else
            ...earnings.map(
              (e) => RecentEarningTile(earning: e, isDark: isDark),
            ),
        ],
      ),
    );
  }
}

class _EmptyRecent extends StatelessWidget {
  final bool isDark;

  const _EmptyRecent({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 28.r, horizontal: 20.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Icon(Icons.receipt_long_rounded, size: 36.r, color: isDark ? Colors.white24 : Colors.black26),
          SizedBox(height: 12.r),
          Text(
            'earnings_no_recent'.tr(),
            style: TextStyle(
              fontSize: 15.r,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          SizedBox(height: 4.r),
          Text(
            'earnings_no_recent_desc'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.r, color: isDark ? Colors.white38 : Colors.black45),
          ),
        ],
      ),
    );
  }
}
