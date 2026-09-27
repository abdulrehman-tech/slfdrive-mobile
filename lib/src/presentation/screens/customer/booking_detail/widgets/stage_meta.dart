import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../models/booking_detail.dart';
import '../../../../utils/date_labels.dart';

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

String formatBookingDate(DateTime d, {bool includeTime = false}) =>
    includeTime ? formatDayMonthYearTime(d) : formatDayMonthYear(d);
