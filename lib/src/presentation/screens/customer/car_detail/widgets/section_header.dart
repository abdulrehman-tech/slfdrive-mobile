import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Small icon + title row used as a header inside each detail card.
class SectionHeader extends StatelessWidget {
  final IconData icon;
  final Color accent;
  final String title;
  final bool isDark;
  final ColorScheme cs;

  const SectionHeader({
    super.key,
    required this.icon,
    required this.accent,
    required this.title,
    required this.isDark,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 28.r,
          height: 28.r,
          decoration: BoxDecoration(
            color: accent.withValues(alpha: isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(icon, size: 14.r, color: accent),
        ),
        SizedBox(width: 8.r),
        Text(
          title,
          style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
        ),
      ],
    );
  }
}
