import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_shimmer.dart';

/// Reusable shimmer skeleton for list/grid loading states — a column of rounded
/// placeholder cards. Drop-in replacement for a `CircularProgressIndicator` in
/// any list-loading spot.
class ListSkeleton extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry? padding;
  final double spacing;

  const ListSkeleton({
    super.key,
    this.itemCount = 6,
    this.itemHeight = 88,
    this.padding,
    this.spacing = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF1E1E2E) : const Color(0xFFE0E0E0);
    final pad = padding ?? EdgeInsets.fromLTRB(16.r, 12.r, 16.r, 16.r);

    return AppShimmer(
      baseColor: base,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: pad,
        child: Column(
          children: List.generate(itemCount, (i) {
            return Padding(
              padding: EdgeInsets.only(bottom: i < itemCount - 1 ? spacing.r : 0),
              child: Container(
                height: itemHeight.r,
                decoration: BoxDecoration(
                  color: base,
                  borderRadius: BorderRadius.circular(18.r),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}
