import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../models/booking_data.dart';
import 'pickup_mode_toggle.dart';

class PickupModeToggleRow extends StatelessWidget {
  final BookingData data;
  final bool isDark;

  const PickupModeToggleRow({
    super.key,
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: PickupModeToggle(
            isActive: data.pickupMode == PickupMode.selfPickup,
            icon: Iconsax.shop_copy,
            title: 'booking_pickup_self'.tr(),
            subtitle: 'booking_pickup_self_desc'.tr(),
            color: const Color(0xFF3D5AFE),
            isDark: isDark,
            onTap: () => data.setPickupMode(PickupMode.selfPickup),
          ),
        ),
        SizedBox(width: 10.r),
        Expanded(
          child: PickupModeToggle(
            isActive: data.pickupMode == PickupMode.delivery,
            icon: Iconsax.truck_fast_copy,
            title: 'booking_pickup_delivery'.tr(),
            subtitle: 'booking_pickup_delivery_desc'.tr(),
            color: const Color(0xFFE91E63),
            isDark: isDark,
            onTap: () => data.setPickupMode(PickupMode.delivery),
          ),
        ),
      ],
    );
  }
}
