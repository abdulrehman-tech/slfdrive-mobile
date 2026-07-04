import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../widgets/location_map_preview.dart';
import '../provider/car_detail_provider.dart';
import 'car_glass_card.dart';
import 'section_header.dart';

/// Card showing the car pickup location — a tappable map + resolved place name.
class LocationSection extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;

  const LocationSection({super.key, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CarDetailProvider>();
    final vehicle = provider.vehicle;
    if (vehicle == null) return const SizedBox.shrink();

    final locationLabel = (provider.ar ? vehicle.locationNameAr : vehicle.locationName) ?? vehicle.locationName;
    final hasCoords = vehicle.lat != null && vehicle.lon != null;
    // Nothing to show at all — no name and no coordinates.
    if ((locationLabel == null || locationLabel.isEmpty) && !hasCoords) {
      return const SizedBox.shrink();
    }

    return CarGlassCard(
      isDark: isDark,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeader(
              icon: Iconsax.location,
              accent: const Color(0xFFE91E63),
              title: 'car_detail_location'.tr(),
              isDark: isDark,
              cs: cs,
            ),
            SizedBox(height: 12.r),
            if (hasCoords)
              LocationMapPreview(
                points: [MapPoint(lat: vehicle.lat!, lon: vehicle.lon!)],
                isDark: isDark,
                cs: cs,
                height: 140,
              )
            else
              _placeholder(locationLabel),
          ],
        ),
      ),
    );
  }

  Widget _placeholder(String? label) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: Container(
        height: 140.r,
        width: double.infinity,
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.map, size: 28.r, color: cs.onSurface.withValues(alpha: 0.2)),
            if (label != null && label.isNotEmpty) ...[
              SizedBox(height: 6.r),
              Text(label, style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.4))),
            ],
          ],
        ),
      ),
    );
  }
}
