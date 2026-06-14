import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../constants/storage_keys.dart';
import '../../../../../core/data/repositories/booking_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/models/common/pagination_params.dart';
import '../models/booking_item.dart';

class BookingsProvider extends ChangeNotifier {
  BookingsProvider({BookingRepository? repository, FlutterSecureStorage? storage})
      : _repository = repository ?? getIt<BookingRepository>(),
        _storage = storage ?? getIt<FlutterSecureStorage>() {
    load();
  }

  final BookingRepository _repository;
  final FlutterSecureStorage _storage;

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
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
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
