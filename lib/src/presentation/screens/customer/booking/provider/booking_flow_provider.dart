import 'dart:math';

import 'package:flutter/foundation.dart';

import '../models/booking_data.dart';
import '../models/booking_step_id.dart';

/// Orchestrates the multi-step booking flow.
///
/// Owns the wrapped [BookingData] `ChangeNotifier`, the active step index, the
/// submission flag, and the validation gates that drive the bottom action bar.
/// The screen becomes a thin composer that simply reads from here and rebuilds
/// on notification.
class BookingFlowProvider extends ChangeNotifier {
  BookingFlowProvider({
    BookingServiceType? initialServiceType,
    BookingCar? initialCar,
    BookingDriver? initialDriver,
  })  : _initialServiceType = initialServiceType,
        _initialCar = initialCar,
        _initialDriver = initialDriver,
        data = BookingData(
          initialServiceType: initialServiceType,
          initialCar: initialCar,
          initialDriver: initialDriver,
        ) {
    // Seed sensible defaults BEFORE attaching the listener so the notify fired
    // by setDates doesn't trigger rebuilds during the initial build phase.
    if (data.startAt == null) {
      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      data.setDates(start, start.add(const Duration(days: 2)));
    }
    data.addListener(_onDataChange);
  }

  final BookingData data;
  final BookingServiceType? _initialServiceType;
  final BookingCar? _initialCar;
  final BookingDriver? _initialDriver;

  int _currentIndex = 0;
  bool _submitting = false;

  int get currentIndex => _currentIndex;
  bool get submitting => _submitting;

  /// Visible steps filtered by service type & entry context.
  List<BookingStepId> get steps {
    final service = data.serviceType;
    final ids = <BookingStepId>[];
    // Service selector: skipped if the flow was entered with a preset service
    // + subject (typical when entering from car or driver detail).
    final skipService =
        _initialServiceType != null && (_initialCar != null || _initialDriver != null);
    if (!skipService) ids.add(BookingStepId.service);
    ids.add(BookingStepId.dates);
    if (service != BookingServiceType.driverOnly) ids.add(BookingStepId.pickup);
    if (service != BookingServiceType.driverOnly) ids.add(BookingStepId.extras);
    if (service == BookingServiceType.carWithDriver || service == BookingServiceType.driverOnly) {
      ids.add(BookingStepId.driver);
    }
    ids.add(BookingStepId.summary);
    ids.add(BookingStepId.payment);
    return ids;
  }

  BookingStepId get currentStep => steps[_currentIndex];

  bool get isFirstStep => _currentIndex == 0;
  bool get isLastStep => currentStep == BookingStepId.payment;

  /// Whether the next/confirm/pay action should be enabled for the current step.
  bool get canGoNext {
    switch (currentStep) {
      case BookingStepId.service:
        return data.serviceType != null;
      case BookingStepId.dates:
        return data.startAt != null && data.endAt != null;
      case BookingStepId.pickup:
        if (data.pickupMode == PickupMode.delivery) {
          return data.deliveryLocation != null;
        }
        return true;
      case BookingStepId.extras:
        return true;
      case BookingStepId.driver:
        return data.driver != null;
      case BookingStepId.summary:
        return true;
      case BookingStepId.payment:
        return !_submitting;
    }
  }

  /// Localization key for the primary action button label.
  String get nextLabelKey {
    if (currentStep == BookingStepId.payment) return 'booking_pay_now';
    if (currentStep == BookingStepId.summary) return 'booking_confirm_review';
    return 'booking_next';
  }

  /// Whether the bottom bar should surface the total price summary.
  bool get showPrice =>
      currentStep == BookingStepId.summary || currentStep == BookingStepId.payment;

  void goToStep(int index) {
    if (index < 0 || index >= steps.length || index == _currentIndex) return;
    _currentIndex = index;
    notifyListeners();
  }

  /// Advances to the next step. Returns `true` when the caller should trigger
  /// the payment submission flow (i.e. we're on the final step).
  bool advance() {
    if (!canGoNext) return false;
    if (currentStep == BookingStepId.payment) return true;
    if (_currentIndex < steps.length - 1) {
      _currentIndex++;
      notifyListeners();
    }
    return false;
  }

  /// Moves back one step. Returns `true` when already at the first step —
  /// the caller should then pop the screen.
  bool goBack() {
    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
      return false;
    }
    return true;
  }

  /// Simulates payment submission. Resolves once a booking reference has been
  /// assigned to the underlying [BookingData]; the caller is then responsible
  /// for navigating to the success screen.
  Future<void> submitPayment() async {
    _submitting = true;
    notifyListeners();
    await Future<void>.delayed(const Duration(milliseconds: 1200));
    data.assignBookingRef(_generateRef());
    _submitting = false;
    notifyListeners();
  }

  String _generateRef() {
    final rand = Random();
    final code = List.generate(6, (_) => rand.nextInt(10)).join();
    return 'SLF$code';
  }

  void _onDataChange() => notifyListeners();

  @override
  void dispose() {
    data.removeListener(_onDataChange);
    data.dispose();
    super.dispose();
  }
}
