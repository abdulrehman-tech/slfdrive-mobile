import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingBackButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isDesktop;

  const OnboardingBackButton({super.key, required this.onTap, this.isDesktop = false});

  @override
  Widget build(BuildContext context) {
    final size = isDesktop ? 60.0 : 56.r;
    final radius = isDesktop ? 16.0 : 16.r;
    final iconSize = isDesktop ? 24.0 : 20.r;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Icon(Icons.arrow_back_ios_new, color: Colors.white, size: iconSize),
        ),
      ),
    );
  }
}
