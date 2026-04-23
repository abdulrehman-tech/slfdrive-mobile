import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class NotifAgeHeader extends StatelessWidget {
  final String labelKey;
  final ColorScheme cs;
  final EdgeInsetsGeometry padding;

  const NotifAgeHeader({
    super.key,
    required this.labelKey,
    required this.cs,
    required this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        labelKey.tr(),
        style: TextStyle(
          fontSize: 13.r,
          fontWeight: FontWeight.w700,
          color: cs.onSurface.withValues(alpha: 0.55),
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}
