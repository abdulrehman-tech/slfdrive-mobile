/// One day in the driver's rolling 7-day revenue series shown on the home
/// earnings card. [labelKey] is a translation key from [DateLabelKeys.dow];
/// [amount] is that day's completed-booking revenue in OMR; [isToday] marks the
/// current day for emphasis.
class DayEarning {
  final String labelKey;
  final double amount;
  final bool isToday;

  const DayEarning({
    required this.labelKey,
    required this.amount,
    required this.isToday,
  });
}
