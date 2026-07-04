import 'package:easy_localization/easy_localization.dart';

import '../../../../../core/models/booking/booking.dart';
import '../../bookings/models/booking_item.dart';

enum BookingTimelineStage { confirmed, pickedUp, inTrip, returned }

/// Vehicle/driver display values already fetched by the bookings list, passed to
/// the detail screen via route `extra` so the card's image/name paint instantly
/// (the full booking still loads + re-enriches in the background).
class BookingDetailSeed {
  final String? vehicleName;
  final String? vehicleImageUrl;
  final String? driverName;
  final String? driverPhotoUrl;
  const BookingDetailSeed({
    this.vehicleName,
    this.vehicleImageUrl,
    this.driverName,
    this.driverPhotoUrl,
  });
}

/// Friendly label for a booking's service type (vehicle / driver / both).
String _serviceLabel(Booking b) {
  final s = (b.serviceType ?? '').toLowerCase();
  if (s.contains('with') || b.serviceTypeId == 11) return 'booking_kind_vehicle_driver'.tr();
  if (s.contains('driver') || b.serviceTypeId == 9) return 'booking_kind_driver'.tr();
  return 'booking_kind_vehicle'.tr();
}

class BookingDetail {
  final int id;
  final String ref;
  final String carName;
  final String carImageUrl;
  final String brand;
  final String plateNumber;
  final String plateCode;
  final String pickupLocation;
  final String dropoffLocation;

  /// Pickup / drop-off coordinates from the booking (`BookingResponseDto`).
  /// Self-pickup carries pickup coords; delivery carries drop-off coords.
  final double? pickupLat;
  final double? pickupLon;
  final double? dropoffLat;
  final double? dropoffLon;

  final DateTime start;
  final DateTime end;
  final double pricePerDay;
  final double extrasPerDay;
  final double deliveryFee;

  /// Backend price breakdown (`BookingResponseDto`): the vehicle- and driver-side
  /// charges, and the authoritative grand total. When the booking is same-day
  /// these represent per-hour billing (see [isHourly]).
  final double vehicleAmount;
  final double driverAmount;
  final double totalAmount;

  final String paymentMethod;
  final String? driverName;
  final String? driverAvatar;
  final String? driverPhone;
  final BookingTimelineStage stage;
  final String statusLabel;

  /// Real booking-lifecycle status (drives the prominent status chip).
  final BookingStatus status;
  final bool isApproved;
  final bool isPending;
  final bool isPaid;

  /// True when the booking is billed to a corporate company (customer doesn't pay).
  final bool isCorporate;
  final String? corporateCompanyName;

  /// Free-text reason supplied when the booking was rejected.
  final String? rejectionReason;

  /// Service label (e.g. "Vehicle rental"); shown alongside the enriched name.
  final String serviceLabel;

  /// Backend ids used to enrich the detail from Vehicle/{id} + the driver list.
  final int? vehicleId;
  final int? driverId;

  /// Owning company of the vehicle (from Vehicle/{id}), shown on the car card.
  final String? companyName;

  /// The settled payment method (cash / card / OmPay) from the Payment record,
  /// shown once the booking is paid. Null while unpaid / unknown.
  final String? paymentMethodName;

  // Vehicle specs (from Vehicle/{id}).
  final String? color;
  final int? year;
  final int? seats;
  final String? transmission;
  final String? fuelType;
  final String? vehicleType;
  final String? vehicleLocation;

  // Driver specs (from the driver list match).
  final int? driverExperienceYears;
  final String? driverLanguages;
  final String? driverLocation;

  const BookingDetail({
    required this.id,
    required this.ref,
    required this.carName,
    required this.carImageUrl,
    required this.brand,
    required this.plateNumber,
    required this.plateCode,
    required this.pickupLocation,
    required this.dropoffLocation,
    this.pickupLat,
    this.pickupLon,
    this.dropoffLat,
    this.dropoffLon,
    required this.start,
    required this.end,
    required this.pricePerDay,
    required this.extrasPerDay,
    required this.deliveryFee,
    this.vehicleAmount = 0,
    this.driverAmount = 0,
    this.totalAmount = 0,
    required this.paymentMethod,
    required this.stage,
    this.status = BookingStatus.pending,
    this.statusLabel = '',
    this.serviceLabel = '',
    this.isApproved = false,
    this.isPending = false,
    this.isPaid = false,
    this.isCorporate = false,
    this.corporateCompanyName,
    this.rejectionReason,
    this.vehicleId,
    this.driverId,
    this.companyName,
    this.paymentMethodName,
    this.driverName,
    this.driverAvatar,
    this.driverPhone,
    this.color,
    this.year,
    this.seats,
    this.transmission,
    this.fuelType,
    this.vehicleType,
    this.vehicleLocation,
    this.driverExperienceYears,
    this.driverLanguages,
    this.driverLocation,
  });

