/// A payment record for a booking (`PaymentResponseDto`, from
/// `GET /api/Payment/booking/{bookingId}`). Carries the method (cash / card /
/// OmPay) that the booking read DTO doesn't expose.
class PaymentInfo {
  final int id;
  final int bookingId;
  final int? paymentTypeId;
  final String? paymentTypeName;
  final int? paymentStatusId;
  final String? paymentStatusName;
  final String? gatewayName;
  final String? paidAt;

  const PaymentInfo({
    required this.id,
    required this.bookingId,
    this.paymentTypeId,
    this.paymentTypeName,
    this.paymentStatusId,
    this.paymentStatusName,
    this.gatewayName,
    this.paidAt,
  });

  /// Settled (paymentStatusId 10 = paid).
  bool get isPaid =>
      paymentStatusId == 10 || (paymentStatusName ?? '').toLowerCase().contains('paid');

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      id: (json['id'] as num?)?.toInt() ?? 0,
      bookingId: (json['bookingId'] as num?)?.toInt() ?? 0,
      paymentTypeId: (json['paymentTypeId'] as num?)?.toInt(),
      paymentTypeName: json['paymentTypeName'] as String?,
      paymentStatusId: (json['paymentStatusId'] as num?)?.toInt(),
      paymentStatusName: json['paymentStatusName'] as String?,
      gatewayName: json['gatewayName'] as String?,
      paidAt: json['paidAt'] as String?,
    );
  }
}
