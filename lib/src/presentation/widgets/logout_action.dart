import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/role_provider.dart';

/// Runs the full logout sequence behind a blocking loading overlay.
///
/// `AuthProvider.logout()` revokes the refresh token over the network (best
/// effort) before clearing local state, so it can take a moment — this shows a
/// non-dismissible spinner until it finishes, then routes to `/auth`.
///
/// Call this *after* dismissing the confirm dialog, passing the page context.
Future<void> logoutWithLoading(BuildContext context) async {
  final router = GoRouter.of(context);
  final auth = context.read<AuthProvider>();
  final role = context.read<RoleProvider>();
  final rootNavigator = Navigator.of(context, rootNavigator: true);
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

  try {
    await auth.logout();
    await role.clear();
  } finally {
    rootNavigator.pop(); // dismiss the loading overlay
  }
  router.go('/auth');
}
