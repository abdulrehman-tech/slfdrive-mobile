import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../data/bookings_mock_data.dart';
import '../models/booking_item.dart';

class BookingsProvider extends ChangeNotifier {
  BookingsProvider({List<BookingItem>? bookings})
    : _bookings = List.of(bookings ?? buildMockBookings());

  final List<BookingItem> _bookings;
  int _tabIndex = 0;

  static const tabKeys = [
    'bookings_tab_upcoming',
    'bookings_tab_active',
    'bookings_tab_completed',
    'bookings_tab_cancelled',
  ];

  static const tabIcons = [
    Iconsax.calendar_tick,
    Iconsax.timer_1,
    Iconsax.tick_circle,
    Iconsax.close_circle,
  ];

  static const tabColors = [
    Color(0xFF3D5AFE),
    Color(0xFFFFA726),
    Color(0xFF4CAF50),
    Color(0xFFE53935),
  ];

  static const statusMap = [
    BookingStatus.confirmed,
    BookingStatus.inProgress,
    BookingStatus.completed,
    BookingStatus.cancelled,
  ];

  static const emptyTitles = [
    'bookings_empty_upcoming',
    'bookings_empty_active',
    'bookings_empty_completed',
    'bookings_empty_cancelled',
  ];

  static const emptySubs = [
    'bookings_empty_upcoming_sub',
    'bookings_empty_active_sub',
    'bookings_empty_completed_sub',
    'bookings_empty_cancelled_sub',
  ];

  int get tabIndex => _tabIndex;
  List<BookingItem> get bookings => List.unmodifiable(_bookings);

  List<BookingItem> get filteredBookings =>
      _bookings.where((b) => b.status == statusMap[_tabIndex]).toList();

  int countForTab(int index) =>
      _bookings.where((b) => b.status == statusMap[index]).length;

  void setTab(int index) {
    if (_tabIndex == index) return;
    _tabIndex = index;
    notifyListeners();
  }
}
