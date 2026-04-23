import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SpecPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final ColorScheme cs;

  const SpecPill({
    super.key,
    required this.icon,
    required this.label,
    required this.isDark,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.r, vertical: 4.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.r, color: cs.onSurface.withValues(alpha: 0.5)),
          SizedBox(width: 4.r),
          Text(
            label,
            style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.65), fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
