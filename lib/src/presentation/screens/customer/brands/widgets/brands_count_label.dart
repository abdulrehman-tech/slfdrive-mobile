import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class BrandsCountLabel extends StatelessWidget {
  final int count;
  final ColorScheme cs;
  final double fontSize;

  const BrandsCountLabel({
    super.key,
    required this.count,
    required this.cs,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      '$count ${'brands_count'.tr()}',
      style: TextStyle(
        fontSize: fontSize,
        color: cs.onSurface.withValues(alpha: 0.5),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
