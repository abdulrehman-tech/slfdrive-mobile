/// Request body for `POST /api/Booking/create`
/// (`SLF.Domain.DTOs.BookingCreationRequest`). All ids are resolved at call
/// time — type/status ids come from the `GeneralType`/`GeneralStatus` lookups.
class BookingCreationRequest {
  final int userId;
  final int? vehicleId;
  final int? driverId;
  final int? rentalCompanyId;
  final int? corporateCompanyId;
  final double? totalAmount;
  final int? statusId;
  final int bookingTypeId;
  final int serviceTypeId;
  final int? paymentTypeId;
  final double? commissionPercent;
  final double? commissionAmount;
  final List<BookingDetailsCreationRequest> bookingDetails;

  const BookingCreationRequest({
    required this.userId,
    this.vehicleId,
    this.driverId,
    this.rentalCompanyId,
    this.corporateCompanyId,
    this.totalAmount,
    this.statusId,
    required this.bookingTypeId,
    required this.serviceTypeId,
    this.paymentTypeId,
    this.commissionPercent,
    this.commissionAmount,
    this.bookingDetails = const [],
  });

  Map<String, dynamic> toJson() => {
        'userId': userId,
        if (vehicleId != null) 'vehicleId': vehicleId,
        if (driverId != null) 'driverId': driverId,
        if (rentalCompanyId != null) 'rentalCompanyId': rentalCompanyId,
        if (corporateCompanyId != null) 'corporateCompanyId': corporateCompanyId,
        if (totalAmount != null) 'totalAmount': totalAmount,
        if (statusId != null) 'statusId': statusId,
        'bookingTypeId': bookingTypeId,
        'serviceTypeId': serviceTypeId,
        if (paymentTypeId != null) 'paymentTypeId': paymentTypeId,
        if (commissionPercent != null) 'commissionPercent': commissionPercent,
        if (commissionAmount != null) 'commissionAmount': commissionAmount,
        'bookingDetails': bookingDetails.map((d) => d.toJson()).toList(),
      };
}

/// Nested rental-leg detail (`SLF.Domain.DTOs.BookingDetailsCreationRequest`).
class BookingDetailsCreationRequest {
  final String fromDateTime; // ISO-8601
  final String toDateTime; // ISO-8601
  final double? pickUpLat;
  final double? pickUpLon;
  final double? dropOffLat;
  final double? dropOffLon;
  final double? amount;

  const BookingDetailsCreationRequest({
    required this.fromDateTime,
    required this.toDateTime,
    this.pickUpLat,
    this.pickUpLon,
    this.dropOffLat,
    this.dropOffLon,
    this.amount,
  });

  Map<String, dynamic> toJson() => {
        'fromDateTime': fromDateTime,
        'toDateTime': toDateTime,
        if (pickUpLat != null) 'pickUpLat': pickUpLat,
        if (pickUpLon != null) 'pickUpLon': pickUpLon,
        if (dropOffLat != null) 'dropOffLat': dropOffLat,
        if (dropOffLon != null) 'dropOffLon': dropOffLon,
        if (amount != null) 'amount': amount,
      };
}

/// Response from `POST /api/Booking/create`
/// (`SLF.Domain.DTOs.BookingCreationResponseDto`).
class BookingCreationResponse {
  final int? bookingId;
  final String? bookingNo;
  final int? contactId;
  final int? paymentId;
  final int? statusId;
  final double? totalAmount;
  final double? commissionAmount;

  const BookingCreationResponse({
    this.bookingId,
    this.bookingNo,
    this.contactId,
    this.paymentId,
    this.statusId,
    this.totalAmount,
    this.commissionAmount,
  });

  factory BookingCreationResponse.fromJson(Map<String, dynamic> json) {
    return BookingCreationResponse(
      bookingId: (json['bookingId'] as num?)?.toInt(),
      bookingNo: json['bookingNo'] as String?,
      contactId: (json['contactId'] as num?)?.toInt(),
      paymentId: (json['paymentId'] as num?)?.toInt(),
      statusId: (json['statusId'] as num?)?.toInt(),
      totalAmount: (json['totalAmount'] as num?)?.toDouble(),
      commissionAmount: (json['commissionAmount'] as num?)?.toDouble(),
    );
  }
}
