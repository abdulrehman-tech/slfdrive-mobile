import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Shimmer skeleton shown while the booking detail loads — mirrors the real
/// layout (header, vehicle/driver, schedule, location, price, action).
class BookingDetailSkeleton extends StatelessWidget {
  const BookingDetailSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF1E1E2E) : const Color(0xFFE0E0E0);

    return SafeArea(
      child: Skeletonizer(
        enabled: true,
        effect: ShimmerEffect(
          baseColor: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFE0E0E0),
          highlightColor: isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF5F5F5),
          duration: const Duration(milliseconds: 1500),
        ),
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: 1100.r),
            child: SingleChildScrollView(
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.fromLTRB(16.r, 8.r, 16.r, 24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top bar: back + title
                  Row(
                    children: [
                      _box(base, 40.r, 40.r, radius: 12.r),
                      SizedBox(width: 14.r),
                      _box(base, 160.r, 18.r),
                    ],
                  ),
                  SizedBox(height: 20.r),
                  _refCard(base),
                  SizedBox(height: 14.r),
                  _vehicleCard(base),
                  SizedBox(height: 14.r),
                  _card(base, height: 96.r),
                  SizedBox(height: 14.r),
                  _card(base, height: 150.r),
                  SizedBox(height: 14.r),
                  _card(base, height: 120.r),
                  SizedBox(height: 14.r),
                  _box(base, double.infinity, 48.r, radius: 14.r),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _box(Color c, double w, double h, {double radius = 8}) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(radius)),
      );

  Widget _card(Color base, {required double height}) => Container(
        height: height,
        decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(20.r)),
      );

  Widget _refCard(Color base) => Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(20.r)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _box(base.withValues(alpha: 0.5), 80.r, 12.r),
                  SizedBox(height: 8.r),
                  _box(base.withValues(alpha: 0.5), 140.r, 18.r),
                ],
              ),
            ),
            _box(base.withValues(alpha: 0.5), 70.r, 26.r, radius: 10.r),
          ],
        ),
      );

  Widget _vehicleCard(Color base) => Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(20.r)),
        child: Column(
          children: [
            Row(
              children: [
                _box(base.withValues(alpha: 0.5), 90.r, 72.r, radius: 14.r),
                SizedBox(width: 14.r),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _box(base.withValues(alpha: 0.5), 130.r, 16.r),
                      SizedBox(height: 8.r),
                      _box(base.withValues(alpha: 0.5), 80.r, 12.r),
                      SizedBox(height: 10.r),
                      _box(base.withValues(alpha: 0.5), 60.r, 14.r),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.r),
            Row(
              children: [
                _box(base.withValues(alpha: 0.5), 70.r, 28.r, radius: 10.r),
                SizedBox(width: 8.r),
                _box(base.withValues(alpha: 0.5), 60.r, 28.r, radius: 10.r),
                SizedBox(width: 8.r),
                _box(base.withValues(alpha: 0.5), 64.r, 28.r, radius: 10.r),
              ],
            ),
          ],
        ),
      );
}

/// A minimal close button overlaid on the skeleton so the user can back out.
class BookingDetailSkeletonClose extends StatelessWidget {
  const BookingDetailSkeletonClose({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SafeArea(
      child: Align(
        alignment: Alignment.topLeft,
        child: IconButton(
          icon: Icon(CupertinoIcons.back, color: cs.onSurface),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
      ),
    );
  }
}
