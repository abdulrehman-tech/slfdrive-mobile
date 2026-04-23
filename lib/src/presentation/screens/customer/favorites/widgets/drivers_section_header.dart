import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

class DriversSectionHeader extends StatelessWidget {
  final bool isDark;

  const DriversSectionHeader({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Container(
          width: 28.r,
          height: 28.r,
          decoration: BoxDecoration(
            color: const Color(0xFF00BCD4).withValues(alpha: isDark ? 0.15 : 0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            Iconsax.profile_2user_copy,
            color: const Color(0xFF00BCD4),
            size: 14.r,
          ),
        ),
        SizedBox(width: 8.r),
        Text(
          'favorites_filter_drivers'.tr(),
          style: TextStyle(
            fontSize: 14.r,
            fontWeight: FontWeight.w700,
            color: cs.onSurface,
          ),
        ),
      ],
    );
  }
}
