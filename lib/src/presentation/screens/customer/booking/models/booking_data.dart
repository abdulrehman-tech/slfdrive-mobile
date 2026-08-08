import 'package:flutter/foundation.dart';

import '../../../../../core/models/booking/booking_quote.dart';
import '../../../../../core/models/company/all_company.dart';
import '../../../../../core/models/lookup/location_option.dart';

// ============================================================
// ENUMS
// ============================================================

enum BookingServiceType {
  /// Customer drives themselves (car only).
  rentCar,

  /// Customer rents a car and wants a driver with it.
  carWithDriver,

  /// Customer hires a driver only (uses their own vehicle).
  driverOnly,
}

enum PickupMode { selfPickup, delivery }

/// Payment methods offered at pay time (after a booking is approved).
/// `card` runs through the OmPay gateway; `cash` is recorded directly.
enum PaymentMethod { card, cash }

extension BookingServiceTypeX on BookingServiceType {
  String get titleKey {
    switch (this) {
      case BookingServiceType.rentCar:
        return 'booking_service_rent_car';
      case BookingServiceType.carWithDriver:
        return 'booking_service_car_with_driver';
      case BookingServiceType.driverOnly:
        return 'booking_service_driver_only';
    }
  }

  String get subtitleKey {
    switch (this) {
      case BookingServiceType.rentCar:
        return 'booking_service_rent_car_desc';
      case BookingServiceType.carWithDriver:
        return 'booking_service_car_with_driver_desc';
      case BookingServiceType.driverOnly:
        return 'booking_service_driver_only_desc';
    }
  }

  bool get needsCar =>
      this == BookingServiceType.rentCar || this == BookingServiceType.carWithDriver;

  bool get needsDriver =>
      this == BookingServiceType.carWithDriver || this == BookingServiceType.driverOnly;
}

// ============================================================
// NESTED MODELS
// ============================================================

class BookingCar {
  final String id;
  final String name;
  final String brand;
  final String imageUrl;
  final double pricePerDay;

  /// Per-hour rate — used for same-day bookings, which the backend bills by the
  /// hour. 0 when the vehicle has no hourly price configured.
  final double pricePerHour;
  final String plateNumber;
  final String plateCode;

  /// The vehicle's own location (its pickup point). Self-pickup shows this
  /// read-only; it's also the booking's pickup coordinates.
  final double? lat;
  final double? lon;
  final String? locationName;

  /// The vehicle's branch. NOTE: a branch can hold vehicles from several
  /// companies, so it is NOT a reliable company key — use [companyId] instead.
  final int? branchId;

  /// The vehicle's owning company (`AllCompany` id, from the vehicle DTO's
  /// `companyId`). Used to scope the driver list in the car-with-driver flow —
  /// it matches a driver's `allCompanyId`.
  final int? companyId;

  const BookingCar({
    required this.id,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.pricePerDay,
    this.pricePerHour = 0,
    this.plateNumber = '12345',
    this.plateCode = 'A',
    this.lat,
    this.lon,
    this.locationName,
    this.branchId,
    this.companyId,
  });

  bool get hasLocation => lat != null && lon != null;
}

class BookingDriver {
  final String id;
  final String name;
  final String avatarUrl;
  final double rating;
  final double pricePerDay;

  /// Per-hour rate — used for same-day bookings (billed hourly). 0 when unset.
  final double pricePerHour;
  final String speciality;

  const BookingDriver({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.pricePerDay,
    this.pricePerHour = 0,
    required this.speciality,
  });
}

class BookingLocation {
  final double latitude;
  final double longitude;
  final String address;
  final String? label;

  const BookingLocation({
    required this.latitude,
    required this.longitude,
    required this.address,
    this.label,
  });

  BookingLocation copyWith({double? latitude, double? longitude, String? address, String? label}) =>
      BookingLocation(
        latitude: latitude ?? this.latitude,
        longitude: longitude ?? this.longitude,
        address: address ?? this.address,
        label: label ?? this.label,
      );
}

// ============================================================
// PRICING BREAKDOWN (estimate shown in summary; charged after approval)
// ============================================================

class BookingPricing {
  /// Per-unit rate charged — per hour for same-day bookings, per day otherwise.
  final double baseRate;

  /// Billing units: hours for a same-day booking, days otherwise.
  final int units;

  /// True when billed by the hour (same-day booking).
  final bool isHourly;
  final double deliveryFee;

  const BookingPricing({
    required this.baseRate,
    required this.units,
    required this.isHourly,
    required this.deliveryFee,
  });

  /// Translation key for the unit label ("hours" / "days").
  String get unitLabelKey => isHourly ? 'booking_dates_hours' : 'booking_dates_days';

