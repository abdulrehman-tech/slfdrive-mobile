import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../providers/auth_provider.dart';
import '../widgets/delete_account_dialog.dart';
import '../widgets/profile_section.dart';
import '../widgets/profile_tile.dart';

/// Danger zone shared by both roles — hosts the App Store-required
/// "Delete Account" action behind a confirmation dialog. Hidden for guests
/// (no account to delete). Carries its own top gap so hiding it leaves no
/// double spacing in the parent list.
class DangerZoneSection extends StatelessWidget {
  final bool isDark;
  const DangerZoneSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    if (context.watch<AuthProvider>().isGuest) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(top: 16.r),
      child: ProfileSection(
        title: 'profile_section_danger'.tr(),
        isDark: isDark,
        children: [
          ProfileTile(
            icon: Iconsax.trash_copy,
            iconColor: const Color(0xFFE53935),
            title: 'profile_delete_account'.tr(),
            isDark: isDark,
            onTap: () => showDeleteAccountDialog(context, isDark: isDark),
          ),
        ],
      ),
    );
  }
}
