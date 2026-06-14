/// Response from `POST /api/Booking/{id}/pay/ompay/init`
/// (`SLF.Domain.DTOs.OmPayInitResponse`). The app opens [redirectUrl] (or uses
/// [checkoutJsUrl] for an embedded checkout), then polls
/// `GET /api/Booking/{id}/pay/ompay/verify?orderId=` with [orderId].
class OmPayInitResponse {
  final String? orderId;
  final String? clientId;
  final String? redirectUrl;
  final String? checkoutJsUrl;
  final int? paymentId;
  final double? amount;
  final String? currency;

  const OmPayInitResponse({
    this.orderId,
    this.clientId,
    this.redirectUrl,
    this.checkoutJsUrl,
    this.paymentId,
    this.amount,
    this.currency,
  });

  factory OmPayInitResponse.fromJson(Map<String, dynamic> json) {
    return OmPayInitResponse(
      orderId: json['orderId'] as String?,
      clientId: json['clientId'] as String?,
      redirectUrl: json['redirectUrl'] as String?,
      checkoutJsUrl: json['checkoutJsUrl'] as String?,
      paymentId: (json['paymentId'] as num?)?.toInt(),
      amount: (json['amount'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
    );
  }
}
