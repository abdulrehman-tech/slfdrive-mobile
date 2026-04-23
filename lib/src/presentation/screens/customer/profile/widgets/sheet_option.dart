import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class SheetOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool active;
  final VoidCallback onTap;
  final bool isDark;
  final ColorScheme cs;

  const SheetOption({
    super.key,
    required this.icon,
    required this.label,
    required this.color,
    required this.active,
    required this.onTap,
    required this.isDark,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 8.r),
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: active
              ? color.withValues(alpha: isDark ? 0.2 : 0.12)
              : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: active
                ? color.withValues(alpha: 0.35)
                : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: color.withValues(alpha: active ? 0.25 : 0.15),
                borderRadius: BorderRadius.circular(11.r),
              ),
              child: Icon(icon, color: color, size: 18.r),
            ),
            SizedBox(width: 12.r),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
              ),
            ),
            if (active) Icon(Iconsax.tick_circle_copy, color: color, size: 19.r),
          ],
        ),
      ),
    );
  }
}
