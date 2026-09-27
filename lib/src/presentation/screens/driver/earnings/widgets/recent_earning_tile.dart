import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../models/earnings_period.dart';
import '../../../../widgets/omr_icon.dart';

class RecentEarningTile extends StatelessWidget {
  final RecentEarning earning;
  final bool isDark;

  const RecentEarningTile({
    super.key,
    required this.earning,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.r),
      padding: EdgeInsets.all(14.r),
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
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Iconsax.tick_circle,
              color: const Color(0xFF4CAF50),
              size: 22.r,
            ),
          ),
          SizedBox(width: 14.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  earning.customer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 15.r,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 4.r),
                Text(
                  earning.date,
                  style: TextStyle(
                    fontSize: 13.r,
                    color: isDark ? Colors.white60 : const Color(0xFF757575),
                  ),
                ),
              ],
            ),
          ),
          OmrAmount.value(
            earning.amount,
            style: TextStyle(
              fontSize: 16.r,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF4D63DD),
            ),
          ),
        ],
      ),
    );
  }
}
