import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../../constants/image_constants.dart';
import '../../../../constants/url_constants.dart';
import '../../../utils/contact_launcher.dart';

/// About SLF Drive — app identity, version, a short description, website and
/// legal links. Reached from the profile and drawer via `/about`.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cs = Theme.of(context).colorScheme;
    final year = DateTime.now().year;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
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
                'about_title'.tr(),
                style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.w700, color: cs.onSurface),
              ),
            ),
            SliverToBoxAdapter(
              child: Center(
                child: Container(
                  constraints: BoxConstraints(maxWidth: 640.r),
                  padding: EdgeInsets.fromLTRB(20.r, 24.r, 20.r, 40.r),
                  child: Column(
                    children: [
                      // Logo + name + version
                      Container(
                        width: 96.r,
                        height: 96.r,
                        padding: EdgeInsets.all(18.r),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF4D63DD), Color(0xFF677EF0)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(28.r),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4D63DD).withValues(alpha: 0.35),
                              blurRadius: 24.r,
                              offset: Offset(0, 10.r),
                            ),
                          ],
                        ),
                        child: Image.asset(ImageConstants.logoWhite, fit: BoxFit.contain),
                      ),
                      SizedBox(height: 18.r),
                      Text(
                        'app_name'.tr(),
                        style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.w800, color: cs.onSurface),
                      ),
                      SizedBox(height: 4.r),
                      Text(
                        'about_tagline'.tr(),
                        style: TextStyle(fontSize: 13.r, color: cs.onSurface.withValues(alpha: 0.6)),
                      ),
                      SizedBox(height: 10.r),
                      FutureBuilder<PackageInfo>(
                        future: PackageInfo.fromPlatform(),
                        builder: (context, snap) {
                          final info = snap.data;
                          final v = info == null ? '' : 'v${info.version} (${info.buildNumber})';
                          if (v.isEmpty) return const SizedBox.shrink();
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 5.r),
                            decoration: BoxDecoration(
                              color: cs.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              v,
                              style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w700, color: cs.primary),
                            ),
                          );
                        },
                      ),
                      SizedBox(height: 24.r),
                      // Description
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20.r),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        child: Text(
                          'about_description'.tr(),
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 14.r, height: 1.6, color: cs.onSurface.withValues(alpha: 0.75)),
                        ),
                      ),
                      SizedBox(height: 16.r),
                      _tile(
                        context,
                        icon: Iconsax.global,
                        color: const Color(0xFF3D5AFE),
                        label: 'about_website'.tr(),
                        isDark: isDark,
                        onTap: () => ContactLauncher.openWebsite(UrlConstants.aboutUs),
                      ),
                      _tile(
                        context,
                        icon: Iconsax.document_text,
                        color: const Color(0xFF7C4DFF),
                        label: 'legal_terms_title'.tr(),
                        isDark: isDark,
                        onTap: () => context.push('/legal/terms'),
                      ),
                      _tile(
                        context,
                        icon: Iconsax.security_safe,
                        color: const Color(0xFF00BCD4),
                        label: 'legal_privacy_title'.tr(),
                        isDark: isDark,
                        onTap: () => context.push('/legal/privacy'),
                      ),
                      SizedBox(height: 24.r),
                      Text(
                        'drawer_copyright'.tr(namedArgs: {'year': '$year'}),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.4)),
                      ),
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

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.only(bottom: 12.r),
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
                  width: 40.r,
                  height: 40.r,
                  decoration: BoxDecoration(color: color.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12.r)),
                  child: Icon(icon, color: color, size: 20.r),
                ),
                SizedBox(width: 14.r),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w600, color: cs.onSurface),
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
}
