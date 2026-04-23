import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Animated page indicator for the car image gallery.
class ImageDots extends StatelessWidget {
  final int count;
  final int active;
  final double activeWidth;

  const ImageDots({
    super.key,
    required this.count,
    required this.active,
    this.activeWidth = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == active;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          margin: EdgeInsets.symmetric(horizontal: 3.r),
          width: isActive ? activeWidth.r : 6.r,
          height: 6.r,
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(3.r),
          ),
        );
      }),
    );
  }
}
