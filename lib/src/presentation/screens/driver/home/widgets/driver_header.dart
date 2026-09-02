import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../providers/auth_provider.dart';
import '../../../../widgets/notification_btn.dart';
import '../../shell/driver_shell_provider.dart';
import 'online_status_dialog.dart';

class DriverHeader extends StatelessWidget {
  final bool isDark;

  const DriverHeader({super.key, required this.isDark});

  /// Runs the online/offline toggle and surfaces a failure snackbar — the pill
  /// itself shows the in-flight spinner via [DriverShellProvider.isTogglingOnline].
  static Future<void> runToggle(BuildContext context) async {
    final provider = context.read<DriverShellProvider>();
    final messenger = ScaffoldMessenger.of(context);
    await provider.toggleOnline();
    if (!context.mounted) return;
    if (provider.actionError != null) {
      messenger.showSnackBar(SnackBar(
        content: Text(provider.actionError!.tr()),
        behavior: SnackBarBehavior.floating,
        backgroundColor: const Color(0xFFE53935),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverShellProvider>();
    final isOnline = provider.isOnline;
    final isToggling = provider.isTogglingOnline;
    final auth = context.watch<AuthProvider>();
    final name = (auth.displayName?.trim().isNotEmpty ?? false)
        ? auth.displayName!.trim()
        : 'driver_name'.tr();

    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Row(
        children: [
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Iconsax.menu, size: 20.r, color: isDark ? Colors.white : Colors.black87),
              ),
            ),
          ),
          SizedBox(width: 16.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'driver_welcome'.tr(),
                  style: TextStyle(fontSize: 13.r, color: isDark ? Colors.white60 : const Color(0xFF757575)),
                ),
                SizedBox(height: 2.r),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 18.r,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          // Same inbox as the customer side: '/notifications' is exempt from the
          // router's driver fence (see _sharedAuthedRoutes).
          NotificationBtn(cs: Theme.of(context).colorScheme, isDark: isDark),
          SizedBox(width: 12.r),
          GestureDetector(
            onTap: isToggling
                ? null
                : () => showOnlineStatusDialog(
                      context,
                      isDark: isDark,
                      isCurrentlyOnline: isOnline,
                      onConfirm: () => runToggle(context),
                    ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 10.r),
              decoration: BoxDecoration(
                gradient: isOnline ? const LinearGradient(colors: [Color(0xFF4D63DD), Color(0xFF677EF0)]) : null,
                color: isOnline ? null : (isDark ? const Color(0xFF2A2A2A) : Colors.grey[300]),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isToggling)
                    SizedBox(
                      width: 10.r,
                      height: 10.r,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: isOnline ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                      ),
                    )
                  else
                    Container(
                      width: 8.r,
                      height: 8.r,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: isOnline ? Colors.green : Colors.red),
                    ),
                  SizedBox(width: 8.r),
                  Text(
                    isOnline ? 'driver_online'.tr() : 'driver_offline'.tr(),
                    style: TextStyle(
                      fontSize: 14.r,
                      fontWeight: FontWeight.w600,
                      color: isOnline ? Colors.white : (isDark ? Colors.white70 : Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
