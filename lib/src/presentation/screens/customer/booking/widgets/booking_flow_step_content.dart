import 'package:flutter/material.dart';

import '../models/booking_data.dart';
import '../models/booking_step_id.dart';
import '../steps/dates_step.dart';
import '../steps/driver_select_step.dart';
import '../steps/extras_step.dart';
import '../steps/payment_step.dart';
import '../steps/pickup_mode_step.dart';
import '../steps/service_type_step.dart';
import '../steps/summary_step.dart';

/// Resolves and builds the widget for a given [BookingStepId].
class BookingFlowStepContent extends StatelessWidget {
  final BookingStepId step;
  final BookingData data;
  final bool isDark;

  const BookingFlowStepContent({
    super.key,
    required this.step,
    required this.data,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    switch (step) {
      case BookingStepId.service:
        return ServiceTypeStep(data: data, isDark: isDark);
      case BookingStepId.dates:
        return DatesStep(data: data, isDark: isDark);
      case BookingStepId.pickup:
        return PickupModeStep(data: data, isDark: isDark);
      case BookingStepId.extras:
        return ExtrasStep(data: data, isDark: isDark);
      case BookingStepId.driver:
        return DriverSelectStep(data: data, isDark: isDark);
      case BookingStepId.summary:
        return SummaryStep(data: data, isDark: isDark);
      case BookingStepId.payment:
        return PaymentStep(data: data, isDark: isDark);
    }
  }
}
