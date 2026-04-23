import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../providers/language_provider.dart';
import '../../../../providers/theme_provider.dart';
import 'action_tile.dart';
import 'glass_section.dart';

class SettingsSection extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const SettingsSection({super.key, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    return GlassSection(
      isDark: isDark,
      cs: cs,
      title: 'driver_section_settings'.tr(),
      icon: Iconsax.setting_2,
      iconColor: const Color(0xFF7C4DFF),
      children: [
        ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.language_square,
          title: 'driver_language'.tr(),
          subtitle: 'English',
          onTap: () => context.read<LanguageProvider>().toggleLanguage(),
        ),
        ThinDivider(isDark: isDark),
        ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.brush_2,
          title: 'driver_theme'.tr(),
          subtitle: isDark ? 'Dark' : 'Light',
          onTap: () => context.read<ThemeProvider>().toggleTheme(),
        ),
      ],
    );
  }
}
