import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class OtpBackButton extends StatelessWidget {
  final bool isDark;
  final bool desktop;

  const OtpBackButton({super.key, required this.isDark, this.desktop = false});

  @override
  Widget build(BuildContext context) {
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;
    final double size = desktop ? 24.r : 20.r;
    final IconData icon = desktop
        ? (isRtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new)
        : Icons.arrow_back_ios_new;

    return IconButton(
      onPressed: () => context.pop(),
      icon: Icon(icon, color: isDark ? Colors.white : const Color(0xFF3D3D3D), size: size),
    );
  }
}
