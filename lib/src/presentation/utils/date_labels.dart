import 'package:intl/intl.dart';

/// Locale-aware date labels. Uses `Intl.defaultLocale`, which `MyApp` keeps in
/// sync with the EasyLocalization locale, so Arabic gets real month names
/// ("٢٦ سبتمبر" style, with Latin digits — see `main.dart`) instead of English
/// abbreviations reordered by the bidi algorithm.
String _locale() => Intl.getCurrentLocale();

/// "26 Sep" / "26 سبتمبر".
String formatDayMonth(DateTime d) => DateFormat('d MMM', _locale()).format(d);

/// "26 Sep 2026" / "26 سبتمبر 2026".
String formatDayMonthYear(DateTime d) => DateFormat('d MMM y', _locale()).format(d);

/// "26 Sep 2026, 3:00 PM" / "26 سبتمبر 2026، 3:00 م".
String formatDayMonthYearTime(DateTime d) {
  final sep = Intl.getCurrentLocale().startsWith('ar') ? '، ' : ', ';
  return '${formatDayMonthYear(d)}$sep${DateFormat.jm(_locale()).format(d)}';
}

/// "26 – 28 Sep" style range between two days, or a single day when equal.
String formatDayRange(DateTime from, DateTime to) {
  if (from.year == to.year && from.month == to.month && from.day == to.day) return formatDayMonth(from);
  return '${formatDayMonth(from)} – ${formatDayMonth(to)}';
}
