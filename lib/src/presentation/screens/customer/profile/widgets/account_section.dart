import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'profile_section.dart';
import 'profile_tile.dart';

class AccountSection extends StatelessWidget {
  final bool isDark;
  const AccountSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ProfileSection(
      title: 'profile_section_account'.tr(),
      isDark: isDark,
      children: [
        ProfileTile(
          icon: Iconsax.call_copy,
          iconColor: const Color(0xFF4CAF50),
          title: 'profile_phone'.tr(),
          value: '+968 9000 0000',
          isDark: isDark,
          onTap: () => context.push('/profile/edit'),
        ),
        ProfileTile(
          icon: Iconsax.sms_copy,
          iconColor: const Color(0xFF00BCD4),
          title: 'profile_email_address'.tr(),
          value: 'guest@slfdrive.com',
          isDark: isDark,
          onTap: () => context.push('/profile/edit'),
        ),
        ProfileTile(
          icon: Iconsax.shield_tick_copy,
          iconColor: const Color(0xFF7C4DFF),
          title: 'profile_verify_identity'.tr(),
          value: 'profile_verified'.tr(),
          valueColor: const Color(0xFF4CAF50),
          isDark: isDark,
          onTap: () => context.push('/profile/kyc'),
        ),
      ],
    );
  }
}
