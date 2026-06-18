import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../core/models/booking/booking.dart';

/// Backend booking lifecycle (booking_status): pending → approved → completed,
/// or rejected. (`CorporateApproved` folds into approved.)
enum BookingStatus { pending, approved, completed, rejected }

/// What was booked, from the service type (vehicle / driver / vehicle-with-driver).
enum BookingServiceKind { vehicle, driver, vehicleWithDriver }

class BookingItem {
  final int id;
  final String bookingNo;
  final BookingServiceKind kind;
  final BookingStatus status;
  final bool isPaid;
  final String pickupDate;
  final String dropoffDate;
  final double totalPrice;
  final int? vehicleId;
  final int? driverId;
  final String? vehicleName;
  final String? vehicleImageUrl;
  final String? driverName;
  final String? driverPhotoUrl;

  const BookingItem({
    required this.id,
    required this.bookingNo,
    required this.kind,
    required this.status,
    required this.isPaid,
    required this.pickupDate,
    required this.dropoffDate,
    required this.totalPrice,
    this.vehicleId,
    this.driverId,
    this.vehicleName,
    this.vehicleImageUrl,
    this.driverName,
    this.driverPhotoUrl,
  });

  /// Customer can pay once approved and not yet paid.
  bool get canPay => status == BookingStatus.approved && !isPaid;

  /// Headline for the card: vehicle name when known; for a driver hire, the
  /// driver name; otherwise the service label.
  String get title {
    if (vehicleName != null && vehicleName!.isNotEmpty) return vehicleName!;
    if (driverName != null && driverName!.isNotEmpty) return driverName!;
    return kind.title;
  }

  /// Thumbnail: vehicle photo when present, otherwise the driver photo (driver
  /// hire). Null → the card falls back to the service-kind icon.
  String? get thumbnailUrl {
    if (vehicleImageUrl != null && vehicleImageUrl!.isNotEmpty) return vehicleImageUrl;
    if (driverPhotoUrl != null && driverPhotoUrl!.isNotEmpty) return driverPhotoUrl;
    return null;
  }

  BookingItem copyWith({
    String? vehicleName,
    String? vehicleImageUrl,
    String? driverName,
    String? driverPhotoUrl,
  }) {
    return BookingItem(
      id: id,
      bookingNo: bookingNo,
      kind: kind,
      status: status,
      isPaid: isPaid,
      pickupDate: pickupDate,
      dropoffDate: dropoffDate,
      totalPrice: totalPrice,
      vehicleId: vehicleId,
      driverId: driverId,
      vehicleName: vehicleName ?? this.vehicleName,
      vehicleImageUrl: vehicleImageUrl ?? this.vehicleImageUrl,
      driverName: driverName ?? this.driverName,
      driverPhotoUrl: driverPhotoUrl ?? this.driverPhotoUrl,
    );
  }

  factory BookingItem.fromBooking(Booking b) {
    String date(String? iso) => (iso == null || iso.length < 10) ? '' : iso.substring(0, 10);
    return BookingItem(
      id: b.id,
      bookingNo: b.bookingNo ?? 'SLF${b.id}',
      kind: serviceKindFromApi(b),
      status: bookingStatusFromApi(b),
      isPaid: (b.paymentStatus ?? '').toLowerCase().contains('paid'),
      pickupDate: date(b.fromDateTime),
      dropoffDate: date(b.toDateTime),
      totalPrice: b.totalAmount ?? 0,
      vehicleId: b.vehicleId,
      driverId: b.driverId,
      driverName: b.driverFullName,
    );
  }
}

/// Maps the backend booking_status string onto the four UI states.
BookingStatus bookingStatusFromApi(Booking b) {
  final s = '${b.status ?? ''} ${b.statusType ?? ''}'.toLowerCase();
  if (s.contains('reject') || s.contains('cancel')) return BookingStatus.rejected;
  if (b.completedAt != null || s.contains('complete')) return BookingStatus.completed;
  if (s.contains('approved')) return BookingStatus.approved; // incl. CorporateApproved
  return BookingStatus.pending;
}

/// Maps service_type (name or id) onto the service kind.
BookingServiceKind serviceKindFromApi(Booking b) {
  final s = (b.serviceType ?? '').toLowerCase();
  if (s.contains('with')) return BookingServiceKind.vehicleWithDriver; // vehicle-with-driver
  if (s.contains('driver')) return BookingServiceKind.driver;
  if (s.contains('vehicle')) return BookingServiceKind.vehicle;
  switch (b.serviceTypeId) {
    case 11:
      return BookingServiceKind.vehicleWithDriver;
    case 9:
      return BookingServiceKind.driver;
    default:
      return BookingServiceKind.vehicle;
  }
}

extension BookingStatusX on BookingStatus {
  Color get color {
    switch (this) {
      case BookingStatus.pending:
        return const Color(0xFFFFA726);
      case BookingStatus.approved:
        return const Color(0xFF3D5AFE);
      case BookingStatus.completed:
        return const Color(0xFF4CAF50);
      case BookingStatus.rejected:
        return const Color(0xFFE53935);
    }
  }

  IconData get icon {
    switch (this) {
      case BookingStatus.pending:
        return Iconsax.clock;
      case BookingStatus.approved:
        return Iconsax.tick_circle;
      case BookingStatus.completed:
        return Iconsax.medal_star;
      case BookingStatus.rejected:
        return Iconsax.close_circle;
    }
  }

  String get label {
    switch (this) {
      case BookingStatus.pending:
        return 'bookings_status_pending'.tr();
      case BookingStatus.approved:
        return 'bookings_status_approved'.tr();
      case BookingStatus.completed:
        return 'bookings_status_completed'.tr();
      case BookingStatus.rejected:
        return 'bookings_status_rejected'.tr();
    }
  }
}

extension BookingServiceKindX on BookingServiceKind {
  IconData get icon {
    switch (this) {
      case BookingServiceKind.vehicle:
        return Iconsax.car_copy;
      case BookingServiceKind.driver:
        return Iconsax.profile_2user_copy;
      case BookingServiceKind.vehicleWithDriver:
        return Iconsax.driver_copy;
    }
  }

  Color get color {
    switch (this) {
      case BookingServiceKind.vehicle:
        return const Color(0xFF3D5AFE);
      case BookingServiceKind.driver:
        return const Color(0xFF00BCD4);
      case BookingServiceKind.vehicleWithDriver:
        return const Color(0xFF7C4DFF);
    }
  }

  String get title {
    switch (this) {
      case BookingServiceKind.vehicle:
        return 'booking_kind_vehicle'.tr();
      case BookingServiceKind.driver:
        return 'booking_kind_driver'.tr();
      case BookingServiceKind.vehicleWithDriver:
        return 'booking_kind_vehicle_driver'.tr();
    }
  }
}
