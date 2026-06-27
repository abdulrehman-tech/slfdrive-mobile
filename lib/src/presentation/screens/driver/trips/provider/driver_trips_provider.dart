import 'package:flutter/foundation.dart';

import '../../../../../core/data/repositories/booking_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/models/booking/booking.dart';
import '../../../../../core/models/common/pagination_params.dart';
import '../../../../../core/services/customer_avatars.dart';
import '../../../../../core/services/driver_session.dart';
import '../../../../../core/services/place_namer.dart';
import '../models/driver_trip.dart';

/// Drives the driver's trips screen from `POST /api/Booking/paginated`,
/// keeping only rows whose `driverId` matches the signed-in driver (filtered
/// client-side — the backend list isn't driver-scoped). Bookings still pending
/// the driver's approval are excluded here — they appear as requests on home.
class DriverTripsProvider extends ChangeNotifier {
  DriverTripsProvider({
    BookingRepository? repository,
    DriverSession? session,
    PlaceNamer? placeNamer,
    CustomerAvatars? avatars,
  })  : _repository = repository ?? getIt<BookingRepository>(),
        _session = session ?? getIt<DriverSession>(),
        _placeNamer = placeNamer ?? getIt<PlaceNamer>(),
        _avatars = avatars ?? getIt<CustomerAvatars>() {
    load();
  }

  final BookingRepository _repository;
  final DriverSession _session;
  final PlaceNamer _placeNamer;
  final CustomerAvatars _avatars;

  final List<DriverTrip> _trips = [];
  int _tabIndex = 0; // 0=active, 1=completed, 2=cancelled

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  static const tabKeys = [
    'trips_active',
    'trips_completed',
    'trips_cancelled',
  ];

  static const statusMap = [
    DriverTripStatus.active,
    DriverTripStatus.completed,
    DriverTripStatus.cancelled,
  ];

  static const emptyTitles = [
    'trips_no_active',
    'trips_no_completed',
    'trips_no_cancelled',
  ];

  static const emptySubs = [
    'trips_no_active_desc',
    'trips_no_completed_desc',
    'trips_no_cancelled_desc',
  ];

  int get tabIndex => _tabIndex;
  List<DriverTrip> get trips => List.unmodifiable(_trips);

  List<DriverTrip> get filteredTrips =>
      _trips.where((t) => t.status == statusMap[_tabIndex]).toList();

  int countForTab(int index) =>
      _trips.where((t) => t.status == statusMap[index]).length;

  void setTab(int index) {
    if (_tabIndex == index) return;
    _tabIndex = index;
    notifyListeners();
  }

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
              const PaginationParams(pageNumber: 1, pageSize: 100),
            )).items;
      final built = <DriverTrip>[];
      for (final b in mine) {
        final pickup = await _placeNamer.describe(b.pickupLat, b.pickupLon);
        final dropoff = await _placeNamer.describe(b.dropoffLat, b.dropoffLon);
        final avatar = await _avatars.photoUrl(b.userId);
        final t = DriverTrip.fromBooking(b, pickupName: pickup, dropoffName: dropoff, avatarUrl: avatar);
        if (t != null) built.add(t);
      }
      _trips
        ..clear()
        ..addAll(built);
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Marks an active trip complete (`POST /api/Booking/{id}/complete`), then
  /// refreshes. Returns true on success; on failure [error] holds the message.
  Future<bool> completeTrip(int bookingId) async {
    try {
      await _repository.complete(bookingId);
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
