import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Small icon + label pill used for seats/transmission/fuel specs.
class SpecChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final ColorScheme cs;

  const SpecChip({
    super.key,
    required this.icon,
    required this.label,
    required this.isDark,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.r, vertical: 3.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10.r, color: cs.onSurface.withValues(alpha: 0.45)),
          SizedBox(width: 3.r),
          Text(
            label,
            style: TextStyle(fontSize: 9.r, color: cs.onSurface.withValues(alpha: 0.55), fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
