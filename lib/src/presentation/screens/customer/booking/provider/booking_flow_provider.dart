import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:url_launcher/url_launcher.dart';

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
    ids.add(BookingStepId.corporate);
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
      case BookingStepId.corporate:
        // Personal is always valid; Corporate requires an approved org pick.
        return !data.isCorporate || data.organization != null;
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

  String? _error;
  String? get error => _error;

  /// Submits the booking to the backend and, for gateway payment methods,
  /// starts the OmPay checkout. Returns `true` once a real booking reference
  /// has been assigned to [data]; the caller then navigates to success. On
  /// failure returns `false` and exposes [error].
  Future<bool> submitPayment() async {
    _submitting = true;
    _error = null;
    notifyListeners();
    try {
      final repo = getIt<BookingRepository>();
      final lookups = getIt<BookingLookups>();
      final storage = getIt<FlutterSecureStorage>();
      await lookups.ensureLoaded();

      final userId = int.tryParse(await storage.read(key: StorageKeys.userId) ?? '');
      if (userId == null) {
        _error = 'not_signed_in';
        return false;
      }

      final service = data.serviceType ?? BookingServiceType.rentCar;
      final serviceTypeId = lookups.serviceTypeId(service);
      final paymentTypeId = lookups.paymentTypeId(data.paymentMethod);
      final bookingTypeId = lookups.bookingTypeId(corporate: data.isCorporate);
      final statusId = lookups.initialStatusId();
      if (serviceTypeId == null ||
          paymentTypeId == null ||
          bookingTypeId == null ||
          statusId == null) {
        _error = 'booking_config_unavailable';
        return false;
      }

      final start = data.startAt ?? DateTime.now();
      final end = data.endAt ?? start;
      final pickup = data.pickupMode == PickupMode.delivery
          ? data.deliveryLocation
          : data.pickupLocation;
      final detail = BookingDetailsCreationRequest(
        fromDateTime: start.toIso8601String(),
        toDateTime: end.toIso8601String(),
        pickUpLat: pickup?.latitude,
        pickUpLon: pickup?.longitude,
        dropOffLat: data.deliveryLocation?.latitude,
        dropOffLon: data.deliveryLocation?.longitude,
        amount: data.totalPrice,
      );

      final request = BookingCreationRequest(
        userId: userId,
        vehicleId: int.tryParse(data.car?.id ?? ''),
        driverId: int.tryParse(data.driver?.id ?? ''),
        corporateCompanyId:
            data.isCorporate ? int.tryParse(data.organization?.id ?? '') : null,
        totalAmount: data.totalPrice,
        statusId: statusId,
        bookingTypeId: bookingTypeId,
        serviceTypeId: serviceTypeId,
        paymentTypeId: paymentTypeId,
        bookingDetails: [detail],
      );

      final created = await repo.create(request);
      final bookingId = created.bookingId;
      if (bookingId == null) {
        _error = 'booking_failed';
        return false;
      }

      // Gateway payment methods kick off an OmPay checkout. The redirect is
      // opened externally; final reconciliation happens via the backend webhook,
      // so verify here is best-effort and never blocks success.
      if (_usesGateway(data.paymentMethod)) {
        final init = await repo.omPayInit(bookingId, kIsWeb ? 'web' : 'mobile');
        final url = init.redirectUrl ?? init.checkoutJsUrl;
        if (url != null && url.isNotEmpty) {
          final uri = Uri.tryParse(url);
          if (uri != null) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          }
        }
        if (init.orderId != null) {
          try {
            await repo.omPayVerify(bookingId, init.orderId!);
          } catch (_) {
            // pending/failed verification is non-fatal here
          }
        }
      }

      data.assignBookingRef(created.bookingNo ?? 'SLF$bookingId');
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

  bool _usesGateway(PaymentMethod m) =>
      m == PaymentMethod.card ||
      m == PaymentMethod.applePay ||
      m == PaymentMethod.wallet;

  void _onDataChange() => notifyListeners();

  @override
  void dispose() {
    data.removeListener(_onDataChange);
    data.dispose();
    super.dispose();
  }
}
