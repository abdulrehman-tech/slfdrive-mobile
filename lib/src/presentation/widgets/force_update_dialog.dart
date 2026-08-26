import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../constants/url_constants.dart';
import '../../core/models/app/app_version_info.dart';
import '../utils/contact_launcher.dart';
import '../utils/platform_utils.dart';

/// Non-dismissible "update required" gate shown on splash when the backend's
/// published version is newer than the installed one and flagged
/// `forceUpdate`. The only way out is the store; back/barrier taps do nothing.
class ForceUpdateDialog extends StatelessWidget {
  final AppVersionInfo info;
  final bool isDark;

  const ForceUpdateDialog({super.key, required this.info, required this.isDark});

  static Future<void> show(BuildContext context, {required AppVersionInfo info, required bool isDark}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (_) => PopScope(canPop: false, child: ForceUpdateDialog(info: info, isDark: isDark)),
    );
  }

  /// Backend-supplied store link for this platform, falling back to the
  /// bundled constants when the row holds a placeholder (e.g. `"1"`).
  static String storeUrlFor(AppVersionInfo info) {
    final candidate = PlatformUtils.isIOS ? info.appStoreUrl : info.playStoreUrl;
    final uri = Uri.tryParse(candidate?.trim() ?? '');
    if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http') && uri.host.isNotEmpty) {
      return uri.toString();
    }
    return PlatformUtils.isIOS ? UrlConstants.appStoreUrl : UrlConstants.playStoreUrl;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final message = (info.message ?? '').trim();
    return Dialog(
      backgroundColor: Colors.transparent,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24.r),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                  blurRadius: 24.r,
                  offset: Offset(0, 8.r),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Iconsax.refresh_circle, color: cs.primary, size: 32.r),
                ),
                SizedBox(height: 20.r),
                Text(
                  'force_update_title'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20.r,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                SizedBox(height: 8.r),
                Text(
                  message.isNotEmpty ? message : 'force_update_msg'.tr(),
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14.r, color: isDark ? Colors.white70 : Colors.black54, height: 1.4),
                ),
                SizedBox(height: 24.r),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () => ContactLauncher.openWebsite(storeUrlFor(info)),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.r),
                      backgroundColor: cs.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text(
                      'force_update_button'.tr(),
                      style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
