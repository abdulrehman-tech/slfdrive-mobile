import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../location_picker_provider/location_picker_provider.dart';

/// Optional label input (e.g. "Home", "Office") associated with the selected
/// location.
class LocationPickerLabelField extends StatelessWidget {
  final bool isDark;

  const LocationPickerLabelField({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final provider = context.read<LocationPickerProvider>();

    return TextField(
      controller: provider.labelController,
      style: TextStyle(fontSize: 13.r, color: cs.onSurface),
      decoration: InputDecoration(
        labelText: 'booking_location_label'.tr(),
        labelStyle: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.55)),
        hintText: 'booking_location_label_hint'.tr(),
        hintStyle: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.35)),
        filled: true,
        fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
        contentPadding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 10.r),
      ),
    );
  }
}
