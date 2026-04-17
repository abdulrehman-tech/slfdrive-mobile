import 'package:flutter/foundation.dart';

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

enum PaymentMethod { card, applePay, wallet, cashOnDelivery }

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

  const BookingCar({
    required this.id,
    required this.name,
    required this.brand,
    required this.imageUrl,
    required this.pricePerDay,
    this.plateNumber = '12345',
    this.plateCode = 'A',
  });
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

class BookingExtra {
  final String id;
  final String titleKey;
  final String subtitleKey;
  final String iconKey;
  final double pricePerDay;

  const BookingExtra({
    required this.id,
    required this.titleKey,
    required this.subtitleKey,
    required this.iconKey,
    required this.pricePerDay,
  });
}

// Canonical catalogue of available extras — pricing is per day.
const kBookingExtras = <BookingExtra>[
  BookingExtra(
    id: 'child_seat',
    titleKey: 'booking_extra_child_seat',
    subtitleKey: 'booking_extra_child_seat_desc',
    iconKey: 'safety',
    pricePerDay: 3,
  ),
  BookingExtra(
    id: 'gps',
    titleKey: 'booking_extra_gps',
    subtitleKey: 'booking_extra_gps_desc',
    iconKey: 'map',
    pricePerDay: 2,
  ),
  BookingExtra(
    id: 'extra_driver',
    titleKey: 'booking_extra_extra_driver',
    subtitleKey: 'booking_extra_extra_driver_desc',
    iconKey: 'user',
    pricePerDay: 5,
  ),
  BookingExtra(
    id: 'premium_insurance',
    titleKey: 'booking_extra_premium_insurance',
    subtitleKey: 'booking_extra_premium_insurance_desc',
    iconKey: 'shield',
    pricePerDay: 8,
  ),
  BookingExtra(
    id: 'airport_delivery',
    titleKey: 'booking_extra_airport_delivery',
    subtitleKey: 'booking_extra_airport_delivery_desc',
    iconKey: 'airplane',
    pricePerDay: 10,
  ),
  BookingExtra(
    id: 'fuel_full_tank',
    titleKey: 'booking_extra_full_tank',
    subtitleKey: 'booking_extra_full_tank_desc',
    iconKey: 'fuel',
    pricePerDay: 4,
  ),
];

// ============================================================
// PRICING BREAKDOWN
// ============================================================

class BookingPricing {
  final double basePerDay;
  final int days;
  final double extrasPerDay;
  final double deliveryFee;
  final double vatRate; // 0..1

  const BookingPricing({
    required this.basePerDay,
    required this.days,
    required this.extrasPerDay,
    required this.deliveryFee,
    this.vatRate = 0.05,
  });

  double get subtotal => (basePerDay + extrasPerDay) * days + deliveryFee;
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

  DateTime? _startAt;
  DateTime? _endAt;

  PickupMode _pickupMode = PickupMode.selfPickup;
  BookingLocation? _pickupLocation;
  BookingLocation? _deliveryLocation;
  String _deliveryNotes = '';

  final Set<String> _selectedExtras = {};

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
  DateTime? get startAt => _startAt;
  DateTime? get endAt => _endAt;
  PickupMode get pickupMode => _pickupMode;
  BookingLocation? get pickupLocation => _pickupLocation;
  BookingLocation? get deliveryLocation => _deliveryLocation;
  String get deliveryNotes => _deliveryNotes;
  Set<String> get selectedExtras => Set.unmodifiable(_selectedExtras);
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

  double get extrasPerDay {
    double total = 0;
    for (final id in _selectedExtras) {
      final extra = kBookingExtras.firstWhere(
        (e) => e.id == id,
        orElse: () => const BookingExtra(
          id: '',
          titleKey: '',
          subtitleKey: '',
          iconKey: '',
          pricePerDay: 0,
        ),
      );
      total += extra.pricePerDay;
    }
    return total;
  }

  double get deliveryFee => _pickupMode == PickupMode.delivery ? 10 : 0;

  BookingPricing get pricing => BookingPricing(
    basePerDay: basePerDay,
    days: days,
    extrasPerDay: extrasPerDay,
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

  void toggleExtra(String id) {
    if (_selectedExtras.contains(id)) {
      _selectedExtras.remove(id);
    } else {
      _selectedExtras.add(id);
    }
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
