import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DriverSectionHeader extends StatelessWidget {
  final ColorScheme cs;
  final IconData icon;
  final Color color;
  final String title;
  final bool isDark;

  const DriverSectionHeader({
    super.key,
    required this.cs,
    required this.icon,
    required this.color,
    required this.title,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 30.r,
          height: 30.r,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.2 : 0.12),
            borderRadius: BorderRadius.circular(9.r),
          ),
          child: Icon(icon, size: 15.r, color: color),
        ),
        SizedBox(width: 10.r),
        Text(
          title,
          style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
        ),
      ],
    );
  }
}
