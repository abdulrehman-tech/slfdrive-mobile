import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../providers/theme_provider.dart';
import 'logout_dialog.dart';
import 'theme_pill.dart';

class DrawerBottom extends StatelessWidget {
  final bool isDark;
  final Color borderCol;

  const DrawerBottom({super.key, required this.isDark, required this.borderCol});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(16.r, 12.r, 16.r, 28.r),
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: borderCol)),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: borderCol),
            ),
            child: Row(
              children: [
                ThemePill(
                  label: 'theme_light'.tr(),
                  icon: Iconsax.sun_1,
                  active: !isDark,
                  activeColor: const Color(0xFFFFC107),
                  onTap: () => context.read<ThemeProvider>().setLightMode(),
                  isDark: isDark,
                ),
                ThemePill(
                  label: 'theme_dark'.tr(),
                  icon: Iconsax.moon,
                  active: isDark,
                  activeColor: const Color(0xFF7C4DFF),
                  onTap: () => context.read<ThemeProvider>().setDarkMode(),
                  isDark: isDark,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.r),
          GestureDetector(
            onTap: () => showLogoutDialog(context, isDark),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 14.r),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935).withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: const Color(0xFFE53935).withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.logout, color: const Color(0xFFE53935), size: 18.r),
                  SizedBox(width: 8.r),
                  Text(
                    'drawer_sign_out'.tr(),
                    style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: const Color(0xFFE53935)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
