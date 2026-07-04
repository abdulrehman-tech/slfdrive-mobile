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
  int _timeSlot = 1; // pickup slot: 0 morning 1 afternoon 2 evening 3 custom
  TimeOfDay _pickupTime = const TimeOfDay(hour: 10, minute: 0);

  int _returnSlot = 1; // drop-off slot (same slot semantics as pickup)
  TimeOfDay _returnTime = const TimeOfDay(hour: 10, minute: 0);

  // Picked calendar dates (date-only); the pickup/return times are layered on
  // top when pushing to BookingData, so the payload carries the real times.
  DateTime? _startDate;
  DateTime? _endDate;

  static const _timeSlots = <(String, String, TimeOfDay)>[
    ('booking_time_morning', '7:00 – 11:00', TimeOfDay(hour: 9, minute: 0)),
    ('booking_time_afternoon', '11:00 – 17:00', TimeOfDay(hour: 14, minute: 0)),
    ('booking_time_evening', '17:00 – 22:00', TimeOfDay(hour: 19, minute: 0)),
    ('booking_time_custom', 'Pick exact time', TimeOfDay(hour: 10, minute: 0)),
  ];

  @override
  void initState() {
    super.initState();
    // Seed local date/time state from any dates already on BookingData (the flow
    // controller seeds defaults before this step builds).
    final s = widget.data.startAt;
    final e = widget.data.endAt;
    if (s != null) {
      _startDate = DateTime(s.year, s.month, s.day);
      // Recover the pickup time from the seeded start, matching it to a slot.
      _pickupTime = TimeOfDay(hour: s.hour, minute: s.minute);
      _timeSlot = _slotForTime(_pickupTime);
    }
    if (e != null) {
      _endDate = DateTime(e.year, e.month, e.day);
      _returnTime = TimeOfDay(hour: e.hour, minute: e.minute);
      _returnSlot = _slotForTime(_returnTime);
    }

    if (widget.data.startAt == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || widget.data.startAt != null) return;
        final now = DateTime.now();
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = _startDate!.add(const Duration(days: 2));
        _applyDateTime();
      });
    }
  }

  /// The pickup / return times in effect: the selected preset slot's time, or
  /// the custom time when the custom slot is active.
  TimeOfDay get _effectivePickup =>
      _timeSlot < 3 ? _timeSlots[_timeSlot].$3 : _pickupTime;
  TimeOfDay get _effectiveReturn =>
      _returnSlot < 3 ? _timeSlots[_returnSlot].$3 : _returnTime;

  int _slotForTime(TimeOfDay t) {
    for (var i = 0; i < 3; i++) {
      if (_timeSlots[i].$3.hour == t.hour && _timeSlots[i].$3.minute == t.minute) return i;
    }
    return 3; // custom
  }

  /// Combines the picked dates with the effective pickup time and pushes them to
  /// BookingData, so fromDateTime/toDateTime carry the real time-of-day.
  void _applyDateTime() {
    final sd = _startDate;
    final ed = _endDate;
    if (sd == null || ed == null) return;
    final p = _effectivePickup;
    final r = _effectiveReturn;
    final start = DateTime(sd.year, sd.month, sd.day, p.hour, p.minute);
    final end = DateTime(ed.year, ed.month, ed.day, r.hour, r.minute);
    widget.data.setDates(start, end);
  }

  Future<void> _pickCustomTime({required bool isReturn}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isReturn ? _returnTime : _pickupTime,
      builder: (ctx, child) => Theme(data: Theme.of(ctx), child: child!),
    );
    if (picked != null) {
      setState(() => isReturn ? _returnTime = picked : _pickupTime = picked);
      _applyDateTime();
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
                        _startDate = r.startDate;
                        _endDate = r.endDate;
                        _applyDateTime();
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
                      '${d.units} ${d.unitLabelKey.tr()}',
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

        // Pickup time
        _timeSection(
          cs: cs,
          isDark: isDark,
          titleKey: 'booking_time_pickup',
          selectedSlot: _timeSlot,
          customTime: _pickupTime,
          onTapSlot: (i) {
            setState(() => _timeSlot = i);
            if (i == 3) {
              _pickCustomTime(isReturn: false);
            } else {
              _applyDateTime();
            }
          },
        ),

        SizedBox(height: 14.r),

        // Return (drop-off) time
        _timeSection(
          cs: cs,
          isDark: isDark,
          titleKey: 'booking_time_return',
          selectedSlot: _returnSlot,
          customTime: _returnTime,
          onTapSlot: (i) {
            setState(() => _returnSlot = i);
            if (i == 3) {
              _pickCustomTime(isReturn: true);
            } else {
              _applyDateTime();
            }
          },
        ),
      ],
    );
  }

  /// A titled card of time-slot chips (Morning / Afternoon / Evening / Custom).
  Widget _timeSection({
    required ColorScheme cs,
    required bool isDark,
    required String titleKey,
    required int selectedSlot,
    required TimeOfDay customTime,
    required ValueChanged<int> onTapSlot,
  }) {
    return BookingGlassCard(
      isDark: isDark,
      padding: EdgeInsets.all(14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookingSectionHeader(
            icon: Iconsax.clock_copy,
            iconColor: const Color(0xFFFFA726),
            title: titleKey.tr(),
            isDark: isDark,
          ),
          SizedBox(height: 12.r),
          Wrap(
            spacing: 8.r,
            runSpacing: 8.r,
            children: List.generate(_timeSlots.length, (i) {
              final slot = _timeSlots[i];
              final active = selectedSlot == i;
              return GestureDetector(
                onTap: () => onTapSlot(i),
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
                          customTime.format(context),
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
    );
  }

  String _formatShort(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]}';
  }
}
