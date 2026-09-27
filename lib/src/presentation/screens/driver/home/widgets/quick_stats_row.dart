import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../shell/driver_shell_provider.dart';
import '../../shell/widgets/driver_stat_tile.dart';

class QuickStatsRow extends StatelessWidget {
  final bool isDark;

  const QuickStatsRow({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverShellProvider>();

    return Padding(
      padding: EdgeInsets.all(20.r),
      // IntrinsicHeight + stretch: equal-height tiles even when one label wraps.
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: DriverStatTile(
                icon: Iconsax.car,
                value: provider.totalTrips.toString(),
                label: 'driver_trips'.tr(),
                color: const Color(0xFF4D63DD),
                isDark: isDark,
              ),
            ),
            SizedBox(width: 12.r),
            Expanded(
              child: DriverStatTile(
                icon: Iconsax.star_1,
                value: provider.ratingLabel,
                label: 'driver_rating'.tr(),
                color: const Color(0xFFFFA000),
                isDark: isDark,
              ),
            ),
            SizedBox(width: 12.r),
            Expanded(
              child: DriverStatTile(
                icon: Iconsax.tick_circle,
                value: provider.completionLabel,
                label: 'driver_completion'.tr(),
                color: const Color(0xFF4CAF50),
                isDark: isDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
