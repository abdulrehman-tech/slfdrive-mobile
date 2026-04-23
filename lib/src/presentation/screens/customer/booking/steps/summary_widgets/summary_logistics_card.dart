import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../models/booking_data.dart';
import '../../widgets/booking_glass_card.dart';
import 'summary_info_row.dart';

class SummaryLogisticsCard extends StatelessWidget {
  final BookingData data;
  final bool isDark;
  const SummaryLogisticsCard({super.key, required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final d = data;
    return BookingGlassCard(
      isDark: isDark,
      padding: EdgeInsets.all(14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookingSectionHeader(
            icon: Iconsax.location_copy,
            iconColor: const Color(0xFFE91E63),
            title: 'booking_summary_logistics'.tr(),
            isDark: isDark,
          ),
          SizedBox(height: 10.r),
          SummaryInfoRow(
            label: 'booking_summary_mode'.tr(),
            value: d.pickupMode == PickupMode.selfPickup
                ? 'booking_pickup_self'.tr()
                : 'booking_pickup_delivery'.tr(),
          ),
          SummaryInfoRow(
            label: d.pickupMode == PickupMode.selfPickup
                ? 'booking_summary_pickup_at'.tr()
                : 'booking_summary_delivery_to'.tr(),
            value: (d.pickupMode == PickupMode.selfPickup
                ? (d.pickupLocation?.address ?? 'Owner location')
                : (d.deliveryLocation?.address ?? 'Set address')),
            multi: true,
          ),
          if (d.deliveryNotes.isNotEmpty && d.pickupMode == PickupMode.delivery)
            SummaryInfoRow(
              label: 'booking_summary_notes'.tr(),
              value: d.deliveryNotes,
              multi: true,
            ),
        ],
      ),
    );
  }
}
