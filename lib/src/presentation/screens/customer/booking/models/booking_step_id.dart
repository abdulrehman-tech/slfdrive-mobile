import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

/// Identifiers for steps rendered by the booking flow.
///
/// The orchestrator derives the visible subset from the currently selected
/// [BookingServiceType] plus whether the flow was entered with a pre-selected
/// subject (car/driver), in which case the service selector is skipped.
enum BookingStepId { service, dates, pickup, extras, driver, summary, payment }

extension BookingStepIdX on BookingStepId {
  /// Localization key for the step's title (used by both the compact mobile
  /// label and the desktop side rail).
  String get titleKey {
    switch (this) {
      case BookingStepId.service:
        return 'booking_step_service';
      case BookingStepId.dates:
        return 'booking_step_dates';
      case BookingStepId.pickup:
        return 'booking_step_pickup';
      case BookingStepId.extras:
        return 'booking_step_extras';
      case BookingStepId.driver:
        return 'booking_step_driver';
      case BookingStepId.summary:
        return 'booking_step_summary';
      case BookingStepId.payment:
        return 'booking_step_payment';
    }
  }

  /// Icon used on the desktop side rail.
  IconData get icon {
    switch (this) {
      case BookingStepId.service:
        return Iconsax.setting_4_copy;
      case BookingStepId.dates:
        return Iconsax.calendar_2_copy;
      case BookingStepId.pickup:
        return Iconsax.truck_copy;
      case BookingStepId.extras:
        return Iconsax.additem_copy;
      case BookingStepId.driver:
        return Iconsax.user_octagon_copy;
      case BookingStepId.summary:
        return Iconsax.clipboard_text_copy;
      case BookingStepId.payment:
        return Iconsax.card_copy;
    }
  }
}
