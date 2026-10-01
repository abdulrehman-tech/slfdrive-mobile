import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../utils/platform_utils.dart';
import 'bottom_sheets/app_bottom_sheet.dart';

/// Wraps a root screen (the shell tabs, pre-login) so the Android back button
/// asks before closing the app instead of exiting straight away.
///
/// Only the last page on the stack triggers the sheet: when the same screen was
/// pushed on top of another (a guest opening `/auth` from the auth gate), or a
/// drawer is open, back behaves as usual. A no-op off Android — iOS has no
/// system back at the root, and on web it would hijack the browser's.
class ExitConfirmScope extends StatefulWidget {
  final Widget child;
  const ExitConfirmScope({super.key, required this.child});

  @override
  State<ExitConfirmScope> createState() => _ExitConfirmScopeState();
}

class _ExitConfirmScopeState extends State<ExitConfirmScope> {
  bool _sheetOpen = false;

  Future<void> _onBack() async {
    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    if (_sheetOpen) return;
    _sheetOpen = true;
    final exit = await showExitConfirmSheet(context);
    _sheetOpen = false;
    if (exit == true) await SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    if (!PlatformUtils.isAndroid) return widget.child;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _onBack();
      },
      child: widget.child,
    );
  }
}

/// Asks whether to close the app; resolves true when the user confirms.
Future<bool?> showExitConfirmSheet(BuildContext context) {
  return AppBottomSheet.show<bool>(
    context: context,
    showCloseButton: false,
    child: const _ExitConfirmContent(),
  );
}

class _ExitConfirmContent extends StatelessWidget {
  const _ExitConfirmContent();

  static const _accent = Color(0xFFE53935);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(color: _accent.withValues(alpha: 0.12), shape: BoxShape.circle),
          child: Icon(Iconsax.logout, color: _accent, size: 26.r),
        ),
        SizedBox(height: 14.r),
        Text(
          'exit_app_title'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.bold, color: cs.onSurface),
        ),
        SizedBox(height: 8.r),
        Text(
          'exit_app_body'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.r, height: 1.4, color: cs.onSurface.withValues(alpha: 0.65)),
        ),
        SizedBox(height: 22.r),
        Row(
          children: [
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.r),
                  backgroundColor: cs.onSurface.withValues(alpha: 0.06),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text(
                  'exit_app_stay'.tr(),
                  style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.75)),
                ),
              ),
            ),
            SizedBox(width: 12.r),
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.r),
                  backgroundColor: _accent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                ),
                child: Text(
                  'exit_app_confirm'.tr(),
                  style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w700, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