  double get subtotal => baseRate * units + deliveryFee;
  double get total => subtotal;
}

// ============================================================
// BOOKING DATA (ChangeNotifier)
// ============================================================

class BookingData extends ChangeNotifier {
  BookingServiceType? _serviceType;
  BookingCar? _car;
  BookingDriver? _driver;

  // Corporate booking — `_isCorporate` true means the user must also pick the
  // company (`_company`) they are booking on behalf of.
  bool _isCorporate = false;
  AllCompany? _company;

  DateTime? _startAt;
  DateTime? _endAt;

  PickupMode _pickupMode = PickupMode.selfPickup;
  BookingLocation? _pickupLocation;
  BookingLocation? _deliveryLocation;
  String _deliveryNotes = '';

  // Delivery area (`mst_location`) + the (company, area) fee resolved from the
  // DeliveryFee API. Drives both the displayed fee and the `locationId` sent on
  // booking create.
  LocationOption? _deliveryArea;
  double _deliveryFee = 0;
  bool _deliveryFeeLoading = false;

  bool _isExplicitlyHourly = false;

  PaymentMethod _paymentMethod = PaymentMethod.card;

  // Backend-computed fare quote (from /Booking/pre-booking), fetched when the
  // summary step is shown. Null until the first fetch; drives the price card.
  BookingQuote? _quote;
  bool _quoteLoading = false;
  String? _quoteError;

  // Backend booking id + reference (set on success).
  int? _bookingId;
  String? _bookingRef;

  BookingData({
    BookingServiceType? initialServiceType,
    BookingCar? initialCar,
    BookingDriver? initialDriver,
  }) : _serviceType = initialServiceType,
       _car = initialCar,
       _driver = initialDriver;

  // ---- Getters ----
  BookingServiceType? get serviceType => _serviceType;
  BookingCar? get car => _car;
  BookingDriver? get driver => _driver;
  bool get isCorporate => _isCorporate;
  AllCompany? get company => _company;
  DateTime? get startAt => _startAt;
  DateTime? get endAt => _endAt;
  PickupMode get pickupMode => _pickupMode;
  BookingLocation? get pickupLocation => _pickupLocation;
  BookingLocation? get deliveryLocation => _deliveryLocation;
  String get deliveryNotes => _deliveryNotes;
  LocationOption? get deliveryArea => _deliveryArea;
  bool get deliveryFeeLoading => _deliveryFeeLoading;
  PaymentMethod get paymentMethod => _paymentMethod;
  BookingQuote? get quote => _quote;
  bool get quoteLoading => _quoteLoading;
  String? get quoteError => _quoteError;
  String? get bookingRef => _bookingRef;
  int? get bookingId => _bookingId;
  bool get isExplicitlyHourly => _isExplicitlyHourly;

  /// Number of rental days as whole 24-hour periods (minimum 1) — matches how
  /// the backend bills, so the estimate equals the charged total. A Jul 4→6
  /// span (48h) is 2 days, not 3.
  int get days {
    if (_startAt == null || _endAt == null) return 1;
    final d = _endAt!.difference(_startAt!).inDays;
    return d < 1 ? 1 : d;
  }

  /// Rental hours (minimum 1) between pickup and return — the dates step picks
  /// both times, so a same-day booking spans real hours.
  int get hours {
    if (_startAt == null || _endAt == null) return 1;
    final h = _endAt!.difference(_startAt!).inHours;
    return h < 1 ? 1 : h;
  }

  /// Checks if the currently selected car/driver supports hourly billing.
  /// If no car/driver is selected yet, it assumes hourly is supported.
  bool get supportsHourly {
    final sType = _serviceType;
    if (sType == null) return true;

    if (sType.needsCar && _car != null && _car!.pricePerHour <= 0) return false;
    if (sType.needsDriver && _driver != null && _driver!.pricePerHour <= 0) return false;

    return true;
  }

  /// A booking is billed by the hour when explicitly toggled to Hourly mode,
  /// provided they select the same day and the selected vehicle/driver supports it.
  bool get isHourly {
    final s = _startAt, e = _endAt;
    if (s == null || e == null) return false;
    final sameDay = s.year == e.year && s.month == e.month && s.day == e.day;
    return _isExplicitlyHourly && sameDay && supportsHourly;
  }

  /// Billing units: hours for a same-day booking, otherwise days.
  int get units => isHourly ? hours : days;

  /// Translation key for the unit label ("hours" / "days").
  String get unitLabelKey => isHourly ? 'booking_dates_hours' : 'booking_dates_days';

  double get basePerDay {
    double base = 0;
    if (_serviceType?.needsCar == true && _car != null) base += _car!.pricePerDay;
    if (_serviceType?.needsDriver == true && _driver != null) base += _driver!.pricePerDay;
    return base;
  }