  bool get hasVehicle => vehicleId != null;
  bool get hasDriver => driverId != null;

  bool get hasPickupCoords => pickupLat != null && pickupLon != null;
  bool get hasDropoffCoords => dropoffLat != null && dropoffLon != null;
  bool get hasAnyCoords => hasPickupCoords || hasDropoffCoords;

  /// True when the booking is delivered (drop-off coords present) rather than
  /// self-pickup.
  bool get isDelivery => hasDropoffCoords;

  /// Customer can pay once an admin has approved the booking and it isn't paid.
  /// Corporate bookings are billed to the company, so the customer never pays.
  bool get canPay => isApproved && !isPaid && !isCorporate;

  BookingDetail copyWith({
    String? carName,
    String? carImageUrl,
    String? brand,
    String? plateNumber,
    String? plateCode,
    String? companyName,
    String? paymentMethodName,
    String? driverName,
    String? driverAvatar,
    String? driverPhone,
    String? color,
    int? year,
    int? seats,
    String? transmission,
    String? fuelType,
    String? vehicleType,
    String? vehicleLocation,
    int? driverExperienceYears,
    String? driverLanguages,
    String? driverLocation,
  }) {
    return BookingDetail(
      id: id,
      ref: ref,
      carName: carName ?? this.carName,
      carImageUrl: carImageUrl ?? this.carImageUrl,
      brand: brand ?? this.brand,
      plateNumber: plateNumber ?? this.plateNumber,
      plateCode: plateCode ?? this.plateCode,
      pickupLocation: pickupLocation,
      dropoffLocation: dropoffLocation,
      pickupLat: pickupLat,
      pickupLon: pickupLon,
      dropoffLat: dropoffLat,
      dropoffLon: dropoffLon,
      start: start,
      end: end,
      pricePerDay: pricePerDay,
      extrasPerDay: extrasPerDay,
      deliveryFee: deliveryFee,
      vehicleAmount: vehicleAmount,
      driverAmount: driverAmount,
      totalAmount: totalAmount,
      paymentMethod: paymentMethod,
      stage: stage,
      status: status,
      statusLabel: statusLabel,
      serviceLabel: serviceLabel,
      isApproved: isApproved,
      isPending: isPending,
      isPaid: isPaid,
      isCorporate: isCorporate,
      corporateCompanyName: corporateCompanyName,
      rejectionReason: rejectionReason,
      vehicleId: vehicleId,
      driverId: driverId,
      companyName: companyName ?? this.companyName,
      paymentMethodName: paymentMethodName ?? this.paymentMethodName,
      driverName: driverName ?? this.driverName,
      driverAvatar: driverAvatar ?? this.driverAvatar,
      driverPhone: driverPhone ?? this.driverPhone,
      color: color ?? this.color,
      year: year ?? this.year,
      seats: seats ?? this.seats,
      transmission: transmission ?? this.transmission,
      fuelType: fuelType ?? this.fuelType,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleLocation: vehicleLocation ?? this.vehicleLocation,
      driverExperienceYears: driverExperienceYears ?? this.driverExperienceYears,
      driverLanguages: driverLanguages ?? this.driverLanguages,
      driverLocation: driverLocation ?? this.driverLocation,
    );
  }

  /// Rental days as whole 24-hour periods (minimum 1) — matches the backend's
  /// billing so the breakdown units line up with the charged total.
  int get days {
    final d = end.difference(start).inDays;
    return d < 1 ? 1 : d;
  }

  /// A same-calendar-day booking is billed by the hour, not the day.
  bool get isHourly =>
      start.year == end.year && start.month == end.month && start.day == end.day;

