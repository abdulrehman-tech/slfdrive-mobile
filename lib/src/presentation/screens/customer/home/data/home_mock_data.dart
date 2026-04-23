import 'package:flutter/material.dart';

import '../models/ad_item.dart';
import '../models/car_brand.dart';
import '../models/car_item.dart';
import '../models/driver_item.dart';

const kHomeBrands = <CarBrand>[
  CarBrand('Tesla', 'assets/images/brands/tesla.png'),
  CarBrand('Mercedes', 'assets/images/brands/mercedes-benz.png'),
  CarBrand('BMW', 'assets/images/brands/bmw.png'),
  CarBrand('Ferrari', 'assets/images/brands/ferrari.png'),
  CarBrand('Toyota', 'assets/images/brands/toyota.png'),
  CarBrand('Audi', 'assets/images/brands/audi.png'),
  CarBrand('Porsche', 'assets/images/brands/porsche.png'),
  CarBrand('Lamborghini', 'assets/images/brands/lamborghini.png'),
];

List<CarItem> buildFeaturedCars() => [
  CarItem(
    id: '1',
    name: 'Mercedes AMG GT',
    imageUrl: 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80',
    pricePerDay: 250,
    horsepower: 523,
    transmission: 'Automatic',
    seats: 2,
    tag: 'Popular',
    isFavourite: true,
  ),
  CarItem(
    id: '2',
    name: 'BMW M4 Competition',
    imageUrl: 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800&q=80',
    pricePerDay: 190,
    horsepower: 510,
    transmission: 'Automatic',
    seats: 4,
    tag: 'New',
  ),
  CarItem(
    id: '3',
    name: 'Porsche 911 Turbo S',
    imageUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&q=80',
    pricePerDay: 320,
    horsepower: 640,
    transmission: 'PDK',
    seats: 4,
    tag: 'Luxury',
  ),
  CarItem(
    id: '4',
    name: 'Lamborghini Huracán',
    imageUrl: 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=800&q=80',
    pricePerDay: 500,
    horsepower: 610,
    transmission: 'Automatic',
    seats: 2,
    tag: 'Exotic',
  ),
];

const kNearbyDrivers = <DriverItem>[
  DriverItem(
    id: '1',
    name: 'Ahmed Al-Farsi',
    avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    rating: 4.9,
    trips: 312,
    speciality: 'Chauffeur',
  ),
  DriverItem(
    id: '2',
    name: 'Mohammed K.',
    avatarUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
    rating: 4.8,
    trips: 198,
    speciality: 'Airport',
  ),
  DriverItem(
    id: '3',
    name: 'Yusuf Hassan',
    avatarUrl: 'https://randomuser.me/api/portraits/men/61.jpg',
    rating: 4.7,
    trips: 421,
    speciality: 'City Tours',
  ),
  DriverItem(
    id: '4',
    name: 'Omar Saeed',
    avatarUrl: 'https://randomuser.me/api/portraits/men/77.jpg',
    rating: 4.9,
    trips: 560,
    speciality: 'Long Trips',
  ),
];

const kHomeAds = <AdItem>[
  AdItem(
    id: 'ad1',
    title: 'Weekend Escape',
    subtitle: '20% off luxury rentals',
    imageUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=1200&q=80',
    gradient: [Color(0xFF0C2485), Color(0xFF3D5AFE)],
  ),
  AdItem(
    id: 'ad2',
    title: 'Pro Chauffeurs',
    subtitle: 'Book a driver in minutes',
    imageUrl: 'https://images.unsplash.com/photo-1494976388531-d1058494cdd8?w=1200&q=80',
    gradient: [Color(0xFF7C4DFF), Color(0xFF4A148C)],
  ),
  AdItem(
    id: 'ad3',
    title: 'Electric Fleet',
    subtitle: 'Zero-emission rides, ready now',
    imageUrl: 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=1200&q=80',
    gradient: [Color(0xFF00BCD4), Color(0xFF006064)],
  ),
  AdItem(
    id: 'ad4',
    title: 'Airport Transfers',
    subtitle: 'Flat rate, 24/7 pickups',
    imageUrl: 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=1200&q=80',
    gradient: [Color(0xFFFF6F00), Color(0xFFE65100)],
  ),
];
