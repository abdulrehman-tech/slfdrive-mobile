import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../location_picker_provider/location_picker_provider.dart';
import 'location_picker_bottom_sheet.dart';
import 'location_picker_glass_circle.dart';
import 'location_picker_map.dart';
import 'location_picker_search_bar.dart';

/// Mobile: full-bleed map, top search bar, FAB, and blurred bottom sheet.
class LocationPickerMobileLayout extends StatelessWidget {
  final bool isDark;
  final VoidCallback onConfirm;

  const LocationPickerMobileLayout({super.key, required this.isDark, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.read<LocationPickerProvider>();

    return Stack(
      children: [
        const LocationPickerMap(),
        IgnorePointer(
          child: Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 30.r),
              child: Icon(Iconsax.location_copy, size: 38.r, color: cs.primary),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: EdgeInsets.all(14.r),
              child: Row(
                children: [
                  LocationPickerGlassCircle(
                    icon: CupertinoIcons.back,
                    isDark: isDark,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  SizedBox(width: 10.r),
                  Expanded(child: LocationPickerSearchBar(isDark: isDark)),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 200.r,
          right: 16.r,
          child: LocationPickerGlassCircle(
            icon: Iconsax.gps_copy,
            isDark: isDark,
            color: cs.primary,
            onTap: provider.goToMyLocation,
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: LocationPickerBottomSheet(isDark: isDark, onConfirm: onConfirm),
        ),
      ],
    );
  }
}
