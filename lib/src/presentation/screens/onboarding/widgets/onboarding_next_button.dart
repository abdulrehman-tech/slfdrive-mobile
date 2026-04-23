import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../constants/color_constants.dart';

class OnboardingNextButton extends StatelessWidget {
  final bool isLastPage;
  final VoidCallback onTap;
  final bool isDesktop;

  const OnboardingNextButton({
    super.key,
    required this.isLastPage,
    required this.onTap,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final height = isDesktop ? 60.0 : 56.r;
    final radius = isDesktop ? 16.0 : 16.r;
    final fontSize = isDesktop ? 18.0 : 16.r;
    final iconSize = isDesktop ? 18.0 : 16.r;
    final gap = isDesktop ? 12.0 : 8.r;

    return Container(
      height: height,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(radius)),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  isLastPage ? 'get_started'.tr() : 'next'.tr(),
                  style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w600, color: secondaryColor),
                ),
                SizedBox(width: gap),
                Icon(Icons.arrow_forward_ios, color: secondaryColor, size: iconSize),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
