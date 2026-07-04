import 'package:flutter/material.dart';

import '../../../../../constants/endpoints.dart';
import '../../../../../core/data/repositories/booking_repository.dart';
import '../../../../../core/data/repositories/driver_listing_repository.dart';
import '../../../../../core/data/repositories/vehicle_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/models/common/pagination_params.dart';
import '../models/booking_detail.dart';

/// Loads a single booking from `GET /api/Booking/{id}` and enriches it with the
/// vehicle (`Vehicle/{id}`) and driver details — `BookingResponseDto` only
/// carries the ids, not the vehicle image/plate or driver photo.
class BookingDetailProvider extends ChangeNotifier {
  BookingDetailProvider({
    required this.bookingId,
    this.seed,
    BookingRepository? repository,
    VehicleRepository? vehicleRepository,
    DriverListingRepository? driverRepository,
  })  : _repository = repository ?? getIt<BookingRepository>(),
        _vehicles = vehicleRepository ?? getIt<VehicleRepository>(),
        _drivers = driverRepository ?? getIt<DriverListingRepository>() {
    load();
  }

  final int bookingId;

  /// Optional vehicle/driver display values from the bookings list, applied to
  /// the first paint so the card image/name show without waiting for re-fetch.
  final BookingDetailSeed? seed;
  final BookingRepository _repository;
  final VehicleRepository _vehicles;
  final DriverListingRepository _drivers;

  BookingDetail? _booking;
  BookingDetail? get booking => _booking;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final b = await _repository.getById(bookingId);
      if (b == null) {
        _error = 'booking_not_found';
      } else {
        var detail = BookingDetail.fromBooking(b);
        // Apply the list-supplied seed so the image/name are present even if
        // enrichment can't add more.
        if (seed != null) {
          detail = detail.copyWith(
            carName: seed!.vehicleName,
            carImageUrl: seed!.vehicleImageUrl,
            driverName: seed!.driverName,
            driverAvatar: seed!.driverPhotoUrl,
          );
        }
        // Wait for vehicle/driver/payment enrichment to finish before the first
        // paint so the screen renders complete instead of filling in behind the
        // user. The skeleton stays up for the whole chain.
        _booking = await _enrich(detail);
      }
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  /// Best-effort enrichment — failures leave the base detail untouched.
  Future<BookingDetail> _enrich(BookingDetail detail) async {
    var out = detail;
    // Vehicle: keyed directly by vehicleId.
    if (detail.vehicleId != null) {
      try {
        final v = await _vehicles.getById(detail.vehicleId!);
        if (v != null) {
          out = out.copyWith(
            carName: v.displayTitle(),
            carImageUrl: v.primaryPhoto ?? '',
            brand: v.brandName ?? '',
            plateNumber: v.plateNumber ?? '',
            companyName: v.companyName,
            color: v.color,
            year: v.year,
            seats: v.seats,
            transmission: v.transmissionTypeName,
            fuelType: v.fuelTypeName,
            vehicleType: v.vehicleTypeName,
            vehicleLocation: v.locationName,
          );
        }
      } catch (_) {/* keep base */}
    }
    // Driver: the booking stores the entity `driverId`, but Driver/{id} is keyed
    // by the listing id — so find the matching driver in the paginated list.
    if (detail.driverId != null) {
      try {
        final page = await _drivers.getPaginated(
          const PaginationParams(pageNumber: 1, pageSize: 100),
        );
        final match = page.items.where((d) => d.driverId == detail.driverId).toList();
        if (match.isNotEmpty) {
          final d = match.first;
          out = out.copyWith(
            driverName: d.displayName(),
            driverAvatar: d.resolvedPhotoUrl ?? ApiEndpoints.resolveMediaUrl(d.photoUrl) ?? '',
            driverExperienceYears: d.yearsOfExperience,
            driverLanguages: d.languagesKnown,
            driverLocation: d.locationName,
          );
        }
      } catch (_) {/* keep base */}
    }
    // Payment method (cash / card / OmPay): the booking DTO only carries payment
    // status, so read the settled payment record when the booking is paid.
    if (out.isPaid) {
      try {
        final payment = await _repository.paymentForBooking(out.id);
        if (payment?.paymentTypeName != null) {
          out = out.copyWith(paymentMethodName: payment!.paymentTypeName);
        }
      } catch (_) {/* keep base */}
    }
    return out;
  }
}
