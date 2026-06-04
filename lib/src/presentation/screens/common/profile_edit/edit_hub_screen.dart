import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../profile/widgets/profile_section.dart';
import '../profile/widgets/profile_tile.dart';

/// Driver edit hub — routes each API field group to its own focused editor so a
/// driver's many details aren't crammed into one screen.
class ProfileEditHubScreen extends StatelessWidget {
  const ProfileEditHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        elevation: 0,
        title: Text('profile_edit_hub_title'.tr()),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20.r, 12.r, 20.r, 32.r),
        physics: const BouncingScrollPhysics(),
        child: ProfileSection(
          title: 'profile_edit_hub_title'.tr(),
          isDark: isDark,
          children: [
            ProfileTile(
              icon: Iconsax.user_copy,
              iconColor: const Color(0xFF3D5AFE),
              title: 'profile_edit_personal'.tr(),
              isDark: isDark,
              onTap: () => context.push('/profile/edit/personal'),
            ),
            ProfileTile(
              icon: Iconsax.car_copy,
              iconColor: const Color(0xFF7C4DFF),
              title: 'profile_edit_vehicle'.tr(),
              isDark: isDark,
              onTap: () => context.push('/profile/edit/vehicle'),
            ),
            ProfileTile(
              icon: Iconsax.medal_copy,
              iconColor: const Color(0xFF4CAF50),
              title: 'profile_edit_professional'.tr(),
              isDark: isDark,
              onTap: () => context.push('/profile/edit/professional'),
            ),
            ProfileTile(
              icon: Iconsax.document_copy,
              iconColor: const Color(0xFFFF6D00),
              title: 'profile_edit_documents'.tr(),
              isDark: isDark,
              onTap: () => context.push('/profile/edit/documents'),
            ),
          ],
        ),
      ),
    );
  }
}
