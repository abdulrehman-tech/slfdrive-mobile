import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class CompactSearchBar extends StatelessWidget {
  final bool isDark;
  const CompactSearchBar({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.fromLTRB(20.r, 4.r, 20.r, 6.r),
      child: GestureDetector(
        onTap: () => context.pushNamed('search'),
        child: Container(
          height: 46.r,
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF4F5F7),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              SizedBox(width: 14.r),
              Icon(
                Iconsax.search_normal_copy,
                color: cs.onSurface.withValues(alpha: 0.5),
                size: 18.r,
              ),
              SizedBox(width: 10.r),
              Expanded(
                child: Text(
                  'home_search_hint'.tr(),
                  style: TextStyle(
                    color: cs.onSurface.withValues(alpha: 0.5),
                    fontSize: 13.r,
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                margin: EdgeInsets.all(5.r),
                width: 36.r,
                height: 36.r,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF0C2485), Color(0xFF3D5AFE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(Iconsax.setting_4_copy, color: Colors.white, size: 16.r),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
