import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class BrandsSearchField extends StatelessWidget {
  final TextEditingController controller;
  final String query;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool isDark;
  final ColorScheme cs;
  final EdgeInsets? padding;

  const BrandsSearchField({
    super.key,
    required this.controller,
    required this.query,
    required this.onChanged,
    required this.onClear,
    required this.isDark,
    required this.cs,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final field = ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          height: 48.r,
          padding: EdgeInsets.symmetric(horizontal: 14.r),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.05),
            ),
          ),
          child: Row(
            children: [
              Icon(Iconsax.search_normal_copy, size: 18.r, color: cs.onSurface.withValues(alpha: 0.5)),
              SizedBox(width: 10.r),
              Expanded(
                child: TextField(
                  controller: controller,
                  onChanged: onChanged,
                  style: TextStyle(fontSize: 14.r, color: cs.onSurface),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10.r),
                    hintText: 'brands_search_hint'.tr(),
                    hintStyle: TextStyle(fontSize: 14.r, color: cs.onSurface.withValues(alpha: 0.4)),
                  ),
                ),
              ),
              if (query.isNotEmpty)
                GestureDetector(
                  onTap: onClear,
                  child: Icon(Iconsax.close_circle_copy, size: 16.r, color: cs.onSurface.withValues(alpha: 0.4)),
                ),
            ],
          ),
        ),
      ),
    );

    return padding != null ? Padding(padding: padding!, child: field) : field;
  }
}
