import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../location_picker_provider/location_picker_provider.dart';
import 'location_picker_confirm_button.dart';
import 'location_picker_glass_circle.dart';
import 'location_picker_label_field.dart';
import 'location_picker_map.dart';
import 'location_picker_search_bar.dart';
import 'location_picker_selected_address_block.dart';

/// Desktop: fixed-width side panel with controls + expanded map area.
class LocationPickerDesktopLayout extends StatelessWidget {
  final bool isDark;
  final bool forDelivery;
  final VoidCallback onConfirm;

  const LocationPickerDesktopLayout({
    super.key,
    required this.isDark,
    required this.forDelivery,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.read<LocationPickerProvider>();

    return Row(
      children: [
        Container(
          width: 360.r,
          padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 24.r),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF111118) : Colors.white,
            border: Border(
              right: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(CupertinoIcons.back, size: 17.r, color: cs.onSurface),
                    ),
                  ),
                  SizedBox(width: 12.r),
                  Text(
                    forDelivery ? 'booking_delivery_where'.tr() : 'booking_pickup_point'.tr(),
                    style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                  ),
                ],
              ),
              SizedBox(height: 18.r),
              LocationPickerSearchBar(isDark: isDark),
              SizedBox(height: 12.r),
              LocationPickerLabelField(isDark: isDark),
              SizedBox(height: 18.r),
              LocationPickerSelectedAddressBlock(isDark: isDark),
              const Spacer(),
              LocationPickerConfirmButton(onTap: onConfirm),
            ],
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              const LocationPickerMap(),
              IgnorePointer(
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 30.r),
                    child: Icon(Iconsax.location_copy, size: 44.r, color: cs.primary),
                  ),
                ),
              ),
              Positioned(
                bottom: 24.r,
                right: 24.r,
                child: LocationPickerGlassCircle(
                  icon: Iconsax.gps_copy,
                  isDark: isDark,
                  color: cs.primary,
                  onTap: provider.goToMyLocation,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
