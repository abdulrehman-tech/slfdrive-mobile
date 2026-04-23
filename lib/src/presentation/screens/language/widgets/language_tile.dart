import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../constants/color_constants.dart';
import '../models/language_option.dart';

class LanguageTile extends StatelessWidget {
  final LanguageOption language;
  final bool isSelected;
  final bool isDesktop;
  final VoidCallback onTap;

  const LanguageTile({
    super.key,
    required this.language,
    required this.isSelected,
    required this.onTap,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final EdgeInsets padding = isDesktop
        ? const EdgeInsets.symmetric(horizontal: 24, vertical: 18)
        : EdgeInsets.symmetric(horizontal: 20.r, vertical: 16.r);
    final double flagSize = isDesktop ? 32 : 28.r;
    final double gap = isDesktop ? 20 : 16.r;
    final double nameSize = isDesktop ? 18 : 16.r;
    final double checkSize = isDesktop ? 28 : 24.r;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: isSelected ? secondaryColor.withValues(alpha: 0.08) : Colors.transparent,
          ),
          child: Row(
            children: [
              Text(language.flag, style: TextStyle(fontSize: flagSize)),
              SizedBox(width: gap),
              Expanded(
                child: Text(
                  language.name,
                  style: TextStyle(
                    fontSize: nameSize,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                  ),
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: secondaryColor, size: checkSize),
            ],
          ),
        ),
      ),
    );
  }
}
