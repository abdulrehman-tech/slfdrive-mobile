import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../provider/driver_profile_provider.dart';
import 'glass_section.dart';
import 'toggle_tile.dart';

class NotificationsSection extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const NotificationsSection({super.key, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverProfileProvider>();
    return GlassSection(
      isDark: isDark,
      cs: cs,
      title: 'driver_section_notifications'.tr(),
      icon: Iconsax.notification,
      iconColor: const Color(0xFFFFA000),
      children: [
        ToggleTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.notification_bing,
          title: 'driver_push_notifications'.tr(),
          subtitle: 'driver_push_desc'.tr(),
          value: provider.pushNotifications,
          onChanged: (val) => context.read<DriverProfileProvider>().setPushNotifications(val),
        ),
        ThinDivider(isDark: isDark),
        ToggleTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.sms,
          title: 'driver_email_notifications'.tr(),
          subtitle: 'driver_email_desc'.tr(),
          value: provider.emailNotifications,
          onChanged: (val) => context.read<DriverProfileProvider>().setEmailNotifications(val),
        ),
        ThinDivider(isDark: isDark),
        ToggleTile(
          isDark: isDark,
          cs: cs,
          icon: Iconsax.message,
          title: 'driver_sms_notifications'.tr(),
          subtitle: 'driver_sms_desc'.tr(),
          value: provider.smsNotifications,
          onChanged: (val) => context.read<DriverProfileProvider>().setSmsNotifications(val),
        ),
      ],
    );
  }
}
