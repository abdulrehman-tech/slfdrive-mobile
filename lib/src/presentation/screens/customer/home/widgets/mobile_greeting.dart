import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../providers/auth_provider.dart';

class MobileGreeting extends StatelessWidget {
  final Animation<double> fade;
  const MobileGreeting({super.key, required this.fade});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final auth = context.watch<AuthProvider>();

    // First name only; falls back to the localized guest label.
    final full = auth.displayName?.trim() ?? '';
    final name = full.isNotEmpty ? full.split(RegExp(r'\s+')).first : 'home_guest_name'.tr();

    final hour = DateTime.now().hour;
    final greetingKey = hour < 12
        ? 'home_greeting_morning'
        : (hour < 17 ? 'home_greeting_afternoon' : 'home_greeting_evening');

    return FadeTransition(
      opacity: fade,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.r, 14.r, 20.r, 10.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              greetingKey.tr(namedArgs: {'name': name}),
              style: TextStyle(
                fontSize: 13.r,
                fontWeight: FontWeight.w500,
                color: cs.onSurface.withValues(alpha: 0.55),
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
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
