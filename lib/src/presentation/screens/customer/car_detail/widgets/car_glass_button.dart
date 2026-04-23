import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Floating frosted-glass icon button used on the image gallery overlay.
class CarGlassButton extends StatelessWidget {
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  final Color? iconColor;

  const CarGlassButton({
    super.key,
    required this.icon,
    required this.isDark,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withValues(alpha: 0.45) : Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.black.withValues(alpha: 0.08),
              ),
            ),
            child: Icon(icon, size: 18.r, color: iconColor ?? (isDark ? Colors.white : Colors.black87)),
          ),
        ),
      ),
    );
  }
}
