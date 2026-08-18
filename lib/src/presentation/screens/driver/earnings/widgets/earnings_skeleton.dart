import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../widgets/skeletons/app_shimmer.dart';

/// Shimmer placeholder for the earnings tab mirroring its layout: total card,
/// chart card, 2×2 stats grid and a few recent-earning rows.
class EarningsSkeleton extends StatelessWidget {
  const EarningsSkeleton({super.key});

  Widget _box(double h, {double? w, double radius = 16}) => Container(
        height: h.r,
        width: w?.r,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(radius.r),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _box(150),
            SizedBox(height: 20.r),
            _box(200),
            SizedBox(height: 20.r),
            Row(
              children: [
                Expanded(child: _box(90)),
                SizedBox(width: 12.r),
                Expanded(child: _box(90)),
              ],
            ),
            SizedBox(height: 12.r),
            Row(
              children: [
                Expanded(child: _box(90)),
                SizedBox(width: 12.r),
                Expanded(child: _box(90)),
              ],
            ),
            SizedBox(height: 24.r),
            _box(18, w: 140, radius: 6),
            SizedBox(height: 14.r),
            _box(64, radius: 12),
            SizedBox(height: 10.r),
            _box(64, radius: 12),
            SizedBox(height: 10.r),
            _box(64, radius: 12),
          ],
        ),
      ),
    );
  }
}
