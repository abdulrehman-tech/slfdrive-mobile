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

  static const _savedPickups = <(IconData, String, String)>[
    (Iconsax.house_2, 'Home', 'Al Khuwair, Muscat'),
    (Iconsax.briefcase, 'Work', 'Ruwi High Street, Muscat'),
    (Iconsax.airplane, 'Airport', 'Muscat International Airport'),
  ];

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
          // Saved addresses quick picker
          Text(
            'booking_delivery_saved'.tr(),
            style: TextStyle(
              fontSize: 11.r,
              fontWeight: FontWeight.w700,
              color: cs.onSurface.withValues(alpha: 0.55),
              letterSpacing: 0.2,
            ),
          ),
          SizedBox(height: 8.r),
          Wrap(
            spacing: 8.r,
            runSpacing: 8.r,
            children: _savedPickups
                .map((e) => GestureDetector(
                      onTap: () => data.setDeliveryLocation(
                        BookingLocation(
                          latitude: 23.5880,
                          longitude: 58.3829,
                          address: e.$3,
                          label: e.$2,
                        ),
                      ),
                      child: Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 8.r),
                        decoration: BoxDecoration(
                          color: isDark
                              ? Colors.white.withValues(alpha: 0.05)
                              : Colors.black.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(11.r),
                          border: Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.08)
                                : Colors.black.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(e.$1, size: 14.r, color: cs.primary),
                            SizedBox(width: 6.r),
                            Text(
                              e.$2,
                              style: TextStyle(
                                fontSize: 11.r,
                                fontWeight: FontWeight.w600,
                                color: cs.onSurface.withValues(alpha: 0.75),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ))
                .toList(),
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
