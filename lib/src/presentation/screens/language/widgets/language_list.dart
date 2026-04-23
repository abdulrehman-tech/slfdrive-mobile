import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../models/language_option.dart';
import 'language_tile.dart';

class LanguageList extends StatelessWidget {
  final List<LanguageOption> languages;
  final String? selectedCode;
  final bool isDesktop;
  final ValueChanged<LanguageOption> onSelected;

  const LanguageList({
    super.key,
    required this.languages,
    required this.selectedCode,
    required this.onSelected,
    this.isDesktop = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final EdgeInsets listPadding = isDesktop
        ? const EdgeInsets.symmetric(vertical: 12)
        : EdgeInsets.symmetric(vertical: 8.r);
    final BorderRadius radius = isDesktop
        ? BorderRadius.circular(16)
        : BorderRadius.circular(16.r);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: radius,
      ),
      child: ListView.separated(
        padding: listPadding,
        itemCount: languages.length,
        separatorBuilder: (context, index) => Divider(
          height: 1,
          thickness: 1,
          color: isDark ? Colors.grey[800] : const Color(0xFFF0F0F0),
        ),
        itemBuilder: (context, index) {
          final language = languages[index];
          return LanguageTile(
            language: language,
            isSelected: selectedCode == language.code,
            isDesktop: isDesktop,
            onTap: () => onSelected(language),
          );
        },
      ),
    );
  }
}
