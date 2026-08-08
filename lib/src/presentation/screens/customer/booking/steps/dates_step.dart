import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
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
  DateTime? _startDate;
  DateTime? _endDate;

  TimeOfDay _pickupTime = const TimeOfDay(hour: 10, minute: 0);
  TimeOfDay _returnTime = const TimeOfDay(hour: 10, minute: 0);

  String? _timeError;

  @override
  void initState() {
    super.initState();
    final s = widget.data.startAt;
    final e = widget.data.endAt;
    if (s != null) {
      _startDate = DateTime(s.year, s.month, s.day);
      _pickupTime = TimeOfDay(hour: s.hour, minute: s.minute);
    }
    if (e != null) {
      _endDate = DateTime(e.year, e.month, e.day);
      _returnTime = TimeOfDay(hour: e.hour, minute: e.minute);
    }

    if (widget.data.startAt == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || widget.data.startAt != null) return;
        final now = DateTime.now();
        _startDate = DateTime(now.year, now.month, now.day);
        _endDate = _startDate!.add(const Duration(days: 2));
        _pickupTime = const TimeOfDay(hour: 10, minute: 0);
        _returnTime = const TimeOfDay(hour: 11, minute: 0);
        _applyDateTime();
      });
    }
  }

  void _validateAndAdjustTime({required bool changedPickup}) {
    final sd = _startDate;
    final ed = widget.data.isExplicitlyHourly ? _startDate : _endDate;

    if (sd != null && ed != null) {
      final start = DateTime(sd.year, sd.month, sd.day, _pickupTime.hour, _pickupTime.minute);
      final end = DateTime(ed.year, ed.month, ed.day, _returnTime.hour, _returnTime.minute);
      final diff = end.difference(start).inMinutes;

      if (widget.data.isExplicitlyHourly) {
        if (diff < 60) {
          _timeError = 'Drop-off must be at least 1 hour after pickup.';
        } else {
          _timeError = null;
        }
      } else {
        if (diff <= 0) {
          _timeError = 'Drop-off must be after pickup time.';
        } else {
          _timeError = null;
        }
      }
    } else {
      _timeError = null;
    }
  }

  void _applyDateTime() {
    final sd = _startDate;
    final ed = _endDate;
    if (sd == null || ed == null) return;

    final start = DateTime(sd.year, sd.month, sd.day, _pickupTime.hour, _pickupTime.minute);
    // If hourly mode, force end date to be the same as start date.
    final finalEd = widget.data.isExplicitlyHourly ? sd : ed;
    
    final end = DateTime(finalEd.year, finalEd.month, finalEd.day, _returnTime.hour, _returnTime.minute);
    widget.data.setDates(start, end);
  }

  void _pickTime({required bool isReturn}) {
    final initialTime = isReturn ? _returnTime : _pickupTime;
    final now = DateTime.now();
    final initialDateTime = DateTime(now.year, now.month, now.day, initialTime.hour, initialTime.minute);

    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => Material(
        color: Colors.transparent,
        child: Container(
          height: 280.r,
          color: widget.isDark ? Colors.grey[900] : Colors.white,
          child: SafeArea(
          top: false,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: widget.isDark ? Colors.grey[850] : Colors.grey[100],
                  border: Border(bottom: BorderSide(color: Colors.grey.withValues(alpha: 0.2))),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      child: Text('Cancel', style: TextStyle(color: Colors.red, fontSize: 15.r)),
                      onPressed: () => Navigator.of(ctx).pop(),
                    ),
                    Text(
                      isReturn ? 'booking_dates_when_return'.tr() : 'booking_dates_when_pickup'.tr(),
                      style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w600, color: widget.isDark ? Colors.white : Colors.black),
                    ),
                    CupertinoButton(
                      child: Text(isReturn ? 'Done' : 'Next', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.r)),
                      onPressed: () {
                        Navigator.of(ctx).pop();
                        if (!isReturn) {
                          Future.delayed(const Duration(milliseconds: 250), () {
                            if (mounted) _pickTime(isReturn: true);
                          });
                        }
                      },
                    )
                  ],
                ),
              ),
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.time,
                  initialDateTime: initialDateTime,
                  onDateTimeChanged: (DateTime newDateTime) {
                    setState(() {
                      if (isReturn) {
                        _returnTime = TimeOfDay.fromDateTime(newDateTime);
                        _validateAndAdjustTime(changedPickup: false);
                      } else {
                        _pickupTime = TimeOfDay.fromDateTime(newDateTime);
                        _validateAndAdjustTime(changedPickup: true);
                      }
                    });
                    _applyDateTime();
                  },
                ),
              ),
            ],
          ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = widget.isDark;
    final d = widget.data;

    final bool canHourly = d.supportsHourly;
    final bool isHourly = d.isExplicitlyHourly;

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
                title: isHourly ? 'booking_dates_choose_date'.tr() : 'booking_dates_choose_dates'.tr(),
                isDark: isDark,
              ),
              SizedBox(height: 8.r),
              SizedBox(
                height: 340.r,
                child: SfDateRangePicker(
                  key: ValueKey(isHourly), // Remount when mode changes
                  view: DateRangePickerView.month,
                  selectionMode: isHourly ? DateRangePickerSelectionMode.single : DateRangePickerSelectionMode.range,
                  minDate: DateTime.now(),
                  initialSelectedRange: !isHourly ? PickerDateRange(d.startAt, d.endAt) : null,
                  initialSelectedDate: isHourly ? d.startAt : null,
                  onSelectionChanged: (args) {
                    if (isHourly) {
                      if (args.value is DateTime) {
                        _startDate = args.value as DateTime;
                        _endDate = _startDate;
                        _validateAndAdjustTime(changedPickup: true);
                        _applyDateTime();
                      }
                    } else {
                      if (args.value is PickerDateRange) {
                        final r = args.value as PickerDateRange;
                        if (r.startDate != null && r.endDate != null) {
                          _startDate = r.startDate;
                          _endDate = r.endDate;
                          _validateAndAdjustTime(changedPickup: true);
                          _applyDateTime();
                        }
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

        if (canHourly) ...[
          BookingGlassCard(
            isDark: isDark,
            padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 12.r),
            child: Row(
              children: [
                Container(
                  width: 38.r,
                  height: 38.r,
                  decoration: BoxDecoration(
                    color: cs.primary.withValues(alpha: isDark ? 0.2 : 0.12),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(Iconsax.clock_1_copy, size: 20.r, color: cs.primary),
                ),
                SizedBox(width: 14.r),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isHourly ? 'booking_dates_hourly_active'.tr() : 'booking_dates_quick_trip'.tr(),
                        style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w600, color: cs.onSurface),
                      ),
                      Text(
                        isHourly 
                           ? 'booking_dates_booking_by_hour'.tr() 
                           : 'booking_dates_switch_hourly'.tr(),
                        style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.55)),
                      ),
                    ],
                  ),
                ),
                CupertinoSwitch(
                  value: isHourly,
                  activeTrackColor: cs.primary,
                  onChanged: (val) {
                    widget.data.setIsHourlyMode(val);
                    if (val && _startDate != null) {
                      _endDate = _startDate;
                    }
                    _validateAndAdjustTime(changedPickup: true);
                    _applyDateTime();
                  },
                ),
              ],
            ),
          ),
          SizedBox(height: 14.r),
        ],

        if (_timeError != null)
          Padding(
            padding: EdgeInsets.only(bottom: 14.r),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.redAccent, size: 16.r),
                SizedBox(width: 6.r),
                Expanded(
                  child: Text(
                    _timeError!,
                    style: TextStyle(color: Colors.redAccent, fontSize: 13.r, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),

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
                      'booking_dates_total_duration'.tr(),
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

        // Time pickers grouped in a single card
        BookingGlassCard(
          isDark: isDark,
          padding: EdgeInsets.zero,
          child: Column(
            children: [
              _timeRow(
                cs: cs,
                isDark: isDark,
                titleKey: 'booking_time_pickup',
                time: _pickupTime,
                icon: Iconsax.clock_copy,
                iconColor: const Color(0xFF4CAF50), // Green for start
                onTap: () => _pickTime(isReturn: false),
              ),
              Divider(height: 1, color: cs.onSurface.withValues(alpha: 0.05), indent: 64.r),
              _timeRow(
                cs: cs,
                isDark: isDark,
                titleKey: 'booking_time_return',
                time: _returnTime,
                icon: Iconsax.timer_1_copy,
                iconColor: const Color(0xFFFFA726), // Orange for end
                onTap: () => _pickTime(isReturn: true),
              ),
            ],
          ),
        ),
        SizedBox(height: 80.r), // Extra padding so it doesn't clutter with the bottom bar
      ],
    );
  }

  Widget _timeRow({
    required ColorScheme cs,
    required bool isDark,
    required String titleKey,
    required TimeOfDay time,
    required IconData icon,
    required Color iconColor,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            Container(
              width: 38.r,
              height: 38.r,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.2 : 0.12),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, size: 20.r, color: iconColor),
            ),
            SizedBox(width: 14.r),
            Expanded(
              child: Text(
                titleKey.tr(),
                style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w600, color: cs.onSurface),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 6.r),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                time.format(context),
                style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.bold, color: cs.primary),
              ),
            ),
            SizedBox(width: 8.r),
            Icon(Icons.chevron_right_rounded, size: 20.r, color: cs.onSurface.withValues(alpha: 0.3)),
          ],
        ),
      ),
    );
  }

  String _formatShort(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]}';
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
