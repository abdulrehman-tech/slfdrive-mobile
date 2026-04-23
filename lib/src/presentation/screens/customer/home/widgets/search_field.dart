import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Glassy search field used by the desktop top bar.
/// Mobile uses [CompactSearchBar] instead.
class SearchField extends StatelessWidget {
  final double? width;
  final bool isDark;

  const SearchField({super.key, this.width, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final child = ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          height: 52.r,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.12) : Colors.white.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.18) : Colors.white.withValues(alpha: 0.9),
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              SizedBox(width: 14.r),
              Icon(Iconsax.search_normal_copy, color: isDark ? Colors.white54 : const Color(0xFFAAAAAA), size: 20.r),
              SizedBox(width: 10.r),
              Expanded(
                child: GestureDetector(
                  onTap: () => context.pushNamed('search'),
                  child: AbsorbPointer(
                    child: Text(
                      'home_search_hint'.tr(),
                      style: TextStyle(color: isDark ? Colors.white38 : const Color(0xFFAAAAAA), fontSize: 14.r),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.pushNamed('search'),
                child: Container(
                  margin: EdgeInsets.all(6.r),
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF0C2485), Color(0xFF677EF0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(11.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0C2485).withValues(alpha: 0.35),
                        blurRadius: 10.r,
                        offset: Offset(0, 3.r),
                      ),
                    ],
                  ),
                  child: Icon(Iconsax.setting_4_copy, color: Colors.white, size: 18.r),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return width != null ? SizedBox(width: width, child: child) : child;
  }
}
