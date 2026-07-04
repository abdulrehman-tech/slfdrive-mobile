import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../widgets/location_map_preview.dart';
import '../models/booking_detail.dart';
import 'glass_card.dart';
import 'section_header.dart';

class BookingLocationMapCard extends StatelessWidget {
  final BookingDetail booking;
  final bool isDark;
  final ColorScheme cs;

  const BookingLocationMapCard({
    super.key,
    required this.booking,
    required this.isDark,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    final points = <MapPoint>[
      if (booking.hasPickupCoords)
        MapPoint(
          lat: booking.pickupLat!,
          lon: booking.pickupLon!,
          label: 'booking_summary_pickup_at'.tr(),
          color: const Color(0xFFE91E63),
          markerHue: BitmapDescriptor.hueRose,
        ),
      if (booking.hasDropoffCoords)
        MapPoint(
          lat: booking.dropoffLat!,
          lon: booking.dropoffLon!,
          label: 'booking_summary_delivery_to'.tr(),
          color: const Color(0xFF2196F3),
          markerHue: BitmapDescriptor.hueAzure,
        ),
    ];

    // No coordinates → hide the whole card (both the mobile and desktop layouts
    // mount this widget, so hiding here keeps them consistent) instead of
    // showing an empty map placeholder.
    if (points.isEmpty) return const SizedBox.shrink();

    return BookingGlassCard(
      isDark: isDark,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            BookingSectionHeader(
              cs: cs,
              icon: Iconsax.location_copy,
              color: const Color(0xFFE91E63),
              title: 'booking_detail_logistics'.tr(),
              isDark: isDark,
            ),
            SizedBox(height: 12.r),
            LocationMapPreview(points: points, isDark: isDark, cs: cs),
          ],
        ),
      ),
    );
  }
}
