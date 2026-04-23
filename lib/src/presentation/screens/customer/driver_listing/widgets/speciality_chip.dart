import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SpecialityChip extends StatelessWidget {
  final String label;
  final bool active;
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onTap;

  const SpecialityChip({
    super.key,
    required this.label,
    required this.active,
    required this.isDark,
    required this.cs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 8.r),
        decoration: BoxDecoration(
          color: active
              ? cs.primary.withValues(alpha: isDark ? 0.2 : 0.12)
              : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04)),
          borderRadius: BorderRadius.circular(12.r),
          border: active ? Border.all(color: cs.primary.withValues(alpha: 0.3)) : null,
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12.r,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active ? cs.primary : cs.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      ),
    );
  }
}
