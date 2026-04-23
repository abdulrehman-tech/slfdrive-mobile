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
          ...earnings.map(
            (e) => RecentEarningTile(earning: e, isDark: isDark),
          ),
        ],
      ),
    );
  }
}
