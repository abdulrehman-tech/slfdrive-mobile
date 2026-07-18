import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../../constants/date_label_keys.dart';
import '../../../../../constants/storage_keys.dart';
import '../../../../../core/data/repositories/booking_repository.dart';
import '../../../../../core/data/repositories/driver_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/models/booking/booking.dart';
import '../../../../../core/models/common/pagination_params.dart';
import '../../../../../core/models/driver/driver_stats.dart';
import '../../../../../core/services/customer_avatars.dart';
import '../../../../../core/services/driver_session.dart';
import '../../../../../core/services/place_namer.dart';
import '../models/day_earning.dart';
import '../models/trip_request.dart';

/// Drives the driver home screen. Trip requests are the driver's *pending*
/// bookings (awaiting their approval) from `POST /api/Booking/my/paginated`;
/// the headline stats are derived from the same fetch. The online/offline
/// toggle is local-only — the backend exposes no driver-presence endpoint.
class DriverHomeProvider extends ChangeNotifier {
  DriverHomeProvider({
    BookingRepository? repository,
    DriverRepository? drivers,
    FlutterSecureStorage? storage,
    DriverSession? session,
    PlaceNamer? placeNamer,
    CustomerAvatars? avatars,
  })  : _repository = repository ?? getIt<BookingRepository>(),
        _drivers = drivers ?? getIt<DriverRepository>(),
        _storage = storage ?? getIt<FlutterSecureStorage>(),
        _session = session ?? getIt<DriverSession>(),
        _placeNamer = placeNamer ?? getIt<PlaceNamer>(),
        _avatars = avatars ?? getIt<CustomerAvatars>() {
    load();
  }

  final BookingRepository _repository;
  final DriverRepository _drivers;
  final FlutterSecureStorage _storage;
  final DriverSession _session;
  final PlaceNamer _placeNamer;
  final CustomerAvatars _avatars;

  bool _isOnline = false;
  bool get isOnline => _isOnline;

  bool _isTogglingOnline = false;
  bool get isTogglingOnline => _isTogglingOnline;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _hasLoaded = false;

  /// True only during the very first load (before any data has arrived) — drives
  /// the full-screen shimmer. Pull-to-refresh reloads don't re-trigger it.
  bool get isInitialLoading => _isLoading && !_hasLoaded;

  String? _error;
  String? get error => _error;

  int? _userId;

  /// Server aggregate (rating / trip counts / earnings); null until loaded or
  /// when the stats call fails — the getters fall back to booking-derived math.
  DriverStats? _stats;

  double _todayEarnings = 0;
  int _totalTrips = 0;
  int _cancelledTrips = 0;

  double get todayEarnings => _todayEarnings;

  /// Completed trips — prefers the server aggregate, falls back to the count
  /// derived from the fetched bookings.
  int get totalTrips => _stats?.completedBookings ?? _totalTrips;

  /// Completion rate = completed / (completed + rejected), as a whole
  /// percentage. Uses the server aggregate when present. '—' until there's any
  /// finished trip to measure.
  String get completionLabel {
    final completed = _stats?.completedBookings ?? _totalTrips;
    final rejected = _stats?.rejectedBookings ?? _cancelledTrips;
    final finished = completed + rejected;
    if (finished == 0) return '—';
    return '${((completed / finished) * 100).round()}%';
  }

  /// Average driver rating from the server, e.g. `4.8`. '—' when the driver has
  /// no reviews yet or stats aren't available.
  String get ratingLabel {
    final r = _stats?.averageRating;
    if (r == null) return '—';
    return r.toStringAsFixed(1);
  }

  /// Rolling 7-day revenue series (oldest → today) for the earnings card graph.
  final List<DayEarning> _weekly = [];
  List<DayEarning> get weekly => List.unmodifiable(_weekly);

  final List<TripRequest> _requests = [];
  List<TripRequest> get requests => List.unmodifiable(_requests);