  double get basePerHour {
    double base = 0;
    if (_serviceType?.needsCar == true && _car != null) base += _car!.pricePerHour;
    if (_serviceType?.needsDriver == true && _driver != null) base += _driver!.pricePerHour;
    return base;
  }

  /// Per-unit rate: per hour for a same-day booking, per day otherwise.
  double get baseRate => isHourly ? basePerHour : basePerDay;

  // ── Per-side breakdown (vehicle / driver shown as separate lines) ──
  bool get hasCarCharge => _serviceType?.needsCar == true && _car != null;
  bool get hasDriverCharge => _serviceType?.needsDriver == true && _driver != null;

  /// Vehicle per-unit rate (per hour when [isHourly], else per day).
  double get carRate =>
      !hasCarCharge ? 0 : (isHourly ? _car!.pricePerHour : _car!.pricePerDay);

  /// Driver per-unit rate (per hour when [isHourly], else per day).
  double get driverRate =>
      !hasDriverCharge ? 0 : (isHourly ? _driver!.pricePerHour : _driver!.pricePerDay);

  /// Vehicle / driver line totals over the billing [units].
  double get carAmount => carRate * units;
  double get driverAmount => driverRate * units;

  /// Delivery fee in OMR. Resolved from the DeliveryFee API for the (vehicle
  /// company, selected area); 0 for self-pickup or when no fee is configured.
  /// The backend recomputes the authoritative fee on booking create.
  double get deliveryFee => _pickupMode == PickupMode.delivery ? _deliveryFee : 0;

  BookingPricing get pricing => BookingPricing(
    baseRate: baseRate,
    units: units,
    isHourly: isHourly,
    deliveryFee: deliveryFee,
  );

  double get totalPrice => pricing.total;

  // ---- Setters ----
  void setServiceType(BookingServiceType type) {
    _serviceType = type;
    // Clear incompatible selections
    if (type == BookingServiceType.driverOnly) _car = null;
    if (type == BookingServiceType.rentCar) _driver = null;
    notifyListeners();
  }

  void setCar(BookingCar? c) {
    _car = c;
    notifyListeners();
  }

  void setDriver(BookingDriver? d) {
    _driver = d;
    notifyListeners();
  }

  void setCorporate(bool isCorporate, {AllCompany? company}) {
    _isCorporate = isCorporate;
    _company = isCorporate ? company : null;
    notifyListeners();
  }

  void setCompany(AllCompany? company) {
    _company = company;
    notifyListeners();
  }

  void setDates(DateTime start, DateTime end) {
    _startAt = start;
    _endAt = end;
    notifyListeners();
  }

  void setIsHourlyMode(bool isHourly) {
    _isExplicitlyHourly = isHourly;
    notifyListeners();
  }

  void setPickupMode(PickupMode m) {
    _pickupMode = m;
    notifyListeners();
  }

  void setPickupLocation(BookingLocation loc) {
    _pickupLocation = loc;
    notifyListeners();
  }

  void setDeliveryLocation(BookingLocation loc) {
    _deliveryLocation = loc;
    notifyListeners();
  }

  /// Selects the delivery area. The fee is then resolved asynchronously by the
  /// caller (which has API access) and pushed back via [setDeliveryFee].
  void setDeliveryArea(LocationOption? area) {
    _deliveryArea = area;
    if (area == null) _deliveryFee = 0;
    notifyListeners();
  }

  void setDeliveryFeeLoading(bool loading) {
    _deliveryFeeLoading = loading;
    notifyListeners();
  }

  /// Resolved (company, area) delivery fee in OMR.
  void setDeliveryFee(double fee) {
    _deliveryFee = fee;
    _deliveryFeeLoading = false;
    notifyListeners();
  }

  void setDeliveryNotes(String s) {
    _deliveryNotes = s;
    notifyListeners();
  }

  void setPaymentMethod(PaymentMethod m) {
    _paymentMethod = m;
    notifyListeners();
  }

  /// Marks the fare quote as loading (clears any prior error). Called before
  /// hitting /Booking/pre-booking.
  void setQuoteLoading() {
    _quoteLoading = true;
    _quoteError = null;
    notifyListeners();
  }

  void setQuote(BookingQuote quote) {
    _quote = quote;
    _quoteLoading = false;
    _quoteError = null;
    notifyListeners();
  }

  void setQuoteError(String message) {
    _quoteError = message;
    _quoteLoading = false;
    notifyListeners();
  }

  void assignBookingRef(String ref, {int? id}) {
    _bookingRef = ref;
    if (id != null) _bookingId = id;
    notifyListeners();
  }
}
