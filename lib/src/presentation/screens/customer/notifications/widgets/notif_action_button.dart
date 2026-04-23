import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotifActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onTap;
  final bool enabled;
  final bool danger;

  const NotifActionButton({
    super.key,
    required this.icon,
    required this.label,
    required this.isDark,
    required this.cs,
    required this.onTap,
    this.enabled = true,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = danger ? const Color(0xFFE53935) : cs.primary;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.4,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 9.r),
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.18 : 0.1),
            borderRadius: BorderRadius.circular(11.r),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 15.r, color: color),
              SizedBox(width: 6.r),
              Text(label, style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
