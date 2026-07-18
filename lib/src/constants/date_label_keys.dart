/// Translation keys for short day-of-week and month axis labels, used by the
/// driver revenue charts. Index-aligned so callers can map a `DateTime` field
/// straight to a key: `kDowKeys[date.weekday - 1]`, `kMonthKeys[date.month - 1]`.
class DateLabelKeys {
  DateLabelKeys._();

  /// Monday-first, matching Dart's `DateTime.weekday` (1 = Mon … 7 = Sun).
  static const List<String> dow = [
    'dow_mon',
    'dow_tue',
    'dow_wed',
    'dow_thu',
    'dow_fri',
    'dow_sat',
    'dow_sun',
  ];

  /// January-first, matching `DateTime.month` (1 = Jan … 12 = Dec).
  static const List<String> months = [
    'mon_jan',
    'mon_feb',
    'mon_mar',
    'mon_apr',
    'mon_may',
    'mon_jun',
    'mon_jul',
    'mon_aug',
    'mon_sep',
    'mon_oct',
    'mon_nov',
    'mon_dec',
  ];
}
