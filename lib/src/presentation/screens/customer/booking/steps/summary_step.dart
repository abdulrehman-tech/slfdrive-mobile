import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/booking_data.dart';
import 'summary_widgets/summary_extras_card.dart';
import 'summary_widgets/summary_header.dart';
import 'summary_widgets/summary_logistics_card.dart';
import 'summary_widgets/summary_pricing_card.dart';
import 'summary_widgets/summary_promo_card.dart';
import 'summary_widgets/summary_schedule_card.dart';
import 'summary_widgets/summary_subject_card.dart';

class SummaryStep extends StatefulWidget {
  final BookingData data;
  final bool isDark;
  const SummaryStep({super.key, required this.data, required this.isDark});

  @override
  State<SummaryStep> createState() => _SummaryStepState();
}

class _SummaryStepState extends State<SummaryStep> {
  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final isDark = widget.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SummaryHeader(),
        SizedBox(height: 18.r),

        // Service subject summary card (car, driver, both)
        SummarySubjectCard(data: d, isDark: isDark),
        SizedBox(height: 12.r),

        // Dates card
        SummaryScheduleCard(data: d, isDark: isDark),
        SizedBox(height: 12.r),

        // Location card
        SummaryLogisticsCard(data: d, isDark: isDark),

        if (d.selectedExtras.isNotEmpty) ...[
          SizedBox(height: 12.r),
          SummaryExtrasCard(data: d, isDark: isDark),
        ],

        SizedBox(height: 12.r),

        // Promo code
        SummaryPromoCard(
          data: d,
          isDark: isDark,
          onApplied: () => setState(() {}),
        ),

        SizedBox(height: 14.r),
        SummaryPricingCard(data: d, isDark: isDark),
      ],
    );
  }
}
