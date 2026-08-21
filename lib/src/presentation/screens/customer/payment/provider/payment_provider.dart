import 'package:flutter/foundation.dart';

import '../../../../../core/data/repositories/booking_repository.dart';
import '../../../../../core/data/repositories/lookup_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/models/common/general_lookup.dart';
import '../../../../../core/services/booking_lookups.dart';
import '../../booking_detail/widgets/ompay_webview_page.dart';

/// Stage of the pay action, so the UI can show what's happening instead of a
/// single opaque spinner covering the whole init → checkout → verify chain.
enum PaymentPhase { idle, startingCheckout, awaitingGateway, verifying, recording }

/// Terminal result of a gateway attempt.
enum PaymentOutcome { paid, pending, cancelled, failed }

/// What the screen needs to open the OmPay checkout WebView.
class OmPayStart {
  final String url;
  final List<String> returnUrlMarkers;
  final String? orderId;
  const OmPayStart({required this.url, required this.returnUrlMarkers, this.orderId});
}

/// State for paying an approved booking.
///
/// Payment methods come from the company-scoped
/// `GET /api/GeneralType/company/{companyId}?type=payment_type` (the backend
/// already falls back to the default rows when the company has no mapping);
/// when that call fails or no company id is known, the cached active
/// `payment_type` general types are used instead — so payment is never blocked
/// by the new endpoint.
///
/// Branching: a method named card/OmPay goes through the OmPay gateway;
/// any other method (cash today, future types too) is recorded via
/// `POST /api/Booking/pay` with the selected row's id.
///
/// The provider never navigates — the screen owns navigation (pushing the
/// WebView, popping with the result); the provider owns state + API calls.
class PaymentProvider extends ChangeNotifier {
  PaymentProvider({
    required this.bookingId,
    this.companyId,
    LookupRepository? lookupRepository,
    BookingRepository? bookingRepository,
    BookingLookups? bookingLookups,
  })  : _lookups = lookupRepository ?? getIt<LookupRepository>(),
        _repository = bookingRepository ?? getIt<BookingRepository>(),
        _bookingLookups = bookingLookups ?? getIt<BookingLookups>() {
    loadMethods();
  }

  final int bookingId;
  final int? companyId;
  final LookupRepository _lookups;
  final BookingRepository _repository;
  final BookingLookups _bookingLookups;

  List<GeneralLookup> _methods = const [];
  List<GeneralLookup> get methods => _methods;

  int? _selectedId;
  int? get selectedId => _selectedId;

  bool _isLoadingMethods = false;
  bool get isLoadingMethods => _isLoadingMethods;

  /// Non-null when the method list could not be loaded at all (company call
  /// AND fallback failed). The screen shows an error + retry state.
  String? _methodsError;
  String? get methodsError => _methodsError;

  PaymentPhase _phase = PaymentPhase.idle;
  PaymentPhase get phase => _phase;
  bool get isSubmitting => _phase != PaymentPhase.idle;

  /// Last submit failure, shown inline above the pay button.
  String? _submitError;
  String? get submitError => _submitError;

  GeneralLookup? get selectedMethod {
    for (final m in _methods) {
      if (m.id == _selectedId) return m;
    }
    return null;
  }

  /// True when the selected method settles through the OmPay gateway.
  bool get isGateway => isGatewayMethod(selectedMethod);

  /// Card / OmPay rows are gateway methods (case-insensitive contains, matching
  /// the tolerance of [BookingLookups]).
  static bool isGatewayMethod(GeneralLookup? m) {
    final n = (m?.name ?? '').toLowerCase();
    return n.contains('card') || n.contains('ompay');
  }

  void select(int id) {
    if (_selectedId == id) return;
    _selectedId = id;
    _submitError = null;
    notifyListeners();
  }

