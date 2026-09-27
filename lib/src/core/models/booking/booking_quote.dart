/// Authoritative fare quote from `POST /api/Booking/pre-booking`
/// (`SLF.Domain.DTOs.BookingQuoteResponseDto`). The backend computes the whole
/// breakdown — day/hour count, per-side amounts, delivery fee, commission and
/// grand total — so the app displays these verbatim instead of estimating.
class BookingQuote {
  final bool isSameDay;
  final int days;
  final int? hours;

  /// Rental company servicing the booking (derived from the vehicle/driver
  /// owner) — the company a promo code must belong to.
  final int? rentalCompanyId;

  final double? vehicleDailyPrice;
  final double? vehicleHourlyPrice;
  final double? vehicleAmount;

  final double? driverDailyPrice;
  final double? driverHourlyPrice;
  final double? driverAmount;

  final double rentalAmount;
  final double? commissionPercent;
  final double commissionAmount;
  final double totalDeliveryFee;

  /// Rental + delivery before any promo discount.
  final double? grossAmount;

  /// Applied promo (null when none): code as resolved by the server, and the
  /// discount it took off the rental amount (never the delivery fee).
  final String? promoCode;
  final int? promoCodeId;
  final String? discountType;
  final double? discountValue;
  final double discountAmount;
  final double totalAmount;
  final String currency;

  const BookingQuote({
    required this.isSameDay,
    required this.days,
    this.hours,
    this.rentalCompanyId,
    this.vehicleDailyPrice,
    this.vehicleHourlyPrice,
    this.vehicleAmount,
    this.driverDailyPrice,
    this.driverHourlyPrice,
    this.driverAmount,
    required this.rentalAmount,
    this.commissionPercent,
    required this.commissionAmount,
    required this.totalDeliveryFee,
    this.grossAmount,
    this.promoCode,
    this.promoCodeId,
    this.discountType,
    this.discountValue,
    this.discountAmount = 0,
    required this.totalAmount,
    required this.currency,
  });

  /// Billing units shown next to the rate: hours for a same-day booking, days
  /// otherwise. Mirrors how the backend priced it (`isSameDay`).
  int get units => isSameDay ? (hours ?? 0) : days;

  /// True when the server applied a promo code to this quote.
  bool get hasPromo => promoCodeId != null && discountAmount > 0;

  /// Per-side unit rate the backend billed at (hourly when same-day).
  double get vehicleUnitPrice => isSameDay ? (vehicleHourlyPrice ?? 0) : (vehicleDailyPrice ?? 0);
  double get driverUnitPrice => isSameDay ? (driverHourlyPrice ?? 0) : (driverDailyPrice ?? 0);

  factory BookingQuote.fromJson(Map<String, dynamic> json) {
    double? d(String k) => (json[k] as num?)?.toDouble();
    int? i(String k) => (json[k] as num?)?.toInt();
    return BookingQuote(
      isSameDay: json['isSameDay'] as bool? ?? false,
      days: i('days') ?? 0,
      hours: i('hours'),
      rentalCompanyId: i('rentalCompanyId'),
      vehicleDailyPrice: d('vehicleDailyPrice'),
      vehicleHourlyPrice: d('vehicleHourlyPrice'),
      vehicleAmount: d('vehicleAmount'),
      driverDailyPrice: d('driverDailyPrice'),
      driverHourlyPrice: d('driverHourlyPrice'),
      driverAmount: d('driverAmount'),
      rentalAmount: d('rentalAmount') ?? 0,
      commissionPercent: d('commissionPercent'),
      commissionAmount: d('commissionAmount') ?? 0,
      totalDeliveryFee: d('totalDeliveryFee') ?? 0,
      grossAmount: d('grossAmount'),
      promoCode: json['promoCode'] as String?,
      promoCodeId: i('promoCodeId'),
      discountType: json['discountType'] as String?,
      discountValue: d('discountValue'),
      discountAmount: d('discountAmount') ?? 0,
      totalAmount: d('totalAmount') ?? 0,
      currency: json['currency'] as String? ?? 'OMR',
    );
  }
}
