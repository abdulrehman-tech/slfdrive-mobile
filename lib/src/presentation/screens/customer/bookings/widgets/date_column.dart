import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class DateColumn extends StatelessWidget {
  final String label;
  final String date;
  final IconData icon;
  final Color color;
  final bool isDark;
  final ColorScheme cs;

  const DateColumn({
    super.key,
    required this.label,
    required this.date,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13.r, color: color),
            SizedBox(width: 4.r),
            Text(
              label,
              style: TextStyle(
                fontSize: 10.r,
                color: cs.onSurface.withValues(alpha: 0.5),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 3.r),
        Text(
          date,
          style: TextStyle(
            fontSize: 12.r,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}
