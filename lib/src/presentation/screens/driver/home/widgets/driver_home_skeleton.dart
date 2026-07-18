import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../widgets/skeletons/app_shimmer.dart';

/// Full-screen shimmer for the driver home while the first load is in flight.
/// Mirrors the real layout: header, earnings card, quick-stats row, and a
/// couple of trip-request cards.
class DriverHomeSkeleton extends StatelessWidget {
  const DriverHomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF1E1E2E) : const Color(0xFFE8E8E8);

    return AppShimmer(
      baseColor: base,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(base),
            SizedBox(height: 8.r),
            _earningsCard(base),
            SizedBox(height: 20.r),
            _quickStats(base),
            _requestsHeader(base),
            _requestCard(base),
            _requestCard(base),
            SizedBox(height: 40.r),
          ],
        ),
      ),
    );
  }

  Widget _box(Color c, double w, double h, {double r = 4}) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(color: c, borderRadius: BorderRadius.circular(r.r)),
      );

  Widget _header(Color base) {
    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Row(
        children: [
          _box(base, 44.r, 44.r, r: 12),
          SizedBox(width: 16.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _box(base, 80.r, 12.r),
                SizedBox(height: 8.r),
                _box(base, 140.r, 18.r),
              ],
            ),
          ),
          _box(base, 96.r, 40.r, r: 24),
        ],
      ),
    );
  }

  Widget _earningsCard(Color base) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.r),
      child: Container(
        height: 180.r,
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(24.r)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _box(base.withValues(alpha: 0.5), 100.r, 12.r),
            SizedBox(height: 14.r),
            _box(base.withValues(alpha: 0.5), 150.r, 30.r),
            const Spacer(),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (i) {
                final heights = [0.5, 0.7, 0.4, 0.85, 0.6, 0.45, 0.9];
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 3.r),
                    child: _box(base.withValues(alpha: 0.5), double.infinity, 44.r * heights[i]),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _quickStats(Color base) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.r),
      child: Row(
        children: List.generate(3, (i) {
          return Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i < 2 ? 12.r : 0),
              child: Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(16.r)),
                child: Column(
                  children: [
                    _box(base.withValues(alpha: 0.5), 40.r, 40.r, r: 12),
                    SizedBox(height: 12.r),
                    _box(base.withValues(alpha: 0.5), 36.r, 18.r),
                    SizedBox(height: 6.r),
                    _box(base.withValues(alpha: 0.5), 50.r, 10.r),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _requestsHeader(Color base) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.r, 20.r, 20.r, 16.r),
      child: _box(base, 160.r, 18.r),
    );
  }

  Widget _requestCard(Color base) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.r, 0, 20.r, 12.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(16.r)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _box(base.withValues(alpha: 0.5), 44.r, 44.r, r: 12),
                SizedBox(width: 12.r),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _box(base.withValues(alpha: 0.5), 120.r, 15.r),
                    SizedBox(height: 6.r),
                    _box(base.withValues(alpha: 0.5), 80.r, 12.r),
                  ],
                ),
                const Spacer(),
                _box(base.withValues(alpha: 0.5), 70.r, 26.r, r: 8),
              ],
            ),
            SizedBox(height: 16.r),
            _box(base.withValues(alpha: 0.5), double.infinity, 14.r),
            SizedBox(height: 10.r),
            _box(base.withValues(alpha: 0.5), 220.r, 14.r),
            SizedBox(height: 16.r),
            _box(base.withValues(alpha: 0.5), double.infinity, 56.r, r: 12),
            SizedBox(height: 16.r),
            Row(
              children: [
                Expanded(child: _box(base.withValues(alpha: 0.5), double.infinity, 44.r, r: 12)),
                SizedBox(width: 12.r),
                Expanded(child: _box(base.withValues(alpha: 0.5), double.infinity, 44.r, r: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
