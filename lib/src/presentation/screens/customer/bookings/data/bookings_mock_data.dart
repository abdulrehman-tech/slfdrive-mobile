import '../models/booking_item.dart';

List<BookingItem> buildMockBookings() => const [
  BookingItem(
    carName: 'Mercedes AMG GT',
    carImageUrl: 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80',
    pickupDate: 'Jan 15, 2025',
    dropoffDate: 'Jan 18, 2025',
    pickupLocation: 'Muscat Airport',
    totalPrice: 750,
    status: BookingStatus.confirmed,
    driverName: 'Ahmed Al-Farsi',
    driverAvatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
  ),
  BookingItem(
    carName: 'BMW M4 Competition',
    carImageUrl: 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800&q=80',
    pickupDate: 'Jan 10, 2025',
    dropoffDate: 'Jan 12, 2025',
    pickupLocation: 'Downtown Muscat',
    totalPrice: 380,
    status: BookingStatus.inProgress,
  ),
  BookingItem(
    carName: 'Porsche 911 Turbo S',
    carImageUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&q=80',
    pickupDate: 'Dec 20, 2024',
    dropoffDate: 'Dec 23, 2024',
    pickupLocation: 'Grand Mall',
    totalPrice: 960,
    status: BookingStatus.completed,
    driverName: 'Mohammed K.',
    driverAvatarUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
  ),
  BookingItem(
    carName: 'Lamborghini Huracán',
    carImageUrl: 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=800&q=80',
    pickupDate: 'Dec 15, 2024',
    dropoffDate: 'Dec 16, 2024',
    pickupLocation: 'Seeb',
    totalPrice: 500,
    status: BookingStatus.cancelled,
  ),
];
