import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? value;
  final Color? valueColor;
  final bool isDark;
  final VoidCallback onTap;

  const ProfileTile({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.isDark,
    required this.onTap,
    this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
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
              if (value != null)
                Padding(
                  padding: EdgeInsetsDirectional.only(end: 6.r),
                  child: Text(
                    value!,
                    style: TextStyle(
                      fontSize: 12.r,
                      color: valueColor ?? cs.onSurface.withValues(alpha: 0.55),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              Icon(Icons.chevron_right, size: 18.r, color: cs.onSurface.withValues(alpha: 0.3)),
            ],
          ),
        ),
      ),
    );
  }
}
