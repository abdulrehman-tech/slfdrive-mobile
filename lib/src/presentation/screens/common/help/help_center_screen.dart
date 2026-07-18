import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../constants/url_constants.dart';
import '../../../utils/contact_launcher.dart';

/// Help & Support hub — real contact channels (call / email / WhatsApp), FAQ,
/// legal links and socials, sourced from [UrlConstants]. Shared by both roles
/// via the `/help` route.
class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final bg = isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18.r, color: cs.onSurface),
                onPressed: () => context.pop(),
              ),
              title: Text(
                'help_center_title'.tr(),
                style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.w700, color: cs.onSurface),
              ),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 720.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 16.r),
                      _hero(),
                      _sectionTitle('help_contact_title'.tr(), cs),
                      _contactCard(
                        context,
                        icon: Iconsax.call,
                        color: const Color(0xFF4CAF50),
                        title: 'help_call_title'.tr(),
                        subtitle: UrlConstants.supportPhone,
                        isDark: isDark,
                        onTap: () => _launch(context, ContactLauncher.openPhoneCall(UrlConstants.supportPhone)),
                      ),
                      _contactCard(
                        context,
                        icon: Iconsax.sms,
                        color: const Color(0xFF3D5AFE),
                        title: 'help_email_title'.tr(),
                        subtitle: UrlConstants.supportEmail,
                        isDark: isDark,
                        onTap: () => _launch(
                          context,
                          ContactLauncher.openEmail(UrlConstants.supportEmail, subject: 'SLF Drive — Support'),
                        ),
                      ),
                      _infoCard(
                        context,
                        icon: Iconsax.clock,
                        color: const Color(0xFFFFA000),
                        title: 'help_hours_title'.tr(),
                        subtitle: 'help_hours_value'.tr(),
                        isDark: isDark,
                      ),
                      _infoCard(
                        context,
                        icon: Iconsax.location,
                        color: const Color(0xFFE53935),
                        title: 'help_office_title'.tr(),
                        subtitle: 'help_office_value'.tr(),
                        isDark: isDark,
                      ),
                      _sectionTitle('help_resources_title'.tr(), cs),
                      _contactCard(
                        context,
                        icon: Iconsax.document_text,
                        color: const Color(0xFF7C4DFF),
                        title: 'legal_terms_title'.tr(),
                        subtitle: 'help_terms_sub'.tr(),
                        isDark: isDark,
                        onTap: () => context.push('/legal/terms'),
                      ),
                      _contactCard(
                        context,
                        icon: Iconsax.security_safe,
                        color: const Color(0xFF00BCD4),
                        title: 'legal_privacy_title'.tr(),
                        subtitle: 'help_privacy_sub'.tr(),
                        isDark: isDark,
                        onTap: () => context.push('/legal/privacy'),
                      ),
                      SizedBox(height: 40.r),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hero() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(24.r),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4D63DD), Color(0xFF677EF0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24.r),
          boxShadow: [
            BoxShadow(color: const Color(0xFF4D63DD).withValues(alpha: 0.3), blurRadius: 20.r, offset: Offset(0, 8.r)),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), shape: BoxShape.circle),
              child: Icon(Iconsax.lifebuoy, color: Colors.white, size: 28.r),
            ),
            SizedBox(width: 16.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'help_hero_title'.tr(),
                    style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.w800, color: Colors.white),
                  ),
                  SizedBox(height: 4.r),
                  Text(
                    'help_hero_sub'.tr(),
                    style: TextStyle(fontSize: 13.r, height: 1.35, color: Colors.white.withValues(alpha: 0.85)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text, ColorScheme cs) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.r, 24.r, 24.r, 12.r),
      child: Text(
        text,
        style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w700, color: cs.onSurface),
      ),
    );
  }

  Widget _contactCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(20.r, 0, 20.r, 12.r),
      child: Material(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.r),
            child: Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12.r)),
                  child: Icon(icon, color: color, size: 22.r),
                ),
                SizedBox(width: 14.r),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w600, color: cs.onSurface),
                      ),
                      SizedBox(height: 3.r),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios_rounded, size: 14.r, color: cs.onSurface.withValues(alpha: 0.3)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Non-tappable info tile (support hours, office location).
  Widget _infoCard(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required bool isDark,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(20.r, 0, 20.r, 12.r),
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12.r)),
              child: Icon(icon, color: color, size: 22.r),
            ),
            SizedBox(width: 14.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w600, color: cs.onSurface),
                  ),
                  SizedBox(height: 3.r),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.5)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Runs a launch future and shows a fallback snackbar if it couldn't open.
  Future<void> _launch(BuildContext context, Future<bool> future) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await future;
    if (!context.mounted || ok) return;
    messenger.showSnackBar(
      SnackBar(content: Text('help_launch_failed'.tr()), behavior: SnackBarBehavior.floating),
    );
  }
}
