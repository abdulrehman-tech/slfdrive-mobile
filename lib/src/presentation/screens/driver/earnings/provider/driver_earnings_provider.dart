import 'package:flutter/foundation.dart';

import '../data/driver_earnings_mock_data.dart';
import '../models/earnings_period.dart';

class DriverEarningsProvider extends ChangeNotifier {
  DriverEarningsProvider({List<RecentEarning>? recentEarnings})
    : _recentEarnings = List.of(recentEarnings ?? buildMockRecentEarnings());

  EarningsPeriod _period = EarningsPeriod.today;
  final List<RecentEarning> _recentEarnings;

  static const periodKeys = [
    'earnings_today',
    'earnings_week',
    'earnings_month',
    'earnings_year',
  ];

  EarningsPeriod get period => _period;
  int get periodIndex => _period.index;
  List<RecentEarning> get recentEarnings =>
      List.unmodifiable(_recentEarnings);

  EarningsSnapshot get snapshot {
    switch (_period) {
      case EarningsPeriod.today:
        return kEarningsToday;
      case EarningsPeriod.week:
        return kEarningsWeek;
      case EarningsPeriod.month:
        return kEarningsMonth;
      case EarningsPeriod.year:
        return kEarningsYear;
    }
  }

  void setPeriodIndex(int index) {
    final next = EarningsPeriod.values[index];
    if (_period == next) return;
    _period = next;
    notifyListeners();
  }
}
