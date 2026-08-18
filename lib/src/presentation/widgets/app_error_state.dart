import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Shared full-body error state: cloud-off icon, the actual error message and
/// a retry button. Pass the provider's [message] (already human-readable via
/// `AppException.message`); falls back to the generic `error_occurred` key.
class AppErrorState extends StatelessWidget {
  final String? message;
  final Future<void> Function()? onRetry;
  final bool isDark;

  const AppErrorState({super.key, this.message, this.onRetry, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.r, 60.r, 20.r, 20.r),
      child: Column(
        children: [
          Icon(Icons.cloud_off_rounded, size: 48.r, color: isDark ? Colors.white38 : Colors.black26),
          SizedBox(height: 16.r),
          // `.tr()` resolves translation keys (e.g. 'driver_error_account') and
          // passes real server sentences through unchanged.
          Text(
            (message?.trim().isNotEmpty ?? false) ? message!.trim().tr() : 'error_occurred'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15.r, color: isDark ? Colors.white70 : Colors.black54),
          ),
          SizedBox(height: 16.r),
          FilledButton(
            onPressed: onRetry == null ? null : () => onRetry!(),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF4D63DD),
              padding: EdgeInsets.symmetric(horizontal: 28.r, vertical: 12.r),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: Text('retry'.tr(), style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
