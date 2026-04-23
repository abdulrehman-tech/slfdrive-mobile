import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'profile_section.dart';
import 'profile_tile.dart';

class MyDataSection extends StatelessWidget {
  final bool isDark;
  const MyDataSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ProfileSection(
      title: 'profile_section_my_data'.tr(),
      isDark: isDark,
      children: [
        ProfileTile(
          icon: Iconsax.location_copy,
          iconColor: const Color(0xFF3D5AFE),
          title: 'profile_section_addresses'.tr(),
          value: '2',
          isDark: isDark,
          onTap: () => context.push('/profile/addresses'),
        ),
        ProfileTile(
          icon: Iconsax.card_copy,
          iconColor: const Color(0xFF4CAF50),
          title: 'profile_section_payments'.tr(),
          value: '2',
          isDark: isDark,
          onTap: () => context.push('/profile/payments'),
        ),
        ProfileTile(
          icon: Iconsax.personalcard_copy,
          iconColor: const Color(0xFF7C4DFF),
          title: 'profile_section_documents'.tr(),
          value: 'profile_pending'.tr(),
          valueColor: const Color(0xFFFF6D00),
          isDark: isDark,
          onTap: () => context.push('/profile/kyc'),
        ),
      ],
    );
  }
}
