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

    final double width = desktop ? 60.r : 52.r;
    final double height = desktop ? 80.r : 68.r;
    final double fontSize = desktop ? 26 : 22.r;
    final double borderRadius = desktop ? 12 : 12.r;
    final double textHeight = desktop ? 1.0 : 2.0;

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
          fillColor: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
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
