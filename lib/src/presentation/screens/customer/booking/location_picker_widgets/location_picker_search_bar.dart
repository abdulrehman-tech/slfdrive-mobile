import 'dart:ui';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../location_picker_provider/location_picker_provider.dart';

/// Glass search bar that updates the provider's typed address and surfaces the
/// reverse-geocoding loading indicator.
class LocationPickerSearchBar extends StatelessWidget {
  final bool isDark;

  const LocationPickerSearchBar({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<LocationPickerProvider>();

    return ClipRRect(
      borderRadius: BorderRadius.circular(14.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.r),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A28).withValues(alpha: 0.92) : Colors.white.withValues(alpha: 0.95),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.08),
                blurRadius: 14.r,
                offset: Offset(0, 4.r),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(Iconsax.search_normal_copy, size: 18.r, color: cs.primary),
              SizedBox(width: 10.r),
              Expanded(
                child: TextField(
                  controller: provider.addressController,
                  onChanged: provider.onAddressChanged,
                  style: TextStyle(fontSize: 13.r, color: cs.onSurface),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    hintText: 'booking_location_search_hint'.tr(),
                    hintStyle: TextStyle(fontSize: 13.r, color: cs.onSurface.withValues(alpha: 0.4)),
                    contentPadding: EdgeInsets.symmetric(vertical: 14.r),
                  ),
                ),
              ),
              if (provider.resolving)
                SizedBox(width: 14.r, height: 14.r, child: const CircularProgressIndicator(strokeWidth: 1.8)),
            ],
          ),
        ),
      ),
    );
  }
}
