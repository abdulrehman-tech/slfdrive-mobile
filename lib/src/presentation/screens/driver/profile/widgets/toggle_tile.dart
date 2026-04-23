import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'mini_switch.dart';

class ToggleTile extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleTile({
    super.key,
    required this.isDark,
    required this.cs,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 14.r),
      child: Row(
        children: [
          Icon(icon, size: 20.r, color: isDark ? Colors.white70 : Colors.black54),
          SizedBox(width: 16.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.r,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 4.r),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13.r, color: isDark ? Colors.white60 : Colors.black54),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.r),
          MiniSwitch(value: value, onChanged: onChanged, isDark: isDark),
        ],
      ),
    );
  }
}
