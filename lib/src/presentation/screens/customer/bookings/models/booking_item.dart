import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../core/models/booking/booking.dart';

enum BookingStatus { confirmed, inProgress, completed, cancelled }

class BookingItem {
  final int id;
  final String carName;
  final String carImageUrl;
  final String pickupDate;
  final String dropoffDate;
  final String pickupLocation;
  final double totalPrice;
  final BookingStatus status;
  final String? driverName;
  final String? driverAvatarUrl;

  const BookingItem({
    required this.id,
    required this.carName,
    required this.carImageUrl,
    required this.pickupDate,
    required this.dropoffDate,
    required this.pickupLocation,
    required this.totalPrice,
    required this.status,
    this.driverName,
    this.driverAvatarUrl,
  });

  /// Maps a backend [Booking] (from `Booking/my/paginated`) to the list item.
  /// `BookingResponseDto` doesn't carry a vehicle display name, so the title
  /// falls back to the service type / booking number.
  factory BookingItem.fromBooking(Booking b) {
    String date(String? iso) => (iso == null || iso.length < 10) ? '' : iso.substring(0, 10);
    return BookingItem(
      id: b.id,
      carName: b.serviceType?.trim().isNotEmpty == true
          ? b.serviceType!
          : (b.bookingNo ?? 'Booking #${b.id}'),
      carImageUrl: '',
      pickupDate: date(b.fromDateTime),
      dropoffDate: date(b.toDateTime),
      pickupLocation: '',
      totalPrice: b.totalAmount ?? 0,
      status: bookingStatusFromApi(b),
      driverName: b.driverFullName,
      driverAvatarUrl: null,
    );
  }
}

/// Resolves the backend status string onto the UI's [BookingStatus] tabs.
BookingStatus bookingStatusFromApi(Booking b) {
  final s = '${b.status ?? ''} ${b.statusType ?? ''}'.toLowerCase();
  if (s.contains('cancel') || s.contains('reject')) return BookingStatus.cancelled;
  if (b.completedAt != null || s.contains('complete')) return BookingStatus.completed;
  if (s.contains('progress') ||
      s.contains('active') ||
      s.contains('ongoing') ||
      s.contains('trip') ||
      s.contains('picked')) {
    return BookingStatus.inProgress;
  }
  return BookingStatus.confirmed;
}

extension BookingStatusX on BookingStatus {
  Color get color {
    switch (this) {
      case BookingStatus.confirmed:
        return const Color(0xFF3D5AFE);
      case BookingStatus.inProgress:
        return const Color(0xFFFFA726);
      case BookingStatus.completed:
        return const Color(0xFF4CAF50);
      case BookingStatus.cancelled:
        return const Color(0xFFE53935);
    }
  }

  IconData get icon {
    switch (this) {
      case BookingStatus.confirmed:
        return Iconsax.calendar_tick;
      case BookingStatus.inProgress:
        return Iconsax.timer_1;
      case BookingStatus.completed:
        return Iconsax.tick_circle;
      case BookingStatus.cancelled:
        return Iconsax.close_circle;
    }
  }

  String get label {
    switch (this) {
      case BookingStatus.confirmed:
        return 'bookings_status_confirmed'.tr();
      case BookingStatus.inProgress:
        return 'bookings_status_in_progress'.tr();
      case BookingStatus.completed:
        return 'bookings_status_completed'.tr();
      case BookingStatus.cancelled:
        return 'bookings_status_cancelled'.tr();
    }
  }
}
