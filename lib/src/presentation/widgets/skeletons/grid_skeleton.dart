import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Reusable shimmer skeleton for grid loading states (e.g. brands) — a grid of
/// circle + label placeholders shaped like the real tiles.
class GridSkeleton extends StatelessWidget {
  final int crossAxisCount;
  final int itemCount;
  final EdgeInsetsGeometry? padding;

  const GridSkeleton({
    super.key,
    this.crossAxisCount = 3,
    this.itemCount = 9,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF1E1E2E) : const Color(0xFFE0E0E0);

    return Skeletonizer(
      enabled: true,
      effect: ShimmerEffect(
        baseColor: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFE0E0E0),
        highlightColor: isDark ? const Color(0xFF2A2A3E) : const Color(0xFFF5F5F5),
        duration: const Duration(milliseconds: 1500),
      ),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: padding ?? EdgeInsets.fromLTRB(16.r, 12.r, 16.r, 32.r),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12.r,
          mainAxisSpacing: 12.r,
          childAspectRatio: 0.82,
        ),
        itemCount: itemCount,
        itemBuilder: (_, i) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 58.r,
              height: 58.r,
              decoration: BoxDecoration(color: base, shape: BoxShape.circle),
            ),
            SizedBox(height: 8.r),
            Container(
              width: 42.r,
              height: 10.r,
              decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(4.r)),
            ),
          ],
        ),
      ),
    );
  }
}
