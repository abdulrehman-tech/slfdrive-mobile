import 'package:flutter/material.dart';

import '../../../../../core/data/repositories/booking_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/app_exception.dart';
import '../models/booking_detail.dart';

/// Loads a single booking from `GET /api/Booking/{id}`.
class BookingDetailProvider extends ChangeNotifier {
  BookingDetailProvider({required this.bookingId, BookingRepository? repository})
      : _repository = repository ?? getIt<BookingRepository>() {
    load();
  }

  final int bookingId;
  final BookingRepository _repository;

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
        _booking = BookingDetail.fromBooking(b);
      }
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
