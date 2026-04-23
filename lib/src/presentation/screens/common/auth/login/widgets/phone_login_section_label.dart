import 'package:flutter/material.dart';

class PhoneLoginSectionLabel extends StatelessWidget {
  final String text;
  final bool isDark;
  final double fontSize;

  const PhoneLoginSectionLabel({
    super.key,
    required this.text,
    required this.isDark,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white : const Color(0xFF3D3D3D),
      ),
    );
  }
}
