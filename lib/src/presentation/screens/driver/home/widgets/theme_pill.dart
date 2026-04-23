import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ThemePill extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isActive;
  final Color activeColor;
  final VoidCallback onTap;
  final bool isDark;

  const ThemePill({
    super.key,
    required this.label,
    required this.icon,
    required this.isActive,
    required this.activeColor,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: EdgeInsets.symmetric(vertical: 10.r),
          decoration: BoxDecoration(
            color: isActive ? (isDark ? Colors.white.withValues(alpha: 0.1) : Colors.white) : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: isActive
                ? [BoxShadow(color: activeColor.withValues(alpha: 0.2), blurRadius: 8.r, offset: Offset(0, 2.r))]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16.r, color: isActive ? activeColor : (isDark ? Colors.white54 : Colors.black38)),
              SizedBox(width: 6.r),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.r,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? activeColor : (isDark ? Colors.white54 : Colors.black38),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
