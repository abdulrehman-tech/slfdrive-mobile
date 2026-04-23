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
