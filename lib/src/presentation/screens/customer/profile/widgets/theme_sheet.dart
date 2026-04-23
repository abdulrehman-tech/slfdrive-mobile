import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../providers/theme_provider.dart';
import '../../../../widgets/bottom_sheets/app_bottom_sheet.dart';
import 'sheet_option.dart';

void showProfileThemeSheet(BuildContext context, {required bool isDark}) {
  final cs = Theme.of(context).colorScheme;
  final tp = context.read<ThemeProvider>();
  AppBottomSheet.show(
    context: context,
    title: 'profile_theme'.tr(),
    child: Padding(
      padding: EdgeInsets.only(bottom: 12.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SheetOption(
            icon: Iconsax.sun_1_copy,
            label: 'theme_light'.tr(),
            color: const Color(0xFFFFC107),
            active: tp.isLightMode,
            onTap: () {
              tp.setLightMode();
              Navigator.pop(context);
            },
            isDark: isDark,
            cs: cs,
          ),
          SheetOption(
            icon: Iconsax.moon_copy,
            label: 'theme_dark'.tr(),
            color: const Color(0xFF7C4DFF),
            active: tp.isDarkMode,
            onTap: () {
              tp.setDarkMode();
              Navigator.pop(context);
            },
            isDark: isDark,
            cs: cs,
          ),
          SheetOption(
            icon: Iconsax.mobile_copy,
            label: 'profile_theme_system'.tr(),
            color: const Color(0xFF00BCD4),
            active: tp.isSystemMode,
            onTap: () {
              tp.setSystemMode();
              Navigator.pop(context);
            },
            isDark: isDark,
            cs: cs,
          ),
        ],
      ),
    ),
  );
}
