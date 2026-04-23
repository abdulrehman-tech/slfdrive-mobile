import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../models/driver_profile.dart';
import '../models/driver_review.dart';

const DriverProfile kMockDriverProfile = DriverProfile(
  id: 'driver-1',
  name: 'Rashid Al-Suleimani',
  coverUrl: 'https://images.unsplash.com/photo-1549317661-bd32c8ce0db2?w=1200&q=80',
  avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
  rating: 4.9,
  trips: 312,
  years: 8,
  responseTime: '< 2m',
  hourlyRate: 15.0,
  dailyRate: 80.0,
  weeklyRate: 480.0,
  phone: '+96890000001',
  bio:
      'Licensed professional chauffeur with 8+ years serving Oman. Specialising in corporate, airport and VIP transport. Multilingual and fully insured.',
  languages: ['English', 'Arabic', 'Hindi', 'Urdu'],
  services: [
    (Iconsax.car_copy, 'driver_service_chauffeur', Color(0xFF3D5AFE)),
    (Iconsax.airplane_copy, 'driver_service_airport', Color(0xFF7C4DFF)),
    (Iconsax.map_1_copy, 'driver_service_city', Color(0xFF00BCD4)),
    (Iconsax.route_square_copy, 'driver_service_long', Color(0xFF4CAF50)),
    (Iconsax.crown_copy, 'driver_service_vip', Color(0xFFFFC107)),
    (Iconsax.heart_copy, 'driver_service_wedding', Color(0xFFE91E63)),
  ],
  vehicles: [
    (Iconsax.car_copy, 'Sedan', Color(0xFF3D5AFE)),
    (Iconsax.truck_copy, 'SUV', Color(0xFF7C4DFF)),
    (Iconsax.bus_copy, 'Van', Color(0xFF00BCD4)),
  ],
  availability: [
    ('M', true),
    ('T', true),
    ('W', false),
    ('T', true),
    ('F', true),
    ('S', true),
    ('S', false),
  ],
  reviewCounts: [210, 72, 18, 7, 5],
  reviews: [
    DriverReview(
      author: 'Sarah M.',
      rating: 5.0,
      text: 'Excellent service — punctual, professional, and smooth airport transfer.',
      timeAgo: '2 days ago',
    ),
    DriverReview(
      author: 'James T.',
      rating: 4.8,
      text: 'Knows the city well, great conversation and safe driving throughout.',
      timeAgo: '1 week ago',
    ),
    DriverReview(
      author: 'Fatima A.',
      rating: 5.0,
      text: 'Best driver experience in Oman. Highly recommend for VIP services.',
      timeAgo: '2 weeks ago',
    ),
  ],
);
