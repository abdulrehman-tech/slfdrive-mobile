import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../providers/theme_provider.dart';
import '../provider/driver_home_provider.dart';
import 'logout_dialog.dart';
import 'theme_pill.dart';

/// Shared drawer content used by both the mobile `Drawer` and the desktop
/// left rail.
class DriverDrawerContent extends StatelessWidget {
  final bool isDark;
  final int drawerSelectedIndex;
  final ValueChanged<int> onTabSelect;

  const DriverDrawerContent({
    super.key,
    required this.isDark,
    required this.drawerSelectedIndex,
    required this.onTabSelect,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08);

    return Column(
      children: [
        _DrawerHeader(isDark: isDark, cs: cs),
        Expanded(child: _DrawerItems(isDark: isDark, borderCol: borderCol, drawerSelectedIndex: drawerSelectedIndex, onTabSelect: onTabSelect)),
        _DrawerBottom(isDark: isDark, cs: cs, borderCol: borderCol),
      ],
    );
  }
}

class DriverMobileDrawer extends StatelessWidget {
  final bool isDark;
  final int drawerSelectedIndex;
  final ValueChanged<int> onTabSelect;

  const DriverMobileDrawer({
    super.key,
    required this.isDark,
    required this.drawerSelectedIndex,
    required this.onTabSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFAFAFA),
      child: SafeArea(
        child: DriverDrawerContent(
          isDark: isDark,
          drawerSelectedIndex: drawerSelectedIndex,
          onTabSelect: onTabSelect,
        ),
      ),
    );
  }
}

class DriverDesktopDrawer extends StatelessWidget {
  final bool isDark;
  final int drawerSelectedIndex;
  final ValueChanged<int> onTabSelect;

  const DriverDesktopDrawer({
    super.key,
    required this.isDark,
    required this.drawerSelectedIndex,
    required this.onTabSelect,
  });

  @override
  Widget build(BuildContext context) {
    final borderCol = isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.08);

    return Container(
      width: 280.r,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFFAFAFA),
        border: Border(right: BorderSide(color: borderCol)),
      ),
      child: DriverDrawerContent(
        isDark: isDark,
        drawerSelectedIndex: drawerSelectedIndex,
        onTabSelect: onTabSelect,
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const _DrawerHeader({required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverHomeProvider>();

    return Container(
      padding: EdgeInsets.all(20.r),
      child: Column(
        children: [
          Container(
            width: 80.r,
            height: 80.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF4D63DD).withValues(alpha: 0.6),
                  const Color(0xFF0C2485).withValues(alpha: 0.4),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(3.r),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                ),
                child: Icon(Icons.person, size: 40.r, color: const Color(0xFF4D63DD)),
              ),
            ),
          ),
          SizedBox(height: 12.r),
          Text(
            'driver_name'.tr(),
            style: TextStyle(
              fontSize: 18.r,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 4.r),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 4.r),
            decoration: BoxDecoration(
              color: const Color(0xFF4D63DD).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              'driver_badge'.tr(),
              style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w600, color: const Color(0xFF4D63DD)),
            ),
          ),
          SizedBox(height: 16.r),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _StatChip(value: '${provider.totalTrips}', label: 'driver_trips'.tr(), isDark: isDark),
              _StatChip(value: provider.rating.toString(), label: 'driver_rating'.tr(), isDark: isDark),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String value;
  final String label;
  final bool isDark;

  const _StatChip({required this.value, required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.w700, color: isDark ? Colors.white : Colors.black87),
        ),
        SizedBox(height: 2.r),
        Text(
          label,
          style: TextStyle(fontSize: 11.r, color: isDark ? Colors.white60 : Colors.black54),
        ),
      ],
    );
  }
}

class _DrawerItems extends StatelessWidget {
  final bool isDark;
  final Color borderCol;
  final int drawerSelectedIndex;
  final ValueChanged<int> onTabSelect;

  const _DrawerItems({
    required this.isDark,
    required this.borderCol,
    required this.drawerSelectedIndex,
    required this.onTabSelect,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 12.r),
      children: [
        _DrawerItem(icon: Iconsax.home_2, title: 'driver_home'.tr(), index: 0, isDark: isDark, drawerSelectedIndex: drawerSelectedIndex, onTabSelect: onTabSelect),
        _DrawerItem(icon: Iconsax.wallet_3, title: 'driver_earnings'.tr(), index: 1, isDark: isDark, drawerSelectedIndex: drawerSelectedIndex, onTabSelect: onTabSelect),
        _DrawerItem(icon: Iconsax.car, title: 'driver_trips'.tr(), index: 2, isDark: isDark, drawerSelectedIndex: drawerSelectedIndex, onTabSelect: onTabSelect),
        _DrawerItem(icon: Iconsax.user, title: 'driver_profile'.tr(), index: 3, isDark: isDark, drawerSelectedIndex: drawerSelectedIndex, onTabSelect: onTabSelect),
        Divider(height: 32.r, color: borderCol),
        _DrawerItem(icon: Iconsax.message_question, title: 'driver_help'.tr(), index: 4, isDark: isDark, drawerSelectedIndex: drawerSelectedIndex, onTabSelect: onTabSelect),
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final int index;
  final bool isDark;
  final int drawerSelectedIndex;
  final ValueChanged<int> onTabSelect;

  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.index,
    required this.isDark,
    required this.drawerSelectedIndex,
    required this.onTabSelect,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = drawerSelectedIndex == index;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).pop();
        // Drawer has 5 items: 0-3 match the shell tabs; 4 → /help.
        if (index <= 3) {
          onTabSelect(index);
        } else if (index == 4) {
          context.push('/help');
        }
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 4.r),
        padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 14.r),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDark
                    ? const Color(0xFF4D63DD).withValues(alpha: 0.15)
                    : const Color(0xFF4D63DD).withValues(alpha: 0.08))
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20.r,
              color: isSelected ? const Color(0xFF4D63DD) : (isDark ? Colors.white70 : Colors.black54),
            ),
            SizedBox(width: 16.r),
            Text(
              title,
              style: TextStyle(
                fontSize: 15.r,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? const Color(0xFF4D63DD) : (isDark ? Colors.white70 : Colors.black54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerBottom extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final Color borderCol;

  const _DrawerBottom({required this.isDark, required this.cs, required this.borderCol});

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
                  isActive: !context.watch<ThemeProvider>().isDarkMode && !context.watch<ThemeProvider>().isSystemMode,
                  activeColor: const Color(0xFFFFA000),
                  onTap: () => context.read<ThemeProvider>().setLightMode(),
                  isDark: isDark,
                ),
                ThemePill(
                  label: 'theme_dark'.tr(),
                  icon: Iconsax.moon,
                  isActive: context.watch<ThemeProvider>().isDarkMode,
                  activeColor: const Color(0xFF7C4DFF),
                  onTap: () => context.read<ThemeProvider>().setDarkMode(),
                  isDark: isDark,
                ),
              ],
            ),
          ),
          SizedBox(height: 12.r),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              showDriverLogoutDialog(context, isDark);
            },
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
                    'driver_sign_out'.tr(),
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
