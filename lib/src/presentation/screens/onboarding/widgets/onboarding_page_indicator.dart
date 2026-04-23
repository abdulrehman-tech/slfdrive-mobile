import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingPageIndicator extends StatelessWidget {
  final int count;
  final int currentIndex;
  final bool isDesktop;

  const OnboardingPageIndicator({
    super.key,
    required this.count,
    required this.currentIndex,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return Row(
        children: List.generate(
          count,
          (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsetsDirectional.only(end: 8),
            width: index == currentIndex ? 40 : 10,
            height: 10,
            decoration: BoxDecoration(
              color: index == currentIndex ? Colors.white : Colors.white.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        count,
        (index) => AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4.r),
          width: index == currentIndex ? 32.r : 8.r,
          height: 8.r,
          decoration: BoxDecoration(
            color: index == currentIndex ? Colors.white : Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
      ),
    );
  }
}
