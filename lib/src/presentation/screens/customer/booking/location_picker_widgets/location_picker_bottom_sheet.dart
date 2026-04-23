import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'location_picker_confirm_button.dart';
import 'location_picker_label_field.dart';
import 'location_picker_selected_address_block.dart';

/// Mobile blurred bottom sheet composing address summary, label input, and CTA.
class LocationPickerBottomSheet extends StatelessWidget {
  final bool isDark;
  final VoidCallback onConfirm;

  const LocationPickerBottomSheet({super.key, required this.isDark, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ClipRRect(
      borderRadius: BorderRadius.only(topLeft: Radius.circular(28.r), topRight: Radius.circular(28.r)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(20.r, 16.r, 20.r, 16.r + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F0F18).withValues(alpha: 0.96) : Colors.white.withValues(alpha: 0.96),
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.r,
                height: 4.r,
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 14.r),
              LocationPickerSelectedAddressBlock(isDark: isDark),
              SizedBox(height: 12.r),
              LocationPickerLabelField(isDark: isDark),
              SizedBox(height: 14.r),
              LocationPickerConfirmButton(onTap: onConfirm),
            ],
          ),
        ),
      ),
    );
  }
}
