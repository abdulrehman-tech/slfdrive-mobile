import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Compact "Sort" pill rendered on the desktop header.
class DesktopSortButton extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onTap;

  const DesktopSortButton({
    super.key,
    required this.isDark,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 8.r),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.07),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.sort, size: 16.r, color: cs.onSurface.withValues(alpha: 0.6)),
            SizedBox(width: 6.r),
            Text(
              'Sort',
              style: TextStyle(
                fontSize: 12.r,
                fontWeight: FontWeight.w600,
                color: cs.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
