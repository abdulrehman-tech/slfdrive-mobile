/// Authoritative fare quote from `POST /api/Booking/pre-booking`
/// (`SLF.Domain.DTOs.BookingQuoteResponseDto`). The backend computes the whole
/// breakdown — day/hour count, per-side amounts, delivery fee, commission and
/// grand total — so the app displays these verbatim instead of estimating.
class BookingQuote {
  final bool isSameDay;
  final int days;
  final int? hours;

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
  final double totalAmount;
  final String currency;

  const BookingQuote({
    required this.isSameDay,
    required this.days,
    this.hours,
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
    required this.totalAmount,
    required this.currency,
  });

  /// Billing units shown next to the rate: hours for a same-day booking, days
  /// otherwise. Mirrors how the backend priced it (`isSameDay`).
  int get units => isSameDay ? (hours ?? 0) : days;

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
      totalAmount: d('totalAmount') ?? 0,
      currency: json['currency'] as String? ?? 'OMR',
    );
  }
}
