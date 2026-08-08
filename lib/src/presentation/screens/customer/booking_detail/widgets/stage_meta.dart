import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../models/booking_detail.dart';

String bookingStageLabelKey(BookingTimelineStage s) {
  switch (s) {
    case BookingTimelineStage.confirmed:
      return 'booking_detail_stage_confirmed';
    case BookingTimelineStage.pickedUp:
      return 'booking_detail_stage_pickedup';
    case BookingTimelineStage.inTrip:
      return 'booking_detail_stage_intrip';
    case BookingTimelineStage.returned:
      return 'booking_detail_stage_returned';
  }
}

IconData bookingStageIcon(BookingTimelineStage s) {
  switch (s) {
    case BookingTimelineStage.confirmed:
      return Iconsax.tick_circle_copy;
    case BookingTimelineStage.pickedUp:
      return Iconsax.key_copy;
    case BookingTimelineStage.inTrip:
      return Iconsax.route_square_copy;
    case BookingTimelineStage.returned:
      return Iconsax.flag_copy;
  }
}

String formatBookingDate(DateTime d, {bool includeTime = false}) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  final dateStr = '${d.day} ${months[d.month - 1]} ${d.year}';
  if (!includeTime) return dateStr;

  final hour = d.hour == 0 ? 12 : (d.hour > 12 ? d.hour - 12 : d.hour);
  final amPm = d.hour >= 12 ? 'PM' : 'AM';
  final minute = d.minute.toString().padLeft(2, '0');
  return '$dateStr, $hour:$minute $amPm';
}
