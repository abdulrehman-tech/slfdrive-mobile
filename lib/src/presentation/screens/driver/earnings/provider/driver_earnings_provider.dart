import 'package:flutter/foundation.dart';

import '../../../../../core/data/repositories/booking_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/models/booking/booking.dart';
import '../../../../../core/models/common/pagination_params.dart';
import '../../../../../core/services/driver_session.dart';
import '../models/earnings_period.dart';

/// Derives the driver's earnings from completed bookings
/// (`POST /api/Booking/paginated`, filtered client-side to the signed-in
/// driver's `driverId`). The backend has no earnings-aggregate endpoint, so
/// totals/trip-counts/hours are computed client-side per period.
class DriverEarningsProvider extends ChangeNotifier {
  DriverEarningsProvider({
    BookingRepository? repository,
    DriverSession? session,
  })  : _repository = repository ?? getIt<BookingRepository>(),
        _session = session ?? getIt<DriverSession>() {
    load();
  }

  final BookingRepository _repository;
  final DriverSession _session;

  EarningsPeriod _period = EarningsPeriod.today;

  /// Completed bookings paired with their completion timestamp (best-effort).
  final List<({Booking booking, DateTime when})> _completed = [];

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  static const periodKeys = [
    'earnings_today',
    'earnings_week',
    'earnings_month',
    'earnings_year',
  ];

  EarningsPeriod get period => _period;
  int get periodIndex => _period.index;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final driverId = await _session.driverId();
      final mine = driverId == null
          ? const <Booking>[]
          : (await _repository.driverPaginated(
              driverId,
              const PaginationParams(pageNumber: 1, pageSize: 200),
            )).items;
      _completed
        ..clear()
        ..addAll(mine.where(_isCompleted).map((b) {
          final when = DateTime.tryParse(b.completedAt ?? b.toDateTime ?? b.fromDateTime ?? '')?.toLocal()
              ?? DateTime.now();
          return (booking: b, when: when);
        }));
      _completed.sort((a, b) => b.when.compareTo(a.when));
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  bool _isCompleted(Booking b) {
    final s = '${b.status ?? ''} ${b.statusType ?? ''}'.toLowerCase();
    return b.completedAt != null || s.contains('complete');
  }

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
    final rows = _completed.where((r) => _inPeriod(r.when, _period)).toList();
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

  void setPeriodIndex(int index) {
    final next = EarningsPeriod.values[index];
    if (_period == next) return;
    _period = next;
    notifyListeners();
  }
}
