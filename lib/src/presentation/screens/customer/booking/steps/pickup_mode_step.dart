import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../models/booking_data.dart';
import 'pickup_mode_widgets/pickup_delivery_location_section.dart';
import 'pickup_mode_widgets/pickup_delivery_notes_section.dart';
import 'pickup_mode_widgets/pickup_mode_toggle_row.dart';
import 'pickup_mode_widgets/pickup_self_section.dart';

class PickupModeStep extends StatefulWidget {
  final BookingData data;
  final bool isDark;
  const PickupModeStep({super.key, required this.data, required this.isDark});

  @override
  State<PickupModeStep> createState() => _PickupModeStepState();
}

class _PickupModeStepState extends State<PickupModeStep> {
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _notesController.text = widget.data.deliveryNotes;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _openMapPicker({required bool isDelivery}) async {
    final result = await context.pushNamed<BookingLocation?>(
      'booking-location-picker',
      extra: {
        'initial': isDelivery ? widget.data.deliveryLocation : widget.data.pickupLocation,
        'forDelivery': isDelivery,
      },
    );
    if (result != null) {
      if (isDelivery) {
        widget.data.setDeliveryLocation(result);
      } else {
        widget.data.setPickupLocation(result);
      }
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = widget.isDark;
    final d = widget.data;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'booking_pickup_title'.tr(),
          style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.bold, color: cs.onSurface, height: 1.2),
        ),
        SizedBox(height: 6.r),
        Text(
          'booking_pickup_subtitle'.tr(),
          style: TextStyle(fontSize: 13.r, color: cs.onSurface.withValues(alpha: 0.55), height: 1.4),
        ),
        SizedBox(height: 18.r),
        PickupModeToggleRow(data: d, isDark: isDark),
        SizedBox(height: 16.r),
        if (d.pickupMode == PickupMode.selfPickup)
          PickupSelfSection(
            data: d,
            isDark: isDark,
            onOpenMap: () => _openMapPicker(isDelivery: false),
          ),
        if (d.pickupMode == PickupMode.delivery) ...[
          PickupDeliveryLocationSection(
            data: d,
            isDark: isDark,
            onOpenMap: () => _openMapPicker(isDelivery: true),
          ),
          SizedBox(height: 14.r),
          PickupDeliveryNotesSection(
            controller: _notesController,
            data: d,
            isDark: isDark,
          ),
        ],
      ],
    );
  }
}
