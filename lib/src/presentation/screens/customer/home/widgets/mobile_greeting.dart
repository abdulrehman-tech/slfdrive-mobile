import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MobileGreeting extends StatelessWidget {
  final Animation<double> fade;
  const MobileGreeting({super.key, required this.fade});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FadeTransition(
      opacity: fade,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.r, 14.r, 20.r, 10.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'home_greeting'.tr(),
              style: TextStyle(
                fontSize: 13.r,
                fontWeight: FontWeight.w500,
                color: cs.onSurface.withValues(alpha: 0.55),
                letterSpacing: 0.2,
              ),
            ),
            SizedBox(height: 4.r),
            Text(
              'home_headline'.tr(),
              style: TextStyle(
                fontSize: 22.r,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
                height: 1.2,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
