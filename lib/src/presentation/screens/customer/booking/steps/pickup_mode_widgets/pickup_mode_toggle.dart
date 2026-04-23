import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PickupModeToggle extends StatelessWidget {
  final bool isActive;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  const PickupModeToggle({
    super.key,
    required this.isActive,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: isActive
              ? color.withValues(alpha: isDark ? 0.2 : 0.12)
              : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isActive
                ? color.withValues(alpha: 0.45)
                : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06)),
            width: isActive ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: isActive ? color : color.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: isActive ? Colors.white : color, size: 18.r),
            ),
            SizedBox(height: 10.r),
            Text(
              title,
              style: TextStyle(
                fontSize: 13.r,
                fontWeight: FontWeight.w700,
                color: isActive ? cs.onSurface : cs.onSurface.withValues(alpha: 0.85),
              ),
            ),
            SizedBox(height: 3.r),
            Text(
              subtitle,
              style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.5), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}
