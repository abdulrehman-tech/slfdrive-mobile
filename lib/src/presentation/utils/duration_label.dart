import 'package:easy_localization/easy_localization.dart';

/// Localised count of billing units, e.g. "1 day" / "2 days", "يوم واحد" /
/// "يومان" / "3 أيام". Uses EasyLocalization plural forms so each language
/// gets its own grammar instead of a fixed "{n} days".
String durationLabel(int units, {bool hourly = false}) =>
    (hourly ? 'units_hours' : 'units_days').plural(units);
