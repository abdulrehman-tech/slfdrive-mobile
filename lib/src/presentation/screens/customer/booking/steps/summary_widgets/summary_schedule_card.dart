import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../models/booking_data.dart';
import '../../widgets/booking_glass_card.dart';
import 'summary_info_row.dart';

class SummaryScheduleCard extends StatelessWidget {
  final BookingData data;
  final bool isDark;
  const SummaryScheduleCard({super.key, required this.data, required this.isDark});

  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  String _formatDate(DateTime? d, bool includeTime) {
    if (d == null) return '-';
    final dateStr = '${d.day} ${_months[d.month - 1]} ${d.year}';
    if (!includeTime) return dateStr;

    final hour = d.hour == 0 ? 12 : (d.hour > 12 ? d.hour - 12 : d.hour);
    final amPm = d.hour >= 12 ? 'PM' : 'AM';
    final minute = d.minute.toString().padLeft(2, '0');
    return '$dateStr, $hour:$minute $amPm';
  }

  @override
  Widget build(BuildContext context) {
    final d = data;
    return BookingGlassCard(
      isDark: isDark,
      padding: EdgeInsets.all(14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookingSectionHeader(
            icon: Iconsax.calendar_2_copy,
            iconColor: const Color(0xFF3D5AFE),
            title: 'booking_summary_schedule'.tr(),
            isDark: isDark,
          ),
          SizedBox(height: 10.r),
          SummaryInfoRow(label: 'booking_summary_pickup_date'.tr(), value: _formatDate(d.startAt, d.isHourly)),
          SummaryInfoRow(label: 'booking_summary_return_date'.tr(), value: _formatDate(d.endAt, d.isHourly)),
          SummaryInfoRow(
            label: 'booking_summary_duration'.tr(),
            value: '${d.units} ${d.unitLabelKey.tr()}',
          ),
        ],
      ),
    );
  }
}
