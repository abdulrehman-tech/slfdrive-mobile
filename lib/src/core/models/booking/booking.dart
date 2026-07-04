/// A booking record returned by `GET /api/Booking/{id}` and the
/// `Booking/my/paginated` list (`SLF.Domain.DTOs.BookingResponseDto`).
class Booking {
  final int id;
  final String? bookingNo;
  final int? userId;
  final int? vehicleId;
  final int? driverId;
  final int? rentalCompanyId;
  final int? corporateCompanyId;
  final double? totalAmount;
  final double? vehicleAmount;
  final double? driverAmount;

  /// Delivery fee charged for this booking, in OMR. `BookingResponseDto` does
  /// NOT expose this today — the backend must add `deliveryFee` (and
  /// `isDelivery`) to the read DTO for it to be non-null. Until then the detail
  /// screen shows no delivery line even when a fee was charged (it's still baked
  /// into `totalAmount`). Parsed defensively so it lights up automatically once
  /// the backend ships the field.
  final double? deliveryFee;

  /// Whether this booking is a delivery. Also absent from `BookingResponseDto`
  /// today; see [deliveryFee].
  final bool? isDelivery;
  final int? statusId;
  final String? status;
  final String? statusType;
  final int? bookingTypeId;
  final String? type;
  final String? serviceType;
  final int? serviceTypeId;
  final int? paymentStatusId;
  final String? paymentStatus;
  final String? fromDateTime;
  final String? toDateTime;
  final double? pickupLat;
  final double? pickupLon;
  final double? dropoffLat;
  final double? dropoffLon;
  final String? confirmedAt;
  final String? completedAt;
  final String? rejectedAt;
  final String? rejectionReason;
  final String? customerFullName;
  final String? customerPhoneNumber;
  final String? customerEmail;
  final String? driverFullName;
  final String? driverPhoneNumber;
  final String? rentalCompanyName;
  final String? corporateCompanyName;

  const Booking({
    required this.id,
    this.bookingNo,
    this.userId,
    this.vehicleId,
    this.driverId,
    this.rentalCompanyId,
    this.corporateCompanyId,
    this.totalAmount,
    this.vehicleAmount,
    this.driverAmount,
    this.deliveryFee,
    this.isDelivery,
    this.statusId,
    this.status,
    this.statusType,
    this.bookingTypeId,
    this.type,
    this.serviceType,
    this.serviceTypeId,
    this.paymentStatusId,
    this.paymentStatus,
    this.fromDateTime,
    this.toDateTime,
    this.pickupLat,
    this.pickupLon,
    this.dropoffLat,
    this.dropoffLon,
    this.confirmedAt,
    this.completedAt,
    this.rejectedAt,
    this.rejectionReason,
    this.customerFullName,
    this.customerPhoneNumber,
    this.customerEmail,
    this.driverFullName,
    this.driverPhoneNumber,
    this.rentalCompanyName,
    this.corporateCompanyName,
  });

  /// True when the booking has reached a completed state and is eligible for a
  /// customer review.
  bool get isCompleted =>
      completedAt != null ||
      (status?.toLowerCase() == 'completed') ||
      (statusType?.toLowerCase() == 'completed');

  /// True when this booking is corporate (billed to a corporate company rather
  /// than paid by the customer). `13` is the backend `booking_type` id.
  bool get isCorporate =>
      corporateCompanyId != null ||
      bookingTypeId == 13 ||
      (type?.toLowerCase() == 'corporate');

  DateTime? get fromDate => DateTime.tryParse(fromDateTime ?? '');
  DateTime? get toDate => DateTime.tryParse(toDateTime ?? '');

  /// Rental duration as whole 24-hour periods (minimum 1) — a Jul 4→6 span
  /// (48h) is 2 days. Kept identical to the customer detail view's `days` so the
  /// driver and customer see the SAME count for one booking (previously this
  /// added +1, so the driver read 3 days while the customer read 2).
  /// NOTE: this is a client-side derivation from the two timestamps. The backend
  /// does not return a day count today — once `BookingResponseDto.numberOfDays`
  /// exists, display it directly and delete this. `totalAmount / durationDays`
  /// is the per-day rate.
  int get durationDays {
    final f = fromDate;
    final t = toDate;
    if (f == null || t == null) return 1;
    final d = t.difference(f).inDays;
    return d < 1 ? 1 : d;
  }

  /// Derived per-day rate (`totalAmount / durationDays`), or null when no total.
  double? get perDayAmount {
    final total = totalAmount;
    if (total == null) return null;
    return total / durationDays;
  }

  factory Booking.fromJson(Map<String, dynamic> json) {
    double? d(String k) => (json[k] as num?)?.toDouble();
    int? i(String k) => (json[k] as num?)?.toInt();
    return Booking(
      id: i('id') ?? 0,
      bookingNo: json['bookingNo'] as String?,
      userId: i('userId'),
      vehicleId: i('vehicleId'),
      driverId: i('driverId'),
      rentalCompanyId: i('rentalCompanyId'),
      corporateCompanyId: i('corporateCompanyId'),
      totalAmount: d('totalAmount') ?? d('amount'),
      vehicleAmount: d('vehicleAmount'),
      driverAmount: d('driverAmount'),
      deliveryFee: d('deliveryFee'),
      isDelivery: json['isDelivery'] as bool?,
      statusId: i('statusId'),
      status: json['status'] as String?,
      statusType: json['statusType'] as String?,
      bookingTypeId: i('bookingTypeId'),
      type: json['type'] as String?,
      serviceType: json['serviceType'] as String?,
      serviceTypeId: i('serviceTypeId'),
      paymentStatusId: i('paymentStatusId'),
      paymentStatus: json['paymentStatus'] as String?,
      fromDateTime: json['fromDateTime'] as String?,
      toDateTime: json['toDateTime'] as String?,
      pickupLat: d('pickupLat'),
      pickupLon: d('pickupLon'),
      dropoffLat: d('dropoffLat'),
      dropoffLon: d('dropoffLon'),
      confirmedAt: json['confirmedAt'] as String?,
      completedAt: json['completedAt'] as String?,
      rejectedAt: json['rejectedAt'] as String?,
      rejectionReason: json['rejectionReason'] as String?,
      customerFullName: json['customerFullName'] as String?,
      customerPhoneNumber: json['customerPhoneNumber'] as String?,
      customerEmail: json['customerEmail'] as String?,
      driverFullName: json['driverFullName'] as String?,
      driverPhoneNumber: json['driverPhoneNumber'] as String?,
      rentalCompanyName: json['rentalCompanyName'] as String?,
      corporateCompanyName: json['corporateCompanyName'] as String?,
    );
  }
}
