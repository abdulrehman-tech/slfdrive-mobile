import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../widgets/omr_icon.dart';
import '../../models/booking_data.dart';
import '../../widgets/booking_glass_card.dart';

class SummaryExtrasCard extends StatelessWidget {
  final BookingData data;
  final bool isDark;
  const SummaryExtrasCard({super.key, required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final d = data;

    return BookingGlassCard(
      isDark: isDark,
      padding: EdgeInsets.all(14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookingSectionHeader(
            icon: Iconsax.additem_copy,
            iconColor: const Color(0xFF7C4DFF),
            title: 'booking_summary_extras'.tr(),
            isDark: isDark,
          ),
          SizedBox(height: 10.r),
          ...d.selectedExtras.map((id) {
            final extra = kBookingExtras.firstWhere((e) => e.id == id);
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 4.r),
              child: Row(
                children: [
                  Icon(Iconsax.tick_circle_copy, size: 13.r, color: const Color(0xFF4CAF50)),
                  SizedBox(width: 6.r),
                  Expanded(
                    child: Text(
                      extra.titleKey.tr(),
                      style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.75)),
                    ),
                  ),
                  Row(
                    children: [
                      OmrIcon(size: 10.r, color: cs.onSurface.withValues(alpha: 0.55)),
                      SizedBox(width: 2.r),
                      Text(
                        '${extra.pricePerDay.toStringAsFixed(0)}/d',
                        style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}
