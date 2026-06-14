import '../data/repositories/lookup_repository.dart';
import '../models/common/general_lookup.dart';
import '../../presentation/screens/customer/booking/models/booking_data.dart';

/// Resolves the `serviceTypeId` / `paymentTypeId` / `bookingTypeId` / initial
/// status id that `POST /api/Booking/create` requires, from the backend's
/// `GeneralType` / `GeneralStatus` lookups.
///
/// Matching is scoped to the row's `type` discriminator (so the two "pending"
/// rows — `booking_status` vs `payment_status` — never collide) and then by
/// `name` (case-insensitive, exact first, contains fallback). The names below
/// were verified against a logged-in `GET /api/GeneralType/active` +
/// `GET /api/GeneralStatus/active` response:
///   service_type:  vehicle | driver | vehicle-with-driver
///   payment_type:  card | cash | OmPay
///   booking_type:  individual | corporate
///   booking_status: pending | approved | completed | rejected | CorporateApproved
class BookingLookups {
  BookingLookups(this._lookups);

  final LookupRepository _lookups;

  List<GeneralLookup>? _types;
  List<GeneralLookup>? _statuses;

  bool get isLoaded => _types != null && _statuses != null;

  /// Loads and caches the general types/statuses. Safe to call repeatedly.
  Future<void> ensureLoaded() async {
    if (isLoaded) return;
    final results = await Future.wait([
      _lookups.getActiveGeneralTypes(),
      _lookups.getActiveGeneralStatuses(),
    ]);
    _types = results[0];
    _statuses = results[1];
  }

  int? serviceTypeId(BookingServiceType service) {
    switch (service) {
      case BookingServiceType.rentCar:
        return _type('service_type', const ['vehicle']);
      case BookingServiceType.carWithDriver:
        return _type('service_type', const ['vehicle-with-driver']);
      case BookingServiceType.driverOnly:
        return _type('service_type', const ['driver']);
    }
  }

  int? paymentTypeId(PaymentMethod method) {
    switch (method) {
      case PaymentMethod.card:
      case PaymentMethod.applePay:
      case PaymentMethod.wallet:
        // All non-cash methods run through the OmPay card gateway.
        return _type('payment_type', const ['card', 'ompay']);
      case PaymentMethod.cashOnDelivery:
        return _type('payment_type', const ['cash']);
      case PaymentMethod.billToCompany:
        // No dedicated corporate payment type; settle as cash/invoice.
        return _type('payment_type', const ['cash', 'card']);
    }
  }

  int? bookingTypeId({required bool corporate}) {
    return corporate
        ? _type('booking_type', const ['corporate'])
        : _type('booking_type', const ['individual']);
  }

  /// Initial status for a freshly created booking (pending approval).
  int? initialStatusId() => _status('booking_status', const ['pending', 'new', 'created']);

  int? _type(String type, List<String> names) => _match(_types, type, names);
  int? _status(String type, List<String> names) => _match(_statuses, type, names);

  /// Finds the id of the row whose `type` equals [type] and whose `name`
  /// matches the earliest-listed candidate (exact match preferred, then
  /// substring). Candidates are ordered most→least specific.
  int? _match(List<GeneralLookup>? rows, String type, List<String> names) {
    if (rows == null || rows.isEmpty) return null;
    final scoped = rows.where((r) => (r.type ?? '').toLowerCase() == type.toLowerCase()).toList();
    if (scoped.isEmpty) return null;
    for (final candidate in names) {
      final needle = candidate.toLowerCase();
      for (final r in scoped) {
        if ((r.name ?? '').toLowerCase() == needle) return r.id;
      }
    }
    for (final candidate in names) {
      final needle = candidate.toLowerCase();
      for (final r in scoped) {
        if ((r.name ?? '').toLowerCase().contains(needle)) return r.id;
      }
    }
    return null;
  }
}
