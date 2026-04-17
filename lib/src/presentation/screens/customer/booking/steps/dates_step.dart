import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

import '../models/booking_data.dart';
import '../widgets/booking_glass_card.dart';

class DatesStep extends StatefulWidget {
  final BookingData data;
  final bool isDark;
  const DatesStep({super.key, required this.data, required this.isDark});

  @override
  State<DatesStep> createState() => _DatesStepState();
}

class _DatesStepState extends State<DatesStep> {
  int _timeSlot = 1; // 0 morning 1 afternoon 2 evening 3 custom
  TimeOfDay _pickupTime = const TimeOfDay(hour: 10, minute: 0);

  static const _timeSlots = <(String, String, TimeOfDay)>[
    ('booking_time_morning', '7:00 – 11:00', TimeOfDay(hour: 9, minute: 0)),
    ('booking_time_afternoon', '11:00 – 17:00', TimeOfDay(hour: 14, minute: 0)),
    ('booking_time_evening', '17:00 – 22:00', TimeOfDay(hour: 19, minute: 0)),
    ('booking_time_custom', 'Pick exact time', TimeOfDay(hour: 10, minute: 0)),
  ];

  @override
  void initState() {
    super.initState();
    // Note: default dates are seeded by BookingFlowScreen.initState BEFORE its
    // listener is attached. We only provide a post-frame fallback in case this
    // step is ever used outside the flow controller.
    if (widget.data.startAt == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || widget.data.startAt != null) return;
        final now = DateTime.now();
        final start = DateTime(now.year, now.month, now.day);
        widget.data.setDates(start, start.add(const Duration(days: 2)));
      });
    }
  }

  Future<void> _pickCustomTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _pickupTime,
      builder: (ctx, child) => Theme(data: Theme.of(ctx).copyWith(useMaterial3: true), child: child!),
    );
    if (picked != null) {
      setState(() => _pickupTime = picked);
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
          'booking_dates_title'.tr(),
          style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.bold, color: cs.onSurface, height: 1.2),
        ),
        SizedBox(height: 6.r),
        Text(
          'booking_dates_subtitle'.tr(),
          style: TextStyle(fontSize: 13.r, color: cs.onSurface.withValues(alpha: 0.55), height: 1.4),
        ),
        SizedBox(height: 18.r),

        // Date range picker
        BookingGlassCard(
          isDark: isDark,
          padding: EdgeInsets.all(12.r),
          child: Column(
            children: [
              BookingSectionHeader(
                icon: Iconsax.calendar_2_copy,
                iconColor: const Color(0xFF3D5AFE),
                title: 'booking_dates_range'.tr(),
                isDark: isDark,
              ),
              SizedBox(height: 8.r),
              SizedBox(
                height: 340.r,
                child: SfDateRangePicker(
                  view: DateRangePickerView.month,
                  selectionMode: DateRangePickerSelectionMode.range,
                  minDate: DateTime.now(),
                  initialSelectedRange: PickerDateRange(d.startAt, d.endAt),
                  onSelectionChanged: (args) {
                    if (args.value is PickerDateRange) {
                      final r = args.value as PickerDateRange;
                      if (r.startDate != null && r.endDate != null) {
                        widget.data.setDates(r.startDate!, r.endDate!);
                      }
                    }
                  },
                  headerStyle: DateRangePickerHeaderStyle(
                    textAlign: TextAlign.center,
                    textStyle: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                  ),
                  monthCellStyle: DateRangePickerMonthCellStyle(
                    textStyle: TextStyle(fontSize: 12.r, color: cs.onSurface),
                    todayTextStyle: TextStyle(fontSize: 12.r, color: cs.primary, fontWeight: FontWeight.w700),
                  ),
                  selectionColor: cs.primary,
                  startRangeSelectionColor: cs.primary,
                  endRangeSelectionColor: cs.primary,
                  rangeSelectionColor: cs.primary.withValues(alpha: 0.15),
                  selectionTextStyle: TextStyle(fontSize: 12.r, color: Colors.white, fontWeight: FontWeight.w700),
                  rangeTextStyle: TextStyle(fontSize: 12.r, color: cs.onSurface, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: 14.r),

        // Duration summary
        BookingGlassCard(
          isDark: isDark,
          padding: EdgeInsets.all(14.r),
          child: Row(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: const Color(0xFF00BCD4).withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Iconsax.timer_1_copy, size: 18.r, color: const Color(0xFF00BCD4)),
              ),
              SizedBox(width: 12.r),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'booking_dates_duration'.tr(),
                      style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.5)),
                    ),
                    SizedBox(height: 2.r),
                    Text(
                      '${d.days} ${'booking_dates_days'.tr()}',
                      style: TextStyle(fontSize: 17.r, fontWeight: FontWeight.w800, color: cs.onSurface),
                    ),
                  ],
                ),
              ),
              if (d.startAt != null && d.endAt != null)
                Text(
                  '${_formatShort(d.startAt!)} → ${_formatShort(d.endAt!)}',
                  style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.55)),
                ),
            ],
          ),
        ),

        SizedBox(height: 14.r),

        // Time slot chips
        BookingGlassCard(
          isDark: isDark,
          padding: EdgeInsets.all(14.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookingSectionHeader(
                icon: Iconsax.clock_copy,
                iconColor: const Color(0xFFFFA726),
                title: 'booking_time_pickup'.tr(),
                isDark: isDark,
              ),
              SizedBox(height: 12.r),
              Wrap(
                spacing: 8.r,
                runSpacing: 8.r,
                children: List.generate(_timeSlots.length, (i) {
                  final slot = _timeSlots[i];
                  final active = _timeSlot == i;
                  return GestureDetector(
                    onTap: () {
                      setState(() => _timeSlot = i);
                      if (i == 3) _pickCustomTime();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 9.r),
                      decoration: BoxDecoration(
                        color: active
                            ? cs.primary.withValues(alpha: isDark ? 0.22 : 0.12)
                            : (isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.03)),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: active
                              ? cs.primary.withValues(alpha: 0.4)
                              : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            slot.$1.tr(),
                            style: TextStyle(
                              fontSize: 12.r,
                              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                              color: active ? cs.primary : cs.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                          if (i < 3) ...[
                            SizedBox(width: 6.r),
                            Text(
                              slot.$2,
                              style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.4)),
                            ),
                          ],
                          if (i == 3 && active) ...[
                            SizedBox(width: 6.r),
                            Text(
                              _pickupTime.format(context),
                              style: TextStyle(fontSize: 10.r, color: cs.primary, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatShort(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]}';
  }
}
