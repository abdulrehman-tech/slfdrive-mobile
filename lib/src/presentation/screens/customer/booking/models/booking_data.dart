import 'package:flutter/foundation.dart';

import '../../../../../core/models/company/all_company.dart';

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
  final String plateNumber;
  final String plateCode;

  /// The vehicle's own location (its pickup point). Self-pickup shows this
  /// read-only; it's also the booking's pickup coordinates.
  final double? lat;
  final double? lon;
  final String? locationName;

  const BookingCar({
    required this.id,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.pricePerDay,
    this.plateNumber = '12345',
    this.plateCode = 'A',
    this.lat,
    this.lon,
    this.locationName,
  });

  bool get hasLocation => lat != null && lon != null;
}

class BookingDriver {
  final String id;
  final String name;
  final String avatarUrl;
  final double rating;
  final double pricePerDay;
  final String speciality;

  const BookingDriver({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.rating,
    required this.pricePerDay,
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
  final double basePerDay;
  final int days;
  final double deliveryFee;
  final double vatRate; // 0..1

  const BookingPricing({
    required this.basePerDay,
    required this.days,
    required this.deliveryFee,
    this.vatRate = 0.05,
  });

  double get subtotal => basePerDay * days + deliveryFee;
  double get vat => subtotal * vatRate;
  double get total => subtotal + vat;
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

  PaymentMethod _paymentMethod = PaymentMethod.card;
  String? _promoCode;
  double _promoDiscount = 0;

  // Computed booking reference (set on success)
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
  PaymentMethod get paymentMethod => _paymentMethod;
  String? get promoCode => _promoCode;
  double get promoDiscount => _promoDiscount;
  String? get bookingRef => _bookingRef;

  /// Number of rental days (inclusive). Minimum 1.
  int get days {
    if (_startAt == null || _endAt == null) return 1;
    final d = _endAt!.difference(_startAt!).inDays;
    return d < 1 ? 1 : d + 1;
  }

  double get basePerDay {
    double base = 0;
    if (_serviceType?.needsCar == true && _car != null) base += _car!.pricePerDay;
    if (_serviceType?.needsDriver == true && _driver != null) base += _driver!.pricePerDay;
    return base;
  }

  double get deliveryFee => _pickupMode == PickupMode.delivery ? 10 : 0;

  BookingPricing get pricing => BookingPricing(
    basePerDay: basePerDay,
    days: days,
    deliveryFee: deliveryFee,
  );

  double get totalPrice => pricing.total - _promoDiscount;

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

  void setDeliveryNotes(String s) {
    _deliveryNotes = s;
    notifyListeners();
  }

  void setPaymentMethod(PaymentMethod m) {
    _paymentMethod = m;
    notifyListeners();
  }

  void applyPromo(String? code, double discount) {
    _promoCode = code;
    _promoDiscount = discount;
    notifyListeners();
  }

  void assignBookingRef(String ref) {
    _bookingRef = ref;
    notifyListeners();
  }
}
