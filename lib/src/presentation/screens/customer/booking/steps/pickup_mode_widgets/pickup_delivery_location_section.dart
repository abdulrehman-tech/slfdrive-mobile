import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../models/booking_data.dart';
import '../../widgets/booking_glass_card.dart';
import 'pickup_location_preview.dart';

class PickupDeliveryLocationSection extends StatelessWidget {
  final BookingData data;
  final bool isDark;
  final VoidCallback onOpenMap;

  const PickupDeliveryLocationSection({
    super.key,
    required this.data,
    required this.isDark,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    return BookingGlassCard(
      isDark: isDark,
      padding: EdgeInsets.all(14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookingSectionHeader(
            icon: Iconsax.location_copy,
            iconColor: const Color(0xFFE91E63),
            title: 'booking_delivery_where'.tr(),
            isDark: isDark,
          ),
          SizedBox(height: 12.r),
          PickupLocationPreview(
            location: data.deliveryLocation,
            fallbackLabel: 'booking_delivery_placeholder'.tr(),
            fallbackAddress: 'booking_delivery_placeholder_desc'.tr(),
            isDark: isDark,
            onTap: onOpenMap,
          ),
          SizedBox(height: 12.r),
          GestureDetector(
            onTap: onOpenMap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 9.r),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF0C2485), Color(0xFF677EF0)]),
                borderRadius: BorderRadius.circular(11.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.map_copy, size: 14.r, color: Colors.white),
                  SizedBox(width: 6.r),
                  Text(
                    'booking_delivery_pick_on_map'.tr(),
                    style: TextStyle(fontSize: 12.r, color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
