import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../providers/auth_provider.dart';
import '../../../providers/theme_provider.dart';
import '../../common/profile/sections/danger_zone_section.dart';
import '../../common/profile/sections/preferences_section.dart';
import '../../common/profile/sections/sign_out_button.dart';
import '../../common/profile/sections/support_section.dart';
import '../../common/profile/widgets/profile_header_card.dart';
import '../../common/profile/widgets/profile_section.dart';
import '../../common/profile/widgets/profile_tile.dart';
import 'provider/driver_profile_provider.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => DriverProfileProvider(), child: const _DriverProfileView());
  }
}

class _DriverProfileView extends StatelessWidget {
  const _DriverProfileView();

  bool _isDark(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final provider = context.watch<DriverProfileProvider>();
    final auth = context.watch<AuthProvider>();
    final topPad = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.r, topPad + 12.r, 16.r, 100.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ProfileHeaderCard(
              isDark: isDark,
              statusChip: _StatusChip(isVerified: auth.isVerified),
            ),
            SizedBox(height: 18.r),
            ProfileSection(
              title: 'profile_section_account'.tr(),
              isDark: isDark,
              children: [
                ProfileTile(
                  icon: Iconsax.user_edit_copy,
                  iconColor: const Color(0xFF3D5AFE),
                  title: 'profile_edit_profile'.tr(),
                  isDark: isDark,
                  onTap: () => context.push('/profile/edit'),
                ),
                ProfileTile(
                  icon: Iconsax.call_copy,
                  iconColor: const Color(0xFF4CAF50),
                  title: 'profile_phone'.tr(),
                  value: auth.displayPhone ?? '',
                  isDark: isDark,
                  onTap: () => context.push('/profile/edit'),
                ),
                ProfileTile(
                  icon: Iconsax.sms_copy,
                  iconColor: const Color(0xFFFF6D00),
                  title: 'profile_email_address'.tr(),
                  value: auth.displayEmail ?? '',
                  isDark: isDark,
                  onTap: () => context.push('/profile/edit'),
                ),
              ],
            ),
            SizedBox(height: 16.r),
            PreferencesSection(
              isDark: isDark,
              pushNotifications: provider.pushNotifications,
              onPushChanged: provider.setPushNotifications,
            ),
            SizedBox(height: 16.r),
            SupportSection(isDark: isDark),
            DangerZoneSection(isDark: isDark),
            SizedBox(height: 16.r),
            SignOutButton(isDark: isDark),
          ],
        ),
      ),
    );
  }
}

/// Driver verification status chip rendered in the profile header. Green when
/// the account is admin-approved, orange while pending review.
class _StatusChip extends StatelessWidget {
  final bool isVerified;
  const _StatusChip({required this.isVerified});

  @override
  Widget build(BuildContext context) {
    final color = isVerified ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00);
    final bg = isVerified ? const Color(0xFF69F0AE) : const Color(0xFFFFD54F);
    final icon = isVerified ? Iconsax.shield_tick_copy : Iconsax.clock_copy;
    final label = isVerified ? 'profile_status_verified'.tr() : 'profile_status_pending'.tr();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.r, vertical: 3.r),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20.r)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11.r, color: color),
          SizedBox(width: 4.r),
          Text(
            label,
            style: TextStyle(fontSize: 10.r, color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}
