import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

enum BookingStatus { confirmed, inProgress, completed, cancelled }

class BookingItem {
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
