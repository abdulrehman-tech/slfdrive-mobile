import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ActionTile extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? color;
  final Color? titleColor;

  const ActionTile({
    super.key,
    required this.isDark,
    required this.cs,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.color,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 14.r),
        child: Row(
          children: [
            Icon(icon, size: 20.r, color: color ?? (isDark ? Colors.white70 : Colors.black54)),
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
                      color: titleColor ?? (isDark ? Colors.white : Colors.black87),
                    ),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4.r),
                    Text(
                      subtitle!,
                      style: TextStyle(fontSize: 13.r, color: isDark ? Colors.white60 : Colors.black54),
                    ),
                  ],
                ],
              ),
            ),
            Icon(CupertinoIcons.forward, size: 16.r, color: isDark ? Colors.white38 : Colors.black26),
          ],
        ),
      ),
    );
  }
}
