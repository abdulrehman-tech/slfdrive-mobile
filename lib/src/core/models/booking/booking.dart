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
  final int? statusId;
  final String? status;
  final String? statusType;
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
    this.statusId,
    this.status,
    this.statusType,
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

  DateTime? get fromDate => DateTime.tryParse(fromDateTime ?? '');
  DateTime? get toDate => DateTime.tryParse(toDateTime ?? '');

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
      statusId: i('statusId'),
      status: json['status'] as String?,
      statusType: json['statusType'] as String?,
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
