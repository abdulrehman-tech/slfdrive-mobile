enum EarningsPeriod { today, week, month, year }

class EarningsSnapshot {
  final double total;
  final int trips;
  final double hours;
  final double avgPerTrip;

  const EarningsSnapshot({
    required this.total,
    required this.trips,
    required this.hours,
    required this.avgPerTrip,
  });
}

/// One column of the earnings-screen revenue chart. [label] is already
/// localized (day/week/month), [value] is OMR revenue, [highlight] marks the
/// current day/week/month.
class ChartBar {
  final String label;
  final double value;
  final bool highlight;

  const ChartBar({
    required this.label,
    required this.value,
    this.highlight = false,
  });
}

class RecentEarning {
  final String date;
  final String customer;
  final double amount;
  final String status;

  const RecentEarning({
    required this.date,
    required this.customer,
    required this.amount,
    required this.status,
  });
}
