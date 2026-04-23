import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'notification_btn.dart';
import 'theme_toggle_btn.dart';

class MobileAppBar extends StatelessWidget {
  final bool isDark;
  const MobileAppBar({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SliverAppBar(
      pinned: true,
      floating: false,
      expandedHeight: 0,
      toolbarHeight: 64.r,
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.black.withValues(alpha: 0.55) : Colors.white.withValues(alpha: 0.72),
              border: Border(
                bottom: BorderSide(
                  color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.07),
                  width: 0.8,
                ),
              ),
            ),
          ),
        ),
      ),
      title: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.r),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => context.push('/profile/addresses'),
                child: Row(
                  children: [
                    Container(
                      width: 32.r,
                      height: 32.r,
                      decoration: BoxDecoration(
                        color: cs.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(Iconsax.location_copy, color: cs.primary, size: 16.r),
                    ),
                    SizedBox(width: 8.r),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'home_location_label'.tr(),
                            style: TextStyle(
                              fontSize: 10.r,
                              color: cs.onSurface.withValues(alpha: 0.5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'home_location'.tr(),
                                style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                              ),
                              SizedBox(width: 3.r),
                              Icon(CupertinoIcons.chevron_down, size: 12.r, color: cs.primary),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            ThemeToggleBtn(isDark: isDark),
            SizedBox(width: 8.r),
            NotificationBtn(cs: cs, isDark: isDark),
          ],
        ),
      ),
    );
  }
}
