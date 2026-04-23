import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../../constants/color_constants.dart';

class BookingsEmpty extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const BookingsEmpty({
    super.key,
    required this.isDark,
    required this.cs,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90.r,
            height: 90.r,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.12 : 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color.withValues(alpha: 0.6), size: 40.r),
          ),
          SizedBox(height: 20.r),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.r,
              fontWeight: FontWeight.bold,
              color: cs.onSurface,
            ),
          ),
          SizedBox(height: 8.r),
          SizedBox(
            width: 260.r,
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.r,
                color: cs.onSurface.withValues(alpha: 0.5),
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 24.r),
          GestureDetector(
            onTap: () => context.pushNamed('car-listing'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 28.r, vertical: 12.r),
              decoration: BoxDecoration(
                gradient: primaryGradient,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0C2485).withValues(alpha: 0.35),
                    blurRadius: 12.r,
                    offset: Offset(0, 4.r),
                  ),
                ],
              ),
              child: Text(
                'explore_cars'.tr(),
                style: TextStyle(
                  fontSize: 14.r,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
