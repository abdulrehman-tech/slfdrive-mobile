import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../../../providers/auth_provider.dart';
import '../../../../providers/theme_provider.dart';
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
    final auth = context.watch<AuthProvider>();
    final name = (auth.displayName?.trim().isNotEmpty ?? false)
        ? auth.displayName!.trim()
        : 'driver_name'.tr();
    final email = (auth.displayEmail?.trim().isNotEmpty ?? false)
        ? auth.displayEmail!.trim()
        : '';
    final avatarUrl = auth.avatarUrl;

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
                child: avatarUrl != null
                    ? ClipOval(
                        child: Image.network(
                          avatarUrl,
                          width: 74.r,
                          height: 74.r,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              Icon(Icons.person, size: 40.r, color: const Color(0xFF4D63DD)),
                        ),
                      )
                    : Icon(Icons.person, size: 40.r, color: const Color(0xFF4D63DD)),
              ),
            ),
          ),
          SizedBox(height: 12.r),
          Text(
            name,
            style: TextStyle(
              fontSize: 18.r,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : Colors.black87,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (email.isNotEmpty) ...[
            SizedBox(height: 4.r),
            Text(
              email,
              style: TextStyle(
                fontSize: 12.r,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
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
        _DrawerItem(activeIcon: Iconsax.home_2, inactiveIcon: Iconsax.home_2_copy, title: 'driver_home'.tr(), index: 0, isDark: isDark, drawerSelectedIndex: drawerSelectedIndex, onTabSelect: onTabSelect),
        _DrawerItem(activeIcon: Iconsax.wallet_3, inactiveIcon: Iconsax.wallet_3_copy, title: 'driver_earnings'.tr(), index: 1, isDark: isDark, drawerSelectedIndex: drawerSelectedIndex, onTabSelect: onTabSelect),
        _DrawerItem(activeIcon: Iconsax.car, inactiveIcon: Iconsax.car_copy, title: 'driver_trips'.tr(), index: 2, isDark: isDark, drawerSelectedIndex: drawerSelectedIndex, onTabSelect: onTabSelect),
        _DrawerItem(activeIcon: Iconsax.user, inactiveIcon: Iconsax.user_copy, title: 'driver_profile'.tr(), index: 3, isDark: isDark, drawerSelectedIndex: drawerSelectedIndex, onTabSelect: onTabSelect),
        Divider(height: 32.r, color: borderCol),
        _DrawerItem(activeIcon: Iconsax.message_question, inactiveIcon: Iconsax.message_question_copy, title: 'driver_help'.tr(), index: 4, isDark: isDark, drawerSelectedIndex: drawerSelectedIndex, onTabSelect: onTabSelect),
      ],
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String title;
  final int index;
  final bool isDark;
  final int drawerSelectedIndex;
  final ValueChanged<int> onTabSelect;

  const _DrawerItem({
    required this.activeIcon,
    required this.inactiveIcon,
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
              isSelected ? activeIcon : inactiveIcon,
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
              // Capture a context that stays mounted after the drawer closes —
              // the drawer item's own context is deactivated by the pop, which
              // would crash logout's GoRouter/Provider lookups.
              final rootContext = Navigator.of(context, rootNavigator: true).context;
              Navigator.of(context).pop();
              showDriverLogoutDialog(rootContext, isDark);
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
          SizedBox(height: 16.r),
          _DriverLegalLinks(isDark: isDark),
          SizedBox(height: 12.r),
          const _DriverVersionFooter(),
        ],
      ),
    );
  }
}

/// Terms · Privacy · Help links row shown above the version footer. Closes the
/// drawer first (capturing the router so the push survives the deactivated
/// drawer context) then opens the target.
class _DriverLegalLinks extends StatelessWidget {
  final bool isDark;
  const _DriverLegalLinks({required this.isDark});

  void _go(BuildContext context, String path) {
    final router = GoRouter.of(context);
    Navigator.of(context).pop();
    router.push(path);
  }

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55);
    Widget link(String key, String path) => GestureDetector(
          onTap: () => _go(context, path),
          child: Text(
            key.tr(),
            style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w600, color: muted),
          ),
        );
    Widget dot() => Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.r),
          child: Text('·', style: TextStyle(fontSize: 12.r, color: muted)),
        );

    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        link('legal_terms_title', '/legal/terms'),
        dot(),
        link('legal_privacy_title', '/legal/privacy'),
      ],
    );
  }
}

/// App name + version/build + copyright at the very bottom of the driver drawer.
class _DriverVersionFooter extends StatelessWidget {
  const _DriverVersionFooter();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final year = DateTime.now().year;
    return Column(
      children: [
        FutureBuilder<PackageInfo>(
          future: PackageInfo.fromPlatform(),
          builder: (context, snap) {
            final info = snap.data;
            final version = info == null ? '' : 'v${info.version} (${info.buildNumber})';
            return Text(
              version.isEmpty ? 'SLF Drive' : 'SLF Drive · $version',
              style: TextStyle(fontSize: 11.r, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.4)),
            );
          },
        ),
        SizedBox(height: 3.r),
        Text(
          'drawer_copyright'.tr(namedArgs: {'year': '$year'}),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.3)),
        ),
      ],
    );
  }
}