  /// Flips availability via `POST /api/Driver/toggle-online/{userId}` and
  /// adopts the server's returned state. On failure the toggle is left
  /// unchanged and [error] carries the message.
  Future<void> toggleOnline() async {
    if (_isTogglingOnline || _userId == null) return;
    _isTogglingOnline = true;
    _error = null;
    notifyListeners();
    try {
      _isOnline = await _drivers.toggleOnline(_userId!);
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }
    _isTogglingOnline = false;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _userId = int.tryParse(await _storage.read(key: StorageKeys.userId) ?? '');
      // One driver read gives us both the driver-entity id (for bookings) and
      // the persisted online state; fall back to the session cache for the id.
      final details = _userId == null ? null : await _drivers.getById(_userId!);
      _isOnline = details?.isOnline ?? _isOnline;
      final driverId = details?.driverId ?? await _session.driverId();
      if (_userId != null) {
        _stats = await _drivers.getStats(_userId!);
      }
      final mine = driverId == null
          ? const <Booking>[]
          : (await _repository.driverPaginated(
              driverId,
              const PaginationParams(pageNumber: 1, pageSize: 100),
            )).items;
      _applyStats(mine.toList());
      _buildWeekly(mine.toList());
      await _buildRequests(mine.where(_isPending).toList());
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    _hasLoaded = true;
    notifyListeners();
  }

  /// Buckets completed-booking revenue into the last 7 calendar days ending
  /// today, so the earnings-card bars reflect real data.
  void _buildWeekly(List<Booking> bookings) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final buckets = List<double>.filled(7, 0);
    for (final b in bookings) {
      if (!_isCompleted(b)) continue;
      final when = _completionDay(b);
      if (when == null) continue;
      final day = DateTime(when.year, when.month, when.day);
      final offset = today.difference(day).inDays; // 0 = today
      if (offset < 0 || offset > 6) continue;
      buckets[6 - offset] += b.totalAmount ?? 0;
    }
    _weekly
      ..clear()
      ..addAll(List.generate(7, (i) {
        final day = today.subtract(Duration(days: 6 - i));
        return DayEarning(
          labelKey: DateLabelKeys.dow[day.weekday - 1],
          amount: buckets[i],
          isToday: i == 6,
        );
      }));
  }

  bool _isCompleted(Booking b) {
    final s = '${b.status ?? ''} ${b.statusType ?? ''}'.toLowerCase();
    return b.completedAt != null || s.contains('complete');
  }

  DateTime? _completionDay(Booking b) =>
      DateTime.tryParse(b.completedAt ?? b.toDateTime ?? b.fromDateTime ?? '')?.toLocal();

  /// Resolves pickup/dropoff place names for each pending booking, then builds
  /// the request cards. Names come from [PlaceNamer] (reverse geocode → nearest
  /// area → coords).
  Future<void> _buildRequests(List<Booking> pending) async {
    final built = <TripRequest>[];
    for (final b in pending) {
      final pickup = await _placeNamer.describe(b.pickupLat, b.pickupLon);
      final dropoff = await _placeNamer.describe(b.dropoffLat, b.dropoffLon);
      final avatar = await _avatars.photoUrl(b.userId);
      built.add(TripRequest.fromBooking(b, pickup: pickup, dropoff: dropoff, avatarUrl: avatar));
    }
    _requests
      ..clear()
      ..addAll(built);
    notifyListeners();
  }

  void _applyStats(List<Booking> bookings) {
    final now = DateTime.now();
    var earnings = 0.0;
    var completed = 0;
    var cancelled = 0;
    for (final b in bookings) {
      final s = '${b.status ?? ''} ${b.statusType ?? ''}'.toLowerCase();
      final isCompleted = b.completedAt != null || s.contains('complete');
      final isCancelled = s.contains('reject') || s.contains('cancel');
      if (isCompleted) {
        completed++;
        final when = DateTime.tryParse(b.completedAt ?? b.toDateTime ?? b.fromDateTime ?? '');
        if (when != null && _isSameDay(when.toLocal(), now)) {
          earnings += b.totalAmount ?? 0;
        }
      } else if (isCancelled) {
        cancelled++;
      }
    }
    _todayEarnings = earnings;
    _totalTrips = completed;
    _cancelledTrips = cancelled;
  }

  bool _isPending(Booking b) {
    final s = '${b.status ?? ''} ${b.statusType ?? ''}'.toLowerCase();
    if (s.contains('reject') || s.contains('cancel') || s.contains('complete')) return false;
    return s.contains('pending') || s.contains('new') || (!s.contains('approved'));
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Driver accepts a request (`POST /api/Booking/approve`). Returns true on
  /// success; refreshes the list and stats. On failure [error] holds the message.
  Future<bool> accept(TripRequest request) =>
      _act(() => _repository.approve(id: request.bookingId, confirmedBy: _userId ?? 0));

  /// Driver declines a request (`POST /api/Booking/reject`).
  Future<bool> decline(TripRequest request) =>
      _act(() => _repository.reject(id: request.bookingId, confirmedBy: _userId ?? 0));

  Future<bool> _act(Future<bool> Function() action) async {
    try {
      await action();
      await load();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }
}
