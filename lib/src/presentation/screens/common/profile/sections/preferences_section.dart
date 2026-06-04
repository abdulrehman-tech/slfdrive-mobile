import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../providers/theme_provider.dart';
import '../data/profile_languages.dart';
import '../widgets/language_sheet.dart';
import '../widgets/profile_section.dart';
import '../widgets/profile_tile.dart';
import '../widgets/profile_toggle_tile.dart';
import '../widgets/theme_sheet.dart';

/// Preferences group shared by both roles: language, theme, currency, push
/// notifications. Behaviour is identical across customer and driver — language
/// goes through easy_localization, theme through [ThemeProvider]. The push
/// toggle is owned by the caller (each role's profile provider) and passed in.
class PreferencesSection extends StatelessWidget {
  final bool isDark;
  final bool pushNotifications;
  final ValueChanged<bool> onPushChanged;

  const PreferencesSection({
    super.key,
    required this.isDark,
    required this.pushNotifications,
    required this.onPushChanged,
  });

  String _currentLangName(BuildContext context) {
    final loc = context.locale;
    final match = kProfileLanguages.where((l) => l.locale.languageCode == loc.languageCode);
    return match.isNotEmpty ? match.first.name : 'English';
  }

  String _currentThemeLabel(BuildContext context) {
    final tp = Provider.of<ThemeProvider>(context, listen: false);
    if (tp.isDarkMode) return 'theme_dark'.tr();
    if (tp.isLightMode) return 'theme_light'.tr();
    return 'profile_theme_system'.tr();
  }

  @override
  Widget build(BuildContext context) {
    // Watch ThemeProvider so the label refreshes after the sheet dismisses.
    context.watch<ThemeProvider>();

    return ProfileSection(
      title: 'profile_section_preferences'.tr(),
      isDark: isDark,
      children: [
        ProfileTile(
          icon: Iconsax.global_copy,
          iconColor: const Color(0xFF3D5AFE),
          title: 'profile_language'.tr(),
          value: _currentLangName(context),
          isDark: isDark,
          onTap: () => showProfileLanguageSheet(context, isDark: isDark),
        ),
        ProfileTile(
          icon: Iconsax.brush_2_copy,
          iconColor: const Color(0xFF7C4DFF),
          title: 'profile_theme'.tr(),
          value: _currentThemeLabel(context),
          isDark: isDark,
          onTap: () => showProfileThemeSheet(context, isDark: isDark),
        ),
        ProfileTile(
          icon: Iconsax.money_recive_copy,
          iconColor: const Color(0xFF4CAF50),
          title: 'profile_currency'.tr(),
          value: 'OMR',
          isDark: isDark,
          onTap: () => ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('profile_currency_locked'.tr()),
              behavior: SnackBarBehavior.floating,
            ),
          ),
        ),
        ProfileToggleTile(
          icon: Iconsax.notification_copy,
          iconColor: const Color(0xFFFF6D00),
          title: 'settings_push_notifications'.tr(),
          value: pushNotifications,
          onChanged: onPushChanged,
          isDark: isDark,
        ),
      ],
    );
  }
}
