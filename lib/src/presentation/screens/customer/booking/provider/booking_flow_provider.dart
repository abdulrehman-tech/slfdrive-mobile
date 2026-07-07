import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../../constants/storage_keys.dart';
import '../../../../../core/data/repositories/booking_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/models/booking/booking_creation_request.dart';
import '../../../../../core/services/booking_lookups.dart';
import '../models/booking_data.dart';
import '../models/booking_step_id.dart';

/// Orchestrates the multi-step booking flow.
///
/// Owns the wrapped [BookingData] `ChangeNotifier`, the active step index, the
/// submission flag, and the validation gates that drive the bottom action bar.
/// Booking creation no longer charges the customer — the booking is created in
/// the backend's default (pending) state; payment happens later from the booking
/// detail screen once an admin approves it.
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
  ///
  /// The vehicle / driver picker steps appear only when that subject is needed
  /// by the service AND wasn't pre-selected (deep-linking from a car/driver
  /// detail screen presets it, so the picker is skipped).
  List<BookingStepId> get steps {
    final service = data.serviceType;
    final needsCar = service?.needsCar == true;
    final needsDriver = service?.needsDriver == true;
    final ids = <BookingStepId>[];
    // Service selector: skipped whenever the flow was entered with a preset
    // service (from a service card, or a car/driver detail screen).
    if (_initialServiceType == null) ids.add(BookingStepId.service);
    ids.add(BookingStepId.corporate);
    ids.add(BookingStepId.dates);
    if (needsCar && _initialCar == null) ids.add(BookingStepId.vehicle);
    if (needsCar) ids.add(BookingStepId.pickup);
    if (needsDriver && _initialDriver == null) ids.add(BookingStepId.driver);
    ids.add(BookingStepId.summary);
    return ids;
  }

  BookingStepId get currentStep => steps[_currentIndex];

  bool get isFirstStep => _currentIndex == 0;
  bool get isLastStep => currentStep == BookingStepId.summary;

  /// Whether the next/confirm action should be enabled for the current step.
  bool get canGoNext {
    switch (currentStep) {
      case BookingStepId.service:
        return data.serviceType != null;
      case BookingStepId.corporate:
        // Personal is always valid; Corporate requires a company pick.
        return !data.isCorporate || data.company != null;
      case BookingStepId.dates:
        return data.startAt != null && data.endAt != null;
      case BookingStepId.vehicle:
        return data.car != null;
      case BookingStepId.pickup:
        if (data.pickupMode == PickupMode.delivery) {
          return data.deliveryLocation != null;
        }
        return true;
      case BookingStepId.driver:
        return data.driver != null;
      case BookingStepId.summary:
        // Block confirm while submitting or while the backend fare is still
        // being fetched — the customer shouldn't confirm before the real total
        // is shown.
        return !_submitting && !data.quoteLoading;
    }
  }

  /// Localization key for the primary action button label.
  String get nextLabelKey {
    if (currentStep == BookingStepId.summary) return 'booking_confirm';
    return 'booking_next';
  }

  /// Whether the bottom bar should surface the total price summary.
  bool get showPrice => currentStep == BookingStepId.summary;

  void goToStep(int index) {
    if (index < 0 || index >= steps.length || index == _currentIndex) return;
    _currentIndex = index;
    notifyListeners();
    _maybeFetchQuote();
  }

  /// Advances to the next step. Returns `true` when the caller should trigger
  /// booking submission (i.e. we're on the final summary step).
  bool advance() {
    if (!canGoNext) return false;
    if (currentStep == BookingStepId.summary) return true;
    if (_currentIndex < steps.length - 1) {
      _currentIndex++;
      notifyListeners();
      _maybeFetchQuote();
    }
    return false;
  }

  /// When the summary step becomes visible, fetch the backend fare quote.
  void _maybeFetchQuote() {
    if (currentStep == BookingStepId.summary) unawaited(refreshQuote());
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

  String? _error;
  String? get error => _error;

  /// Creates the booking in the backend's default (pending) state. No payment
  /// is taken here. Returns `true` once a booking reference has been assigned to
  /// [data]; the caller then navigates to success. On failure returns `false`
  /// and exposes [error].
  Future<bool> submitBooking() async {
    _submitting = true;
    _error = null;
    notifyListeners();
    try {
      final (request, errorKey) = await _buildRequest();
      if (request == null) {
        _error = errorKey;
        return false;
      }

      final created = await getIt<BookingRepository>().create(request);
      final bookingId = created.bookingId;
      if (bookingId == null) {
        _error = 'booking_failed';
        return false;
      }

      data.assignBookingRef(created.bookingNo ?? 'SLF$bookingId', id: bookingId);
      return true;
    } on AppException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _submitting = false;
      notifyListeners();
    }
  }

  /// Fetches the authoritative fare from `POST /api/Booking/pre-booking` for the
  /// current selection and stores it on [data]. Never throws — errors surface
  /// via [BookingData.quoteError] so the summary can fall back gracefully.
  Future<void> refreshQuote() async {
    data.setQuoteLoading();
    try {
      final (request, errorKey) = await _buildRequest();
      if (request == null) {
        data.setQuoteError(errorKey ?? 'booking_failed');
        return;
      }
      final quote = await getIt<BookingRepository>().quote(request);
      data.setQuote(quote);
    } on AppException catch (e) {
      data.setQuoteError(e.message);
    } catch (e) {
      data.setQuoteError(e.toString());
    }
  }

  /// Builds the `BookingCreationRequest` from the current [data]. Shared by the
  /// quote and create calls (same payload shape). Returns `(request, null)` on
  /// success or `(null, errorKey)` when prerequisites are missing.
  Future<(BookingCreationRequest?, String?)> _buildRequest() async {
    final lookups = getIt<BookingLookups>();
    final storage = getIt<FlutterSecureStorage>();
    await lookups.ensureLoaded();

    final userId = int.tryParse(await storage.read(key: StorageKeys.userId) ?? '');
    if (userId == null) return (null, 'not_signed_in');

    final service = data.serviceType ?? BookingServiceType.rentCar;
    final serviceTypeId = lookups.serviceTypeId(service);
    final bookingTypeId = lookups.bookingTypeId(corporate: data.isCorporate);
    if (serviceTypeId == null || bookingTypeId == null) {
      return (null, 'booking_config_unavailable');
    }

    final start = data.startAt ?? DateTime.now();
    final end = data.endAt ?? start;
    // Pickup point = where the vehicle is (its own location). Drop-off is set
    // only when the customer chose delivery.
    final car = data.car;
    final isDelivery = data.pickupMode == PickupMode.delivery;
    final dropOff = isDelivery ? data.deliveryLocation : null;
    // The server derives delivery from the ABSENCE of pickup coordinates on
    // the row. So for delivery we must omit pickUpLat/Lon (and send the
    // drop-off + area); for self-pickup we send the vehicle's coords and no
    // drop-off.
    // Send the times as canonical UTC (trailing `Z`) so the backend never has
    // to guess the zone. A bare local ISO string (no `Z`, no offset) was
    // ambiguous and got mis-shifted (a Jul-4 pickup landed on Jul-3 in the
    // confirmation email). The picker builds LOCAL DateTimes, so `.toUtc()`
    // preserves the correct instant; backend must parse as UTC and convert
    // back to local for display/email.
    final detail = BookingDetailsCreationRequest(
      fromDateTime: start.toUtc().toIso8601String(),
      toDateTime: end.toUtc().toIso8601String(),
      pickUpLat: isDelivery ? null : car?.lat,
      pickUpLon: isDelivery ? null : car?.lon,
      dropOffLat: dropOff?.latitude,
      dropOffLon: dropOff?.longitude,
      // Delivery area drives the server-side fee lookup.
      locationId: isDelivery ? data.deliveryArea?.id : null,
      isDelivery: isDelivery ? true : null,
    );

    // No statusId / paymentTypeId / totalAmount: the backend defaults the
    // status to pending and computes the amount; payment is taken after
    // admin approval.
    final request = BookingCreationRequest(
      userId: userId,
      vehicleId: int.tryParse(data.car?.id ?? ''),
      driverId: int.tryParse(data.driver?.id ?? ''),
      corporateCompanyId: data.isCorporate ? data.company?.id : null,
      bookingTypeId: bookingTypeId,
      serviceTypeId: serviceTypeId,
      bookingDetails: [detail],
    );
    return (request, null);
  }

  void _onDataChange() => notifyListeners();

  @override
  void dispose() {
    data.removeListener(_onDataChange);
    data.dispose();
    super.dispose();
  }
}
