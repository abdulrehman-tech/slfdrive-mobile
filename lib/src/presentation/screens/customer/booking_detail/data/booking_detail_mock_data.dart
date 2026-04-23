import '../models/booking_detail.dart';

BookingDetail buildMockBookingDetail() => BookingDetail(
      ref: 'SLF542891',
      carName: 'Mercedes AMG GT',
      carImageUrl: 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80',
      brand: 'Mercedes',
      plateNumber: '12345',
      plateCode: 'A',
      pickupLocation: 'Muscat International Airport, Oman',
      dropoffLocation: 'Muscat International Airport, Oman',
      start: DateTime.now().add(const Duration(days: 2)),
      end: DateTime.now().add(const Duration(days: 5)),
      pricePerDay: 250,
      extrasPerDay: 10,
      deliveryFee: 10,
      paymentMethod: 'Visa ••••4242',
      stage: BookingTimelineStage.confirmed,
      driverName: 'Ahmed Al-Farsi',
      driverAvatar: 'https://randomuser.me/api/portraits/men/32.jpg',
      driverPhone: '+96890000001',
    );
