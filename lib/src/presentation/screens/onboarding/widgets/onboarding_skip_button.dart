import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingSkipButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDesktop;

  const OnboardingSkipButton({super.key, required this.onTap, this.isDesktop = false});

  @override
  Widget build(BuildContext context) {
    if (isDesktop) {
      return TextButton(
        onPressed: onTap,
        child: Text(
          'skip'.tr(),
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
        ),
      );
    }

    return Container(
      width: 80.r,
      height: 56.r,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Center(
            child: Text(
              'skip'.tr(),
              style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w600, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
