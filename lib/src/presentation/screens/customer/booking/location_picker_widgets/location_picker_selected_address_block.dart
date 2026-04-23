import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../location_picker_provider/location_picker_provider.dart';

/// Highlighted summary of the currently selected address + coordinates.
class LocationPickerSelectedAddressBlock extends StatelessWidget {
  final bool isDark;

  const LocationPickerSelectedAddressBlock({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<LocationPickerProvider>();

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: isDark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: cs.primary.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Iconsax.location_copy, color: cs.primary, size: 16.r),
              SizedBox(width: 6.r),
              Text(
                'booking_location_selected'.tr(),
                style: TextStyle(fontSize: 11.r, color: cs.primary, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          SizedBox(height: 8.r),
          Text(
            provider.address,
            style: TextStyle(fontSize: 13.r, color: cs.onSurface, fontWeight: FontWeight.w600, height: 1.4),
          ),
          SizedBox(height: 6.r),
          Text(
            '${provider.center.latitude.toStringAsFixed(5)}, ${provider.center.longitude.toStringAsFixed(5)}',
            style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.45), fontFamily: 'monospace'),
          ),
        ],
      ),
    );
  }
}
