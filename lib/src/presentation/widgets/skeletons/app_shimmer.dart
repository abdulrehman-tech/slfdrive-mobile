import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/// Shared shimmer wrapper for skeleton loaders.
///
/// The skeletons are built from solid-coloured placeholder [Container]s, which
/// `Skeletonizer` treats as background and leaves static. `Shimmer.fromColors`
/// masks a moving gradient over ANY child, so the boxes actually shine. Wrap a
/// skeleton's placeholder tree in this to get a consistent sweep everywhere.
class AppShimmer extends StatelessWidget {
  final Widget child;

  /// Base colour of the placeholder boxes — pass the same value used for the
  /// box fills so the resting state matches the sweep's dark end.
  final Color? baseColor;
  final Color? highlightColor;

  const AppShimmer({super.key, required this.child, this.baseColor, this.highlightColor});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: baseColor ?? (isDark ? const Color(0xFF232334) : const Color(0xFFE0E0E0)),
      highlightColor: highlightColor ?? (isDark ? const Color(0xFF3A3A55) : const Color(0xFFF7F7F7)),
      period: const Duration(milliseconds: 1400),
      child: child,
    );
  }
}
