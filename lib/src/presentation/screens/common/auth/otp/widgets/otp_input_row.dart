import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../provider/otp_provider.dart';
import 'otp_input_cell.dart';

class OtpInputRow extends StatelessWidget {
  final bool isDark;
  final bool desktop;

  const OtpInputRow({super.key, required this.isDark, this.desktop = false});

  @override
  Widget build(BuildContext context) {
    final length = context.read<OtpProvider>().length;
    // Always LTR so boxes 0→5 are left→right in all locales.
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(
          length,
          (index) => OtpInputCell(index: index, isDark: isDark, desktop: desktop),
        ),
      ),
    );
  }
}
