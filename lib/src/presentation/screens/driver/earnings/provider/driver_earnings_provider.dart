import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';

import '../../../../../constants/date_label_keys.dart';
import '../../../../../core/models/booking/booking.dart';
import '../../../../../core/utils/safe_notifier.dart';
import '../../shell/driver_shell_provider.dart';
import '../models/earnings_period.dart';

/// Thin view-model over [DriverShellProvider] for the earnings tab. The
/// completed-booking dataset and the selected period live in the shared shell
/// (so they survive navigation and update after any action); everything here
/// is pure client-side aggregation — the backend has no earnings endpoint.
class DriverEarningsProvider extends ChangeNotifier with SafeNotifier {
  DriverEarningsProvider(this._shell) {
    _shell.addListener(safeNotify);
  }

  final DriverShellProvider _shell;

  static const periodKeys = [
    'earnings_today',
    'earnings_week',
    'earnings_month',
    'earnings_year',
  ];

  bool get isLoading => _shell.isLoading;
  bool get isInitialLoading => _shell.isInitialLoading;
  String? get error => _shell.error;
  bool get hasData => _shell.hasData;

  EarningsPeriod get period => _shell.earningsPeriod;
  int get periodIndex => period.index;

  void setPeriodIndex(int index) =>
      _shell.setEarningsPeriod(EarningsPeriod.values[index]);

  Future<void> load() => _shell.refresh();

  /// Completed bookings paired with their completion timestamp, newest first.
  List<({Booking booking, DateTime when})> get _completed => _shell.completedRows;

  bool _inPeriod(DateTime when, EarningsPeriod period) {
    final now = DateTime.now();
    switch (period) {
      case EarningsPeriod.today:
        return when.year == now.year && when.month == now.month && when.day == now.day;
      case EarningsPeriod.week:
        return when.isAfter(now.subtract(const Duration(days: 7)));
      case EarningsPeriod.month:
        return when.year == now.year && when.month == now.month;
      case EarningsPeriod.year:
        return when.year == now.year;
    }
  }

  EarningsSnapshot get snapshot {
    final rows = _completed.where((r) => _inPeriod(r.when, period)).toList();
    var total = 0.0;
    var hours = 0.0;
    for (final r in rows) {
      total += r.booking.totalAmount ?? 0;
      final from = r.booking.fromDate;
      final to = r.booking.toDate;
      if (from != null && to != null && to.isAfter(from)) {
        hours += to.difference(from).inMinutes / 60.0;
      }
    }
    final trips = rows.length;
    return EarningsSnapshot(
      total: total,
      trips: trips,
      hours: double.parse(hours.toStringAsFixed(1)),
      avgPerTrip: trips == 0 ? 0 : total / trips,
    );
  }

  /// Sum of completed-booking revenue with a completion time in
  /// `[start, end)`.
  double _totalBetween(DateTime start, DateTime end) {
    var sum = 0.0;
    for (final r in _completed) {
      if (!r.when.isBefore(start) && r.when.isBefore(end)) {
        sum += r.booking.totalAmount ?? 0;
      }
    }
    return sum;
  }

  /// Revenue change of the current period vs the previous equivalent period,
  /// as a signed percentage. Null when the prior period had no revenue (so the
  /// UI can hide the badge instead of showing a meaningless ∞%).
  double? get trendPercent {
    final now = DateTime.now();
    late DateTime curStart, curEnd, prevStart, prevEnd;
    switch (period) {
      case EarningsPeriod.today:
        final t = DateTime(now.year, now.month, now.day);
        curStart = t;
        curEnd = t.add(const Duration(days: 1));
        prevStart = t.subtract(const Duration(days: 1));
        prevEnd = t;
      case EarningsPeriod.week:
        curEnd = now;
        curStart = now.subtract(const Duration(days: 7));
        prevEnd = curStart;
        prevStart = curStart.subtract(const Duration(days: 7));
      case EarningsPeriod.month:
        curStart = DateTime(now.year, now.month);
        curEnd = DateTime(now.year, now.month + 1);
        prevStart = DateTime(now.year, now.month - 1);
        prevEnd = curStart;
      case EarningsPeriod.year:
        curStart = DateTime(now.year);
        curEnd = DateTime(now.year + 1);
        prevStart = DateTime(now.year - 1);
        prevEnd = curStart;
    }
    final prev = _totalBetween(prevStart, prevEnd);
    if (prev <= 0) return null;
    final cur = _totalBetween(curStart, curEnd);
    return (cur - prev) / prev * 100;
  }

  /// Bar-chart series for the selected period, bucketed from completed
  /// bookings: today/week → the last 7 days (daily), month → weeks of the
  /// current month, year → the 12 months. The current day/week/month is
  /// highlighted.
  List<ChartBar> get chartData {
    final now = DateTime.now();
    switch (period) {
      case EarningsPeriod.today:
      case EarningsPeriod.week:
        final today = DateTime(now.year, now.month, now.day);
        final buckets = List<double>.filled(7, 0);
        for (final r in _completed) {
          final day = DateTime(r.when.year, r.when.month, r.when.day);
          final offset = today.difference(day).inDays;
          if (offset < 0 || offset > 6) continue;
          buckets[6 - offset] += r.booking.totalAmount ?? 0;
        }
        return List.generate(7, (i) {
          final day = today.subtract(Duration(days: 6 - i));
          return ChartBar(
            label: DateLabelKeys.dow[day.weekday - 1].tr(),
            value: buckets[i],
            highlight: i == 6,
          );
        });
      case EarningsPeriod.month:
        // Up to 5 week-of-month buckets (day 1–7 → W1, 8–14 → W2, …).
        final weeksInMonth = ((DateTime(now.year, now.month + 1, 0).day - 1) ~/ 7) + 1;
        final buckets = List<double>.filled(weeksInMonth, 0);
        for (final r in _completed) {
          if (r.when.year != now.year || r.when.month != now.month) continue;
          buckets[(r.when.day - 1) ~/ 7] += r.booking.totalAmount ?? 0;
        }
        final currentWeek = (now.day - 1) ~/ 7;
        return List.generate(weeksInMonth, (i) {
          return ChartBar(
            label: 'earnings_week_short'.tr(args: ['${i + 1}']),
            value: buckets[i],
            highlight: i == currentWeek,
          );
        });
      case EarningsPeriod.year:
        final buckets = List<double>.filled(12, 0);
        for (final r in _completed) {
          if (r.when.year != now.year) continue;
          buckets[r.when.month - 1] += r.booking.totalAmount ?? 0;
        }
        return List.generate(12, (i) {
          return ChartBar(
            label: DateLabelKeys.months[i].tr(),
            value: buckets[i],
            highlight: i == now.month - 1,
          );
        });
    }
  }

  List<RecentEarning> get recentEarnings {
    String date(DateTime d) {
      String two(int v) => v.toString().padLeft(2, '0');
      return '${d.year}-${two(d.month)}-${two(d.day)} ${two(d.hour)}:${two(d.minute)}';
    }

    return _completed.take(10).map((r) {
      final b = r.booking;
      return RecentEarning(
        date: date(r.when),
        customer: (b.customerFullName?.trim().isNotEmpty ?? false) ? b.customerFullName!.trim() : 'Customer',
        amount: b.totalAmount ?? 0,
        status: 'completed',
      );
    }).toList();
  }

  @override
  void dispose() {
    _shell.removeListener(safeNotify);
    super.dispose();
  }
}
