import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../constants/url_constants.dart';
import '../../../../utils/contact_launcher.dart';
import '../widgets/profile_section.dart';
import '../widgets/profile_tile.dart';

/// Help / legal / about group shared by both roles.
class SupportSection extends StatelessWidget {
  final bool isDark;
  const SupportSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return ProfileSection(
      title: 'profile_section_support'.tr(),
      isDark: isDark,
      children: [
        ProfileTile(
          icon: Iconsax.message_question_copy,
          iconColor: const Color(0xFF3D5AFE),
          title: 'profile_help_center'.tr(),
          isDark: isDark,
          onTap: () => context.push('/help'),
        ),
        ProfileTile(
          icon: Iconsax.star_1_copy,
          iconColor: const Color(0xFFFFC107),
          title: 'profile_rate_app'.tr(),
          isDark: isDark,
          onTap: () => ContactLauncher.openWebsite(
            defaultTargetPlatform == TargetPlatform.iOS
                ? UrlConstants.appStoreUrl
                : UrlConstants.playStoreUrl,
          ),
        ),
        ProfileTile(
          icon: Iconsax.document_text_copy,
          iconColor: const Color(0xFF7C4DFF),
          title: 'profile_terms'.tr(),
          isDark: isDark,
          onTap: () => context.push('/legal/terms'),
        ),
        ProfileTile(
          icon: Iconsax.security_safe_copy,
          iconColor: const Color(0xFF00BCD4),
          title: 'profile_privacy_policy'.tr(),
          isDark: isDark,
          onTap: () => context.push('/legal/privacy'),
        ),
        ProfileTile(
          icon: Iconsax.info_circle_copy,
          iconColor: const Color(0xFF4CAF50),
          title: 'profile_about'.tr(),
          isDark: isDark,
          onTap: () => context.push('/about'),
        ),
      ],
    );
  }
}
