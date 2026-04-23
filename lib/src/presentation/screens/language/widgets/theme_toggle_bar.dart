import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../../providers/theme_provider.dart';
import 'theme_toggle_button.dart';

class ThemeToggleBar extends StatelessWidget {
  const ThemeToggleBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeProvider = context.watch<ThemeProvider>();

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          ThemeToggleButton(
            icon: Icons.light_mode,
            isSelected: !isDark,
            onTap: () => themeProvider.setLightMode(),
          ),
          ThemeToggleButton(
            icon: Icons.dark_mode,
            isSelected: isDark,
            onTap: () => themeProvider.setDarkMode(),
          ),
        ],
      ),
    );
  }
}
