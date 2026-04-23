import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../models/booking_data.dart';
import '../../widgets/booking_glass_card.dart';

class PickupDeliveryNotesSection extends StatelessWidget {
  final TextEditingController controller;
  final BookingData data;
  final bool isDark;

  const PickupDeliveryNotesSection({
    super.key,
    required this.controller,
    required this.data,
    required this.isDark,
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
            icon: Iconsax.note_text_copy,
            iconColor: const Color(0xFF7C4DFF),
            title: 'booking_delivery_notes'.tr(),
            isDark: isDark,
          ),
          SizedBox(height: 10.r),
          TextField(
            controller: controller,
            maxLines: 3,
            onChanged: data.setDeliveryNotes,
            style: TextStyle(fontSize: 13.r, color: cs.onSurface),
            decoration: InputDecoration(
              hintText: 'booking_delivery_notes_hint'.tr(),
              hintStyle: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.4)),
              filled: true,
              fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              contentPadding: EdgeInsets.all(12.r),
            ),
          ),
        ],
      ),
    );
  }
}
