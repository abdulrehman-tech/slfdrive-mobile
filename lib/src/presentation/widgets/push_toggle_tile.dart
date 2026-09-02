import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../core/di/injection_container.dart';
import '../../core/services/push_messaging_service.dart';
import '../screens/common/profile/widgets/profile_toggle_tile.dart';
import 'push_permission_sheet.dart';

/// Push-notification switch for the profile screens.
///
/// The displayed state is the **effective** one, not just the stored preference:
/// if the OS has notifications blocked, the switch reads off no matter what is
/// in storage. A toggle that claims "on" while the system silently drops every
/// message is the single most reliable way to generate support tickets.
///
/// Turning it on from a blocked state routes through [showPushBlockedSheet] to
/// system Settings, because the OS prompt will not reappear once refused.
class PushToggleTile extends StatefulWidget {
  final bool isDark;
  final bool isDriver;

  const PushToggleTile({
    super.key,
    required this.isDark,
    this.isDriver = false,
  });

  @override
  State<PushToggleTile> createState() => _PushToggleTileState();
}

class _PushToggleTileState extends State<PushToggleTile>
    with WidgetsBindingObserver {
  final PushMessagingService _push = getIt<PushMessagingService>();

  bool _enabled = false;
  bool _busy = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refresh();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // The user may have just come back from system Settings.
    if (state == AppLifecycleState.resumed) _refresh();
  }

  Future<void> _refresh() async {
    final status = await _push.currentStatus();
    final prefers = await _push.isEnabled();
    if (!mounted) return;
    setState(() {
      _enabled = prefers &&
          (status == PushAuthStatus.authorized ||
              status == PushAuthStatus.provisional);
      _busy = false;
    });
  }

  Future<void> _onChanged(bool value) async {
    if (_busy) return;
    setState(() => _busy = true);

    if (!value) {
      await _push.setEnabled(false);
      await _refresh();
      return;
    }

    final status = await _push.currentStatus();
    switch (status) {
      case PushAuthStatus.authorized:
      case PushAuthStatus.provisional:
        await _push.setEnabled(true);
      case PushAuthStatus.notDetermined:
        // Still has its one shot at the OS prompt — show the rationale first.
        if (mounted) {
          await maybePrimePushPermission(context, isDriver: widget.isDriver);
        }
      case PushAuthStatus.denied:
        if (mounted) await showPushBlockedSheet(context);
      case PushAuthStatus.unsupported:
        break;
    }
    await _refresh();
  }

  @override
  Widget build(BuildContext context) {
    return ProfileToggleTile(
      icon: Iconsax.notification_copy,
      iconColor: const Color(0xFFFF6D00),
      title: 'push_settings_title'.tr(),
      value: _enabled,
      onChanged: _busy ? (_) {} : _onChanged,
      isDark: widget.isDark,
    );
  }
}
