import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../../../constants/color_constants.dart';
import '../provider/otp_provider.dart';

class OtpInputCell extends StatelessWidget {
  final int index;
  final bool isDark;
  final bool desktop;

  const OtpInputCell({super.key, required this.index, required this.isDark, this.desktop = false});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<OtpProvider>();
    final controller = provider.controllers[index];
    final focusNode = provider.focusNodes[index];
    final isFilled = controller.text.isNotEmpty;

    final bool isFocused = focusNode.hasFocus;
    final double width = desktop ? 56.r : 46.r;
    final double height = desktop ? 84.r : 62.r;
    final double fontSize = desktop ? 28 : 24.r;
    final double borderRadius = desktop ? 16 : 14.r;
    final double textHeight = desktop ? 1.0 : 1.0;

    final Color idleFill = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);
    final Color activeFill = secondaryColor.withValues(alpha: isDark ? 0.18 : 0.10);

    return SizedBox(
      width: width,
      height: height,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        maxLength: 1,
        cursorColor: secondaryColor,
        showCursor: true,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : const Color(0xFF3D3D3D),
          height: textHeight,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: (isFilled || isFocused) ? activeFill : idleFill,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: isFilled ? secondaryColor : (isDark ? Colors.white24 : const Color(0xFFE0E0E0)),
              width: isFilled ? 2 : 1.5,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: secondaryColor, width: 2),
          ),
        ),
        onChanged: (value) => context.read<OtpProvider>().handleInput(index, value),
      ),
    );
  }
}