  /// Rental hours (minimum 1) — only meaningful when [isHourly].
  int get hours {
    final h = end.difference(start).inHours;
    return h < 1 ? 1 : h;
  }

  /// Billing units: hours for a same-day booking, otherwise days.
  int get units => isHourly ? hours : days;

  /// Translation key for the unit label ("hours" / "days").
  String get unitLabelKey => isHourly ? 'booking_dates_hours' : 'booking_dates_days';

  /// Per-unit vehicle / driver rate derived from the backend amount.
  double get vehicleUnitRate => units > 0 ? vehicleAmount / units : vehicleAmount;
  double get driverUnitRate => units > 0 ? driverAmount / units : driverAmount;

  double get subtotal => (pricePerDay + extrasPerDay) * days + deliveryFee;

  /// Prefer the backend's grand total; fall back to the derived subtotal.
  double get total => totalAmount > 0 ? totalAmount : subtotal;

  /// True when the booking is completed and eligible for a customer review.
  bool get isCompleted => stage == BookingTimelineStage.returned;

  /// Maps a backend [Booking] to the detail view model. `BookingResponseDto`
  /// doesn't carry vehicle display/plate fields or a price breakdown, so those
  /// fall back to empty/derived values; the amount is shown as the lump total.
  factory BookingDetail.fromBooking(Booking b) {
    // Backend timestamps are UTC — convert to local so the displayed calendar
    // dates match what the customer picked (else they read one day less).
    final start = b.fromDate?.toLocal() ?? DateTime.now();
    final end = b.toDate?.toLocal() ?? start;
    final dayCount = () {
      final d = end.difference(start).inDays;
      return d < 1 ? 1 : d;
    }();
    final status = bookingStatusFromApi(b);
    final s = '${b.status ?? ''} ${b.statusType ?? ''}'.toLowerCase();
    // Trip-progress timeline is independent of the lifecycle status: it only
    // advances on pickup / in-trip / completion signals.
    final stage = (status == BookingStatus.completed || b.completedAt != null || s.contains('complete'))
        ? BookingTimelineStage.returned
        : (s.contains('trip') || s.contains('progress') || s.contains('ongoing'))
            ? BookingTimelineStage.inTrip
            : s.contains('picked')
                ? BookingTimelineStage.pickedUp
                : BookingTimelineStage.confirmed;
    final pay = (b.paymentStatus ?? '').toLowerCase();
    final isApproved =
        status == BookingStatus.approved || status == BookingStatus.corporateApproved;
    final isPending = status == BookingStatus.pending;
    final isPaid = b.paymentStatusId == 10 || pay.contains('paid');
    return BookingDetail(
      id: b.id,
      ref: b.bookingNo ?? 'SLF${b.id}',
      carName: _serviceLabel(b),
      carImageUrl: '',
      brand: '',
      plateNumber: '',
      plateCode: '',
      pickupLocation: '',
      dropoffLocation: '',
      pickupLat: b.pickupLat,
      pickupLon: b.pickupLon,
      dropoffLat: b.dropoffLat,
      dropoffLon: b.dropoffLon,
      start: start,
      end: end,
      // Backend returns a lump total; spread it across days with no VAT split.
      pricePerDay: dayCount == 0 ? (b.totalAmount ?? 0) : (b.totalAmount ?? 0) / dayCount,
      extrasPerDay: 0,
      // Backend `BookingResponseDto` omits deliveryFee today, so this is 0 until
      // it ships the field; the price card's delivery line then appears on its own.
      deliveryFee: b.deliveryFee ?? 0,
      // Real price breakdown from the response.
      vehicleAmount: b.vehicleAmount ?? 0,
      driverAmount: b.driverAmount ?? 0,
      totalAmount: b.totalAmount ?? 0,
      paymentMethod: b.paymentStatus ?? '',
      stage: stage,
      status: status,
      statusLabel: b.status ?? '',
      serviceLabel: _serviceLabel(b),
      isApproved: isApproved,
      isPending: isPending,
      isPaid: isPaid,
      isCorporate: b.isCorporate,
      corporateCompanyName: b.corporateCompanyName,
      rejectionReason: b.rejectionReason,
      vehicleId: b.vehicleId,
      driverId: b.driverId,
      driverName: b.driverFullName,
      driverAvatar: null,
      driverPhone: b.driverPhoneNumber,
    );
  }
}
