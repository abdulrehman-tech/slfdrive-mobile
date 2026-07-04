import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../constants/storage_keys.dart';
import '../../../../../core/data/repositories/booking_repository.dart';
import '../../../../../core/data/repositories/driver_listing_repository.dart';
import '../../../../../core/data/repositories/vehicle_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/models/common/pagination_params.dart';
import '../../../../../core/models/driver/driver_listing_item.dart';
import '../models/booking_item.dart';

class BookingsProvider extends ChangeNotifier {
  BookingsProvider({
    BookingRepository? repository,
    FlutterSecureStorage? storage,
    VehicleRepository? vehicleRepository,
    DriverListingRepository? driverRepository,
  })  : _repository = repository ?? getIt<BookingRepository>(),
        _storage = storage ?? getIt<FlutterSecureStorage>(),
        _vehicles = vehicleRepository ?? getIt<VehicleRepository>(),
        _drivers = driverRepository ?? getIt<DriverListingRepository>() {
    load();
  }

  final BookingRepository _repository;
  final FlutterSecureStorage _storage;
  final VehicleRepository _vehicles;
  final DriverListingRepository _drivers;

  final List<BookingItem> _bookings = [];
  int _tabIndex = 0;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final userId = int.tryParse(await _storage.read(key: StorageKeys.userId) ?? '');
      final page = await _repository.myPaginated(
        PaginationParams(pageNumber: 1, pageSize: 50, userId: userId),
      );
      _bookings
        ..clear()
        ..addAll(page.items.map(BookingItem.fromBooking));
      // Wait for the vehicle/driver thumbnails to resolve before showing the
      // list, so it renders complete rather than filling in behind the user.
      await _enrich();
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Best-effort: fill vehicle name/photo (per unique vehicleId) and driver
  /// name/photo (one shared driver-list fetch, matched by `driverId`).
  Future<void> _enrich() async {
    final vehicleIds = _bookings.map((b) => b.vehicleId).whereType<int>().toSet();
    final needDrivers = _bookings.any((b) => b.driverId != null);

    // Drivers: single paginated fetch, indexed by driverId.
    Map<int, DriverListingItem> driversById = const {};
    if (needDrivers) {
      try {
        final page = await _drivers.getPaginated(
          const PaginationParams(pageNumber: 1, pageSize: 100),
        );
        driversById = {
          for (final d in page.items)
            if (d.driverId != null) d.driverId!: d,
        };
      } catch (_) {/* keep base */}
    }

    // Vehicles: one fetch per unique id, in parallel.
    final vehicles = <int, ({String name, String? image})>{};
    await Future.wait(vehicleIds.map((id) async {
      try {
        final v = await _vehicles.getById(id);
        if (v != null) vehicles[id] = (name: v.displayTitle(), image: v.primaryPhoto);
      } catch (_) {/* keep base */}
    }));

    for (var i = 0; i < _bookings.length; i++) {
      final b = _bookings[i];
      final v = b.vehicleId != null ? vehicles[b.vehicleId] : null;
      final d = b.driverId != null ? driversById[b.driverId] : null;
      if (v == null && d == null) continue;
      _bookings[i] = b.copyWith(
        vehicleName: v?.name,
        vehicleImageUrl: v?.image,
        driverName: d?.displayName(),
        driverPhotoUrl: d?.resolvedPhotoUrl,
      );
    }
  }

  static const tabKeys = [
    'bookings_tab_pending',
    'bookings_tab_approved',
    'bookings_tab_completed',
    'bookings_tab_rejected',
  ];

  static const tabIcons = [
    Iconsax.clock,
    Iconsax.tick_circle,
    Iconsax.medal_star,
    Iconsax.close_circle,
  ];

  static const tabColors = [
    Color(0xFFFFA726),
    Color(0xFF3D5AFE),
    Color(0xFF4CAF50),
    Color(0xFFE53935),
  ];

  static const statusMap = [
    BookingStatus.pending,
    BookingStatus.approved,
    BookingStatus.completed,
    BookingStatus.rejected,
  ];

  static const emptyTitles = [
    'bookings_empty_pending',
    'bookings_empty_approved',
    'bookings_empty_completed',
    'bookings_empty_rejected',
  ];

  static const emptySubs = [
    'bookings_empty_pending_sub',
    'bookings_empty_approved_sub',
    'bookings_empty_completed_sub',
    'bookings_empty_rejected_sub',
  ];

  int get tabIndex => _tabIndex;
  List<BookingItem> get bookings => List.unmodifiable(_bookings);

  /// Corporate-approved bookings live under the "approved" tab.
  bool _matchesTab(BookingItem b, int index) {
    final target = statusMap[index];
    if (target == BookingStatus.approved) {
      return b.status == BookingStatus.approved ||
          b.status == BookingStatus.corporateApproved;
    }
    return b.status == target;
  }

  List<BookingItem> get filteredBookings =>
      _bookings.where((b) => _matchesTab(b, _tabIndex)).toList();

  int countForTab(int index) =>
      _bookings.where((b) => _matchesTab(b, index)).length;

  void setTab(int index) {
    if (_tabIndex == index) return;
    _tabIndex = index;
    notifyListeners();
  }
}
