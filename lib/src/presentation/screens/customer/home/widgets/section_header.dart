import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final ColorScheme cs;
  final VoidCallback onViewAll;
  final bool isDesktop;

  const SectionHeader({
    super.key,
    required this.title,
    required this.cs,
    required this.onViewAll,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(isDesktop ? 0 : 16.r, 20.r, isDesktop ? 0 : 16.r, 12.r),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.bold, color: cs.onSurface, letterSpacing: -0.2),
          ),
          GestureDetector(
            onTap: onViewAll,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 5.r),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Text(
                'home_view_all'.tr(),
                style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w700, color: cs.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
