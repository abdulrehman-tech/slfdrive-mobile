import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../models/booking_data.dart';
import '../../widgets/booking_glass_card.dart';

/// Self-pickup: the customer collects the vehicle from where it is. That point
/// is fixed by the provider, so it's shown read-only (no map / no editing).
class PickupSelfSection extends StatelessWidget {
  final BookingData data;
  final bool isDark;

  const PickupSelfSection({super.key, required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final car = data.car;
    final hasLocation = car?.hasLocation == true;
    final locationName = (car?.locationName ?? '').trim();

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
          Container(
            padding: EdgeInsets.all(12.r),
            decoration: BoxDecoration(
              color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44.r,
                  height: 44.r,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Iconsax.location_copy, color: cs.primary, size: 20.r),
                ),
                SizedBox(width: 12.r),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'booking_pickup_owner_default'.tr(),
                        style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 2.r),
                      Text(
                        hasLocation
                            ? (locationName.isNotEmpty ? locationName : 'booking_pickup_provider_location'.tr())
                            : 'booking_pickup_location_pending'.tr(),
                        style: TextStyle(
                          fontSize: 11.r,
                          color: cs.onSurface.withValues(alpha: 0.55),
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Read-only lock indicator — the pickup point can't be changed.
                Icon(Iconsax.lock_1_copy, size: 16.r, color: cs.onSurface.withValues(alpha: 0.3)),
              ],
            ),
          ),
          SizedBox(height: 8.r),
          Text(
            'booking_pickup_self_note'.tr(),
            style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.5), height: 1.4),
          ),
        ],
      ),
    );
  }
}
