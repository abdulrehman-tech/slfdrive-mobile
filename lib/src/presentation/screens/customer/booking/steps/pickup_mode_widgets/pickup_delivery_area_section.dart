import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../../core/models/lookup/location_option.dart';
import '../../../../../widgets/omr_icon.dart';
import '../../models/booking_data.dart';
import '../../widgets/booking_glass_card.dart';

/// Delivery-area picker for the pickup step. Selecting an area resolves the
/// (company, area) delivery fee, shown inline.
class PickupDeliveryAreaSection extends StatelessWidget {
  final BookingData data;
  final bool isDark;
  final List<LocationOption> areas;
  final bool isLoading;
  final String? error;
  final ValueChanged<LocationOption> onSelect;

  const PickupDeliveryAreaSection({
    super.key,
    required this.data,
    required this.isDark,
    required this.areas,
    required this.isLoading,
    required this.error,
    required this.onSelect,
  });

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
            icon: Iconsax.box_copy,
            iconColor: const Color(0xFF4CAF50),
            title: 'booking_delivery_area'.tr(),
            isDark: isDark,
          ),
          SizedBox(height: 12.r),
          if (isLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.r),
              child: Row(
                children: [
                  SizedBox(
                    width: 16.r,
                    height: 16.r,
                    child: const CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 10.r),
                  Text(
                    'booking_delivery_area_loading'.tr(),
                    style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            )
          else if (error != null || areas.isEmpty)
            Text(
              'booking_delivery_area_unavailable'.tr(),
              style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.6)),
            )
          else
            _dropdown(context, cs),
          if (data.deliveryArea != null) ...[
            SizedBox(height: 12.r),
            _feeRow(cs),
          ],
        ],
      ),
    );
  }

  Widget _dropdown(BuildContext context, ColorScheme cs) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          isExpanded: true,
          // Guard against a selected area not in the list (DropdownButton
          // asserts the value matches exactly one item).
          value: areas.any((a) => a.id == data.deliveryArea?.id) ? data.deliveryArea?.id : null,
          hint: Text(
            'booking_delivery_area_hint'.tr(),
            style: TextStyle(fontSize: 13.r, color: cs.onSurface.withValues(alpha: 0.5)),
          ),
          icon: Icon(Iconsax.arrow_down_1_copy, size: 16.r, color: cs.onSurface.withValues(alpha: 0.5)),
          dropdownColor: Theme.of(context).scaffoldBackgroundColor,
          items: areas
              .map((a) => DropdownMenuItem<int>(
                    value: a.id,
                    child: Text(
                      a.cityName != null && a.cityName!.isNotEmpty ? '${a.name}, ${a.cityName}' : a.name,
                      style: TextStyle(fontSize: 13.r, color: cs.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ))
              .toList(),
          onChanged: (id) {
            if (id == null) return;
            final area = areas.firstWhere((a) => a.id == id);
            onSelect(area);
          },
        ),
      ),
    );
  }

  Widget _feeRow(ColorScheme cs) {
    if (data.deliveryFeeLoading) {
      return Row(
        children: [
          SizedBox(width: 14.r, height: 14.r, child: const CircularProgressIndicator(strokeWidth: 2)),
          SizedBox(width: 8.r),
          Text(
            'booking_delivery_fee_checking'.tr(),
            style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.6)),
          ),
        ],
      );
    }
    final fee = data.deliveryFee;
    return Row(
      children: [
        Icon(Iconsax.truck_fast_copy, size: 16.r, color: const Color(0xFF4CAF50)),
        SizedBox(width: 8.r),
        Text(
          'booking_summary_delivery_fee'.tr(),
          style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.7)),
        ),
        const Spacer(),
        if (fee <= 0)
          Text(
            'booking_delivery_free'.tr(),
            style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w800, color: const Color(0xFF4CAF50)),
          )
        else ...[
          OmrIcon(size: 12.r, color: cs.onSurface),
          SizedBox(width: 3.r),
          Text(
            fee.toStringAsFixed(2),
            style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w800, color: cs.onSurface),
          ),
        ],
      ],
    );
  }
}