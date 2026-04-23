import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileToggleTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final bool isDark;

  const ProfileToggleTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.onChanged,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.all(10.r),
      child: Row(
        children: [
          Container(
            width: 34.r,
            height: 34.r,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.2 : 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 16.r, color: iconColor),
          ),
          SizedBox(width: 12.r),
          Expanded(
            child: Text(
              title,
              style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w600, color: cs.onSurface),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 38.r,
              height: 22.r,
              padding: EdgeInsets.all(2.r),
              decoration: BoxDecoration(
                color: value ? cs.primary : cs.onSurface.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: value ? AlignmentDirectional.centerEnd : AlignmentDirectional.centerStart,
                child: Container(
                  width: 18.r,
                  height: 18.r,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 3.r, offset: Offset(0, 1.r)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