  Future<void> loadMethods() async {
    _isLoadingMethods = true;
    _methodsError = null;
    notifyListeners();

    List<GeneralLookup> rows = const [];
    // Preferred source: company-scoped payment types.
    if (companyId != null) {
      try {
        rows = (await _lookups.getCompanyGeneralTypes(companyId!))
            .where((r) => r.isActive)
            .toList();
      } catch (_) {
        rows = const []; // fall through to the cached defaults
      }
    }
    // Fallback: cached active general types (default payment_type rows).
    if (rows.isEmpty) {
      try {
        await _bookingLookups.ensureLoaded();
        rows = _bookingLookups.paymentTypes();
      } on AppException catch (e) {
        _methodsError = e.message;
      } catch (_) {
        _methodsError = '';
      }
    }

    _methods = rows;
    // Keep the current selection when still available, else auto-select first.
    if (_methods.every((m) => m.id != _selectedId)) {
      _selectedId = _methods.isNotEmpty ? _methods.first.id : null;
    }
    _isLoadingMethods = false;
    notifyListeners();
  }

  /// Starts an OmPay checkout session. Returns what the screen needs to open
  /// the WebView, or null on failure (error kept in [submitError]).
  Future<OmPayStart?> startGateway() async {
    _phase = PaymentPhase.startingCheckout;
    _submitError = null;
    notifyListeners();
    try {
      final init = await _repository.omPayInit(bookingId, 'mobile');
      final url = init.checkoutPageUrl ?? init.redirectUrl ?? init.checkoutJsUrl;
      if (url == null || url.isEmpty) {
        throw AppException(message: '');
      }
      // The gateway redirects to the backend result page when the flow ends;
      // detect it (plus the slfdrive:// deep link) to close the WebView.
      final markers = <String>{
        '/ompay/result',
        if (init.redirectUrl != null && init.redirectUrl!.isNotEmpty) init.redirectUrl!,
      }.toList();
      _phase = PaymentPhase.awaitingGateway;
      notifyListeners();
      return OmPayStart(url: url, returnUrlMarkers: markers, orderId: init.orderId);
    } on AppException catch (e) {
      _phase = PaymentPhase.idle;
      _submitError = e.message;
      notifyListeners();
      return null;
    } catch (_) {
      _phase = PaymentPhase.idle;
      _submitError = '';
      notifyListeners();
      return null;
    }
  }

  /// Settles the gateway attempt once the WebView returns. On success the
  /// order is verified with the backend; a verify failure is treated as
  /// pending (the backend webhook reconciles it).
  Future<PaymentOutcome> finishGateway(OmPayWebResult? result, String? initOrderId) async {
    final outcome = result?.outcome ?? OmPayWebOutcome.cancelled;
    if (outcome != OmPayWebOutcome.success) {
      _phase = PaymentPhase.idle;
      notifyListeners();
      return outcome == OmPayWebOutcome.failed
          ? PaymentOutcome.failed
          : PaymentOutcome.cancelled;
    }
    _phase = PaymentPhase.verifying;
    notifyListeners();
    bool paid = false;
    final orderId = result?.orderId ?? initOrderId;
    if (orderId != null) {
      try {
        paid = await _repository.omPayVerify(bookingId, orderId);
      } catch (_) {
        // treated as pending — reconciled by the backend webhook
      }
    }
    _phase = PaymentPhase.idle;
    notifyListeners();
    return paid ? PaymentOutcome.paid : PaymentOutcome.pending;
  }

  /// Records a non-gateway payment (cash and any future direct types) with the
  /// selected method's id. Returns true on success.
  Future<bool> recordPayment() async {
    final id = _selectedId;
    if (id == null) return false;
    _phase = PaymentPhase.recording;
    _submitError = null;
    notifyListeners();
    try {
      await _repository.pay(bookingId: bookingId, paymentTypeId: id);
      _phase = PaymentPhase.idle;
      notifyListeners();
      return true;
    } on AppException catch (e) {
      _phase = PaymentPhase.idle;
      _submitError = e.message;
      notifyListeners();
      return false;
    } catch (_) {
      _phase = PaymentPhase.idle;
      _submitError = '';
      notifyListeners();
      return false;
    }
  }
}
