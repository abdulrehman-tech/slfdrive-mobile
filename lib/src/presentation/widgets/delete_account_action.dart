import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/role_provider.dart';

/// Runs the full account-deletion sequence behind a blocking loading overlay.
///
/// `AuthProvider.deleteAccount()` soft-deletes the account server-side before
/// clearing local state, so it can take a moment — this shows a non-dismissible
/// spinner until it finishes. On success it routes to `/auth`; on failure the
/// session is kept and the error is surfaced in a snackbar so the user can
/// retry.
///
/// Call this *after* dismissing the confirm dialog, passing the page context.
Future<void> deleteAccountWithLoading(BuildContext context) async {
  final router = GoRouter.of(context);
  final auth = context.read<AuthProvider>();
  final role = context.read<RoleProvider>();
  final rootNavigator = Navigator.of(context, rootNavigator: true);
  final messenger = ScaffoldMessenger.of(context);
  final isDark = Theme.of(context).brightness == Brightness.dark;

  // Non-dismissible loading overlay (captured navigator dismisses it after).
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (_) => PopScope(
      canPop: false,
      child: Center(
        child: Container(
          padding: EdgeInsets.all(22.r),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
            borderRadius: BorderRadius.circular(18.r),
          ),
          child: const CircularProgressIndicator(),
        ),
      ),
    ),
  );

  bool deleted = false;
  try {
    deleted = await auth.deleteAccount();
    if (deleted) await role.clear();
  } finally {
    rootNavigator.pop(); // dismiss the loading overlay
  }

  if (deleted) {
    router.go('/auth');
  } else {
    messenger.showSnackBar(
      SnackBar(
        content: Text(auth.error ?? 'profile_delete_failed'.tr()),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFE53935),
      ),
    );
  }
}
