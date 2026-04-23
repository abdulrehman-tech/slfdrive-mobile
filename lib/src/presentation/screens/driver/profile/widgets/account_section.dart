import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'action_tile.dart';
import 'glass_section.dart';

class AccountSection extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const AccountSection({super.key, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    return GlassSection(
      isDark: isDark,
      cs: cs,
      title: 'driver_section_account'.tr(),
      icon: Iconsax.user,
      iconColor: const Color(0xFF4D63DD),
      children: [
        ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.edit,
          title: 'driver_edit_profile'.tr(),
          onTap: () => context.push('/profile/edit'),
        ),
        ThinDivider(isDark: isDark),
        ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.call,
          title: 'driver_phone'.tr(),
          subtitle: '+968 9123 4567',
          onTap: () => context.push('/profile/edit'),
        ),
        ThinDivider(isDark: isDark),
        ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.sms,
          title: 'driver_email'.tr(),
          subtitle: 'driver@example.com',
          onTap: () => context.push('/profile/edit'),
        ),
        ThinDivider(isDark: isDark),
        ActionTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.car,
          title: 'driver_vehicle_info'.tr(),
          onTap: () => context.push('/profile/edit'),
        ),
      ],
    );
  }
}
