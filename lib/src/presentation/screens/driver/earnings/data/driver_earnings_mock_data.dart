import '../models/earnings_period.dart';

const EarningsSnapshot kEarningsToday = EarningsSnapshot(
  total: 145.50,
  trips: 12,
  hours: 8.5,
  avgPerTrip: 12.13,
);

const EarningsSnapshot kEarningsWeek = EarningsSnapshot(
  total: 890.00,
  trips: 68,
  hours: 52.0,
  avgPerTrip: 13.09,
);

const EarningsSnapshot kEarningsMonth = EarningsSnapshot(
  total: 3420.00,
  trips: 245,
  hours: 198.0,
  avgPerTrip: 13.96,
);

const EarningsSnapshot kEarningsYear = EarningsSnapshot(
  total: 3420.00,
  trips: 245,
  hours: 198.0,
  avgPerTrip: 13.96,
);

List<RecentEarning> buildMockRecentEarnings() => const [
  RecentEarning(
    date: 'Today, 2:30 PM',
    customer: 'Ahmed Al-Farsi',
    amount: 18.50,
    status: 'completed',
  ),
  RecentEarning(
    date: 'Today, 12:15 PM',
    customer: 'Sarah Johnson',
    amount: 22.00,
    status: 'completed',
  ),
  RecentEarning(
    date: 'Today, 10:00 AM',
    customer: 'Omar Saeed',
    amount: 15.00,
    status: 'completed',
  ),
  RecentEarning(
    date: 'Yesterday, 6:45 PM',
    customer: 'Fatima Hassan',
    amount: 28.00,
    status: 'completed',
  ),
  RecentEarning(
    date: 'Yesterday, 4:20 PM',
    customer: 'Mohammed K.',
    amount: 12.50,
    status: 'completed',
  ),
];
