import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';

class LanguageSearchField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDesktop;

  const LanguageSearchField({
    super.key,
    required this.controller,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final double fontSize = isDesktop ? 16 : 16.r;
    final double iconSize = isDesktop ? 24 : 24.r;
    final EdgeInsets padding = isDesktop
        ? const EdgeInsets.symmetric(horizontal: 20, vertical: 16)
        : EdgeInsets.symmetric(horizontal: 16.r, vertical: 14.r);
    final BorderRadius radius = isDesktop
        ? BorderRadius.circular(16)
        : BorderRadius.circular(12.r);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: radius,
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'search'.tr(),
          hintStyle: TextStyle(
            color: isDark ? Colors.white38 : const Color(0xFF9E9E9E),
            fontSize: fontSize,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: isDark ? Colors.white38 : const Color(0xFF9E9E9E),
            size: iconSize,
          ),
          border: InputBorder.none,
          contentPadding: padding,
        ),
        style: TextStyle(
          color: isDark ? Colors.white : Colors.black,
          fontSize: fontSize,
        ),
      ),
    );
  }
}
