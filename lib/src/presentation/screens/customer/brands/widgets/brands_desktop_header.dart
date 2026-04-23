import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BrandsDesktopHeader extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final Widget searchField;

  const BrandsDesktopHeader({
    super.key,
    required this.isDark,
    required this.cs,
    required this.searchField,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(CupertinoIcons.back, size: 18.r, color: cs.onSurface),
          ),
        ),
        SizedBox(width: 14.r),
        Text(
          'brands_title'.tr(),
          style: TextStyle(fontSize: 24.r, fontWeight: FontWeight.bold, color: cs.onSurface),
        ),
        const Spacer(),
        SizedBox(width: 360.r, child: searchField),
      ],
    );
  }
}
