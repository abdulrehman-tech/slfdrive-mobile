import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'action_tile.dart';
import 'glass_section.dart';

class SupportSection extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const SupportSection({super.key, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    return GlassSection(
      isDark: isDark,
      cs: cs,
      title: 'driver_section_support'.tr(),
      icon: Iconsax.message_question,
      iconColor: const Color(0xFF4CAF50),
      children: [
        ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.info_circle,
          title: 'driver_help_center'.tr(),
          onTap: () => context.push('/help'),
        ),
        ThinDivider(isDark: isDark),
        ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.document_text,
          title: 'driver_terms'.tr(),
          onTap: () => context.push('/legal/terms'),
        ),
        ThinDivider(isDark: isDark),
        ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.shield_tick,
          title: 'driver_privacy'.tr(),
          onTap: () => context.push('/legal/privacy'),
        ),
      ],
    );
  }
}
