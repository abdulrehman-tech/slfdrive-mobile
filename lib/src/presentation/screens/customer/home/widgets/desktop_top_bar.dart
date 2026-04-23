import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'notification_btn.dart';
import 'search_field.dart';
import 'theme_toggle_btn.dart';

class DesktopTopBar extends StatelessWidget {
  final bool isDark;
  const DesktopTopBar({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'home_greeting'.tr(),
                style: TextStyle(
                  fontSize: 13.r,
                  color: cs.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 2.r),
              Text(
                'home_headline'.tr(),
                style: TextStyle(fontSize: 24.r, fontWeight: FontWeight.bold, color: cs.onSurface, height: 1.2),
              ),
            ],
          ),
        ),
        SearchField(width: 320.r, isDark: isDark),
        SizedBox(width: 16.r),
        ThemeToggleBtn(isDark: isDark),
        SizedBox(width: 12.r),
        NotificationBtn(cs: cs, isDark: isDark),
      ],
    );
  }
}
