import 'package:flutter/material.dart';

import 'push_permission_sheet.dart';

/// Wraps a screen and offers the push pre-permission sheet once, on the first
/// frame after it mounts.
///
/// Exists so the trigger can sit at a moment of genuine intent without turning
/// otherwise-stateless screens into StatefulWidgets. Everything that decides
/// whether the sheet is actually appropriate — already granted, already refused
/// at OS level, shown too recently, shown too often — lives in
/// [maybePrimePushPermission]; this only picks the moment.
class PushPermissionPrimer extends StatefulWidget {
  final Widget child;

  /// Tunes the copy (trip requests vs booking updates) and nothing else.
  final bool isDriver;

  const PushPermissionPrimer({
    super.key,
    required this.child,
    this.isDriver = false,
  });

  @override
  State<PushPermissionPrimer> createState() => _PushPermissionPrimerState();
}

class _PushPermissionPrimerState extends State<PushPermissionPrimer> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      maybePrimePushPermission(context, isDriver: widget.isDriver);
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
