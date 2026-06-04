import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../constants/color_constants.dart';
import '../providers/auth_provider.dart';

/// Guards a gated action behind authentication.
///
/// Returns `true` when the user is signed in and may proceed. For a guest (came
/// in via "Continue as guest"), it shows a "login required" sheet and returns
/// `false` — the caller must abort the action. If the guest taps "Sign in",
/// they're routed to `/auth`.
///
/// Usage:
/// ```dart
/// if (!await requireLogin(context)) return;
/// // ...authenticated-only action...
/// ```
Future<bool> requireLogin(BuildContext context, {String? message}) async {
  final auth = context.read<AuthProvider>();
  if (auth.isAuthenticated) return true;

  final goLogin = await _showLoginPrompt(context, message);
  if (goLogin == true && context.mounted) {
    context.push('/auth');
  }
  return false;
}

Future<bool?> _showLoginPrompt(BuildContext context, String? message) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<bool>(
    context: context,
    backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
    ),
    builder: (sheetContext) {
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.r, 20.r, 24.r, 24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.r,
                height: 4.r,
                margin: EdgeInsets.only(bottom: 20.r),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: secondaryColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(Iconsax.lock_1_copy, color: secondaryColor, size: 30.r),
              ),
              SizedBox(height: 18.r),
              Text(
                'login_required_title'.tr(),
                style: TextStyle(
                  fontSize: 18.r,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : Colors.black87,
                ),
              ),
              SizedBox(height: 8.r),
              Text(
                message ?? 'login_required_message'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13.r,
                  height: 1.4,
                  color: isDark ? Colors.white70 : Colors.black54,
                ),
              ),
              SizedBox(height: 22.r),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(false),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.r),
                        backgroundColor:
                            isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text(
                        'cancel'.tr(),
                        style: TextStyle(
                          fontSize: 14.r,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.r),
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.of(sheetContext).pop(true),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14.r),
                        backgroundColor: secondaryColor,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                      ),
                      child: Text(
                        'sign_in'.tr(),
                        style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w800, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}
