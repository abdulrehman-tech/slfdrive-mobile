import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../../constants/storage_keys.dart';
import '../../../../../core/data/repositories/booking_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/models/booking/booking.dart';
import '../../../../../core/models/common/pagination_params.dart';
import '../../../../../core/services/customer_avatars.dart';
import '../../../../../core/services/driver_session.dart';
import '../../../../../core/services/place_namer.dart';
import '../models/trip_request.dart';

/// Drives the driver home screen. Trip requests are the driver's *pending*
/// bookings (awaiting their approval) from `POST /api/Booking/my/paginated`;
/// the headline stats are derived from the same fetch. The online/offline
/// toggle is local-only — the backend exposes no driver-presence endpoint.
class DriverHomeProvider extends ChangeNotifier {
  DriverHomeProvider({
    BookingRepository? repository,
    FlutterSecureStorage? storage,
    DriverSession? session,
    PlaceNamer? placeNamer,
    CustomerAvatars? avatars,
  })  : _repository = repository ?? getIt<BookingRepository>(),
        _storage = storage ?? getIt<FlutterSecureStorage>(),
        _session = session ?? getIt<DriverSession>(),
        _placeNamer = placeNamer ?? getIt<PlaceNamer>(),
        _avatars = avatars ?? getIt<CustomerAvatars>() {
    load();
  }

  final BookingRepository _repository;
  final FlutterSecureStorage _storage;
  final DriverSession _session;
  final PlaceNamer _placeNamer;
  final CustomerAvatars _avatars;

  bool _isOnline = true;
  bool get isOnline => _isOnline;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  int? _userId;

  double _todayEarnings = 0;
  int _totalTrips = 0;
  int _cancelledTrips = 0;

  double get todayEarnings => _todayEarnings;
  int get totalTrips => _totalTrips;

  /// Completion rate = completed / (completed + cancelled), as a whole
  /// percentage. '—' until there's any finished trip to measure.
  String get completionLabel {
    final finished = _totalTrips + _cancelledTrips;
    if (finished == 0) return '—';
    return '${((_totalTrips / finished) * 100).round()}%';
  }

  /// No per-driver rating aggregate exists on the backend yet.
  String get ratingLabel => '—';

  final List<TripRequest> _requests = [];
  List<TripRequest> get requests => List.unmodifiable(_requests);

  void toggleOnline() {
    _isOnline = !_isOnline;
    notifyListeners();
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _userId = int.tryParse(await _storage.read(key: StorageKeys.userId) ?? '');
      final driverId = await _session.driverId();
      final mine = driverId == null
          ? const <Booking>[]
          : (await _repository.driverPaginated(
              driverId,
              const PaginationParams(pageNumber: 1, pageSize: 100),
            )).items;
      _applyStats(mine.toList());
      await _buildRequests(mine.where(_isPending).toList());
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

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
