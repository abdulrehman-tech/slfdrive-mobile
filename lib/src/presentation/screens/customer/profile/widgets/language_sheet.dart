import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../widgets/bottom_sheets/app_bottom_sheet.dart';
import '../data/profile_mock_data.dart';

void showProfileLanguageSheet(BuildContext context, {required bool isDark}) {
  final cs = Theme.of(context).colorScheme;
  AppBottomSheet.show(
    context: context,
    title: 'profile_language'.tr(),
    child: Padding(
      padding: EdgeInsets.only(bottom: 12.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: kProfileLanguages.map((l) {
          final active = context.locale.languageCode == l.locale.languageCode;
          return GestureDetector(
            onTap: () {
              context.setLocale(l.locale);
              Navigator.pop(context);
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 8.r),
              padding: EdgeInsets.all(14.r),
              decoration: BoxDecoration(
                color: active
                    ? cs.primary.withValues(alpha: isDark ? 0.18 : 0.1)
                    : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: active
                      ? cs.primary.withValues(alpha: 0.3)
                      : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04)),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: active ? cs.primary : cs.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(11.r),
                    ),
                    child: Center(
                      child: Text(
                        l.code.toUpperCase(),
                        style: TextStyle(
                          fontSize: 12.r,
                          fontWeight: FontWeight.w800,
                          color: active ? Colors.white : cs.primary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.r),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l.name,
                          style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                        ),
                        SizedBox(height: 2.r),
                        Text(
                          l.nativeName,
                          style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ),
                  if (active) Icon(Iconsax.tick_circle_copy, color: cs.primary, size: 19.r),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    ),
  );
}
