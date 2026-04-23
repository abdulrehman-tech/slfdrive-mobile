import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../models/booking_data.dart';
import '../../widgets/booking_glass_card.dart';
import 'pickup_location_preview.dart';

class PickupSelfSection extends StatelessWidget {
  final BookingData data;
  final bool isDark;
  final VoidCallback onOpenMap;

  const PickupSelfSection({
    super.key,
    required this.data,
    required this.isDark,
    required this.onOpenMap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return BookingGlassCard(
      isDark: isDark,
      padding: EdgeInsets.all(14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookingSectionHeader(
            icon: Iconsax.location_copy,
            iconColor: const Color(0xFF3D5AFE),
            title: 'booking_pickup_point'.tr(),
            isDark: isDark,
          ),
          SizedBox(height: 12.r),
          PickupLocationPreview(
            location: data.pickupLocation,
            fallbackLabel: 'booking_pickup_owner_default'.tr(),
            fallbackAddress: data.car != null ? '${data.car!.brand} — Muscat, Oman' : 'Muscat, Oman',
            isDark: isDark,
            onTap: onOpenMap,
          ),
          SizedBox(height: 10.r),
          GestureDetector(
            onTap: onOpenMap,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 9.r),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(11.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.map_copy, size: 14.r, color: cs.primary),
                  SizedBox(width: 6.r),
                  Text(
                    'booking_pickup_open_map'.tr(),
                    style: TextStyle(fontSize: 12.r, color: cs.primary, fontWeight: FontWeight.w700),
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
