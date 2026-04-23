import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ThemePill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;
  final bool isDark;

  const ThemePill({
    super.key,
    required this.label,
    required this.icon,
    required this.active,
    required this.activeColor,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.symmetric(vertical: 10.r),
          decoration: BoxDecoration(
            color: active ? activeColor.withValues(alpha: isDark ? 0.2 : 0.12) : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 15.r, color: active ? activeColor : cs.onSurface.withValues(alpha: 0.4)),
              SizedBox(width: 6.r),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12.r,
                  fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  color: active ? activeColor : cs.onSurface.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
