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

  /// Opens the map picker for the delivery address. Self-pickup is read-only
  /// (the vehicle's own location), so it never opens the picker.
  Future<void> _openDeliveryPicker() async {
    final result = await context.pushNamed<BookingLocation?>(
      'booking-location-picker',
      extra: {
        'initial': widget.data.deliveryLocation,
        'forDelivery': true,
      },
    );
    if (result != null) {
      widget.data.setDeliveryLocation(result);
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
          PickupSelfSection(data: d, isDark: isDark),
        if (d.pickupMode == PickupMode.delivery) ...[
          PickupDeliveryLocationSection(
            data: d,
            isDark: isDark,
            onOpenMap: _openDeliveryPicker,
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
