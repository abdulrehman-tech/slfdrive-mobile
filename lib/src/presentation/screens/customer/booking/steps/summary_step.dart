import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../models/booking_data.dart';
import 'summary_widgets/summary_corporate_card.dart';
import 'summary_widgets/summary_header.dart';
import 'summary_widgets/summary_logistics_card.dart';
import 'summary_widgets/summary_pricing_card.dart';
import 'summary_widgets/summary_schedule_card.dart';
import 'summary_widgets/summary_subject_card.dart';

class SummaryStep extends StatelessWidget {
  final BookingData data;
  final bool isDark;
  const SummaryStep({super.key, required this.data, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final d = data;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SummaryHeader(),
        SizedBox(height: 18.r),

        if (d.isCorporate && d.company != null) ...[
          SummaryCorporateCard(data: d, isDark: isDark),
          SizedBox(height: 12.r),
        ],

        // Service subject summary card (car, driver, both)
        SummarySubjectCard(data: d, isDark: isDark),
        SizedBox(height: 12.r),

        // Dates card
        SummaryScheduleCard(data: d, isDark: isDark),
        SizedBox(height: 12.r),

        // Location card
        SummaryLogisticsCard(data: d, isDark: isDark),

        SizedBox(height: 14.r),
        SummaryPricingCard(data: d, isDark: isDark),
      ],
    );
  }
}
