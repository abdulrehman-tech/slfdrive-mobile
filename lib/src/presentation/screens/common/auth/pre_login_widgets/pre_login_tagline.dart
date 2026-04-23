import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

/// Title + subtitle block ("Drive. Ride. Connect." / subtitle copy).
/// Mobile centers the title; desktop left-aligns and scales up.
class PreLoginTagline extends StatelessWidget {
  final double titleSize;
  final double subtitleSize;
  final double titleHeight;
  final double titleLetterSpacing;
  final double spacing;
  final TextAlign titleAlign;
  final CrossAxisAlignment crossAxisAlignment;
  final Color subtitleColor;

  const PreLoginTagline({
    super.key,
    required this.titleSize,
    required this.subtitleSize,
    required this.titleHeight,
    required this.titleLetterSpacing,
    required this.spacing,
    required this.titleAlign,
    required this.crossAxisAlignment,
    required this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Text(
          'pre_login_title'.tr(),
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            height: titleHeight,
            letterSpacing: titleLetterSpacing,
          ),
          textAlign: titleAlign,
        ),
        SizedBox(height: spacing),
        Text(
          'pre_login_subtitle'.tr(),
          style: TextStyle(fontSize: subtitleSize, color: subtitleColor, height: 1.5),
        ),
      ],
    );
  }
}
