import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'action_tile.dart';
import 'glass_section.dart';
import 'logout_dialog.dart';

class DangerZoneSection extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const DangerZoneSection({super.key, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    return GlassSection(
      isDark: isDark,
      cs: cs,
      title: 'driver_section_danger'.tr(),
      icon: Iconsax.warning_2,
      iconColor: const Color(0xFFE53935),
      children: [
        ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.logout,
          title: 'driver_sign_out'.tr(),
          color: const Color(0xFFE53935),
          titleColor: const Color(0xFFE53935),
          onTap: () => showDriverLogoutDialog(context, isDark),
        ),
        ThinDivider(isDark: isDark),
        ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.trash,
          title: 'driver_delete_account'.tr(),
          subtitle: 'driver_delete_warning'.tr(),
          color: const Color(0xFFE53935),
          titleColor: const Color(0xFFE53935),
          onTap: () => context.push('/profile/edit'),
        ),
      ],
    );
  }
}
