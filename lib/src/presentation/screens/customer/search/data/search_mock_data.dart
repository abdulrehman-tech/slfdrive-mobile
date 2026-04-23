import '../models/search_result_car.dart';
import '../models/search_result_driver.dart';

const kSearchAllCars = <SearchResultCar>[
  SearchResultCar(
    id: '1',
    name: 'Mercedes AMG GT',
    imageUrl: 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80',
    pricePerDay: 250,
    brand: 'Mercedes',
    rating: 4.9,
    transmission: 'Automatic',
    seats: 2,
    fuelType: 'Petrol',
  ),
  SearchResultCar(
    id: '2',
    name: 'BMW M4 Competition',
    imageUrl: 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800&q=80',
    pricePerDay: 190,
    brand: 'BMW',
    rating: 4.8,
    transmission: 'Automatic',
    seats: 4,
    fuelType: 'Petrol',
  ),
  SearchResultCar(
    id: '3',
    name: 'Porsche 911 Turbo S',
    imageUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&q=80',
    pricePerDay: 320,
    brand: 'Porsche',
    rating: 4.9,
    transmission: 'PDK',
    seats: 4,
    fuelType: 'Petrol',
  ),
  SearchResultCar(
    id: '4',
    name: 'Toyota Land Cruiser',
    imageUrl: 'https://images.unsplash.com/photo-1594502184342-2e12f877aa73?w=800&q=80',
    pricePerDay: 120,
    brand: 'Toyota',
    rating: 4.7,
    transmission: 'Automatic',
    seats: 7,
    fuelType: 'Diesel',
  ),
  SearchResultCar(
    id: '5',
    name: 'Audi RS7',
    imageUrl: 'https://images.unsplash.com/photo-1606664515524-ed2f786a0bd6?w=800&q=80',
    pricePerDay: 280,
    brand: 'Audi',
    rating: 4.8,
    transmission: 'Automatic',
    seats: 4,
    fuelType: 'Petrol',
  ),
];

const kSearchAllDrivers = <SearchResultDriver>[
  SearchResultDriver(
    id: '1',
    name: 'Ahmed Al-Farsi',
    avatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
    rating: 4.9,
    trips: 312,
    speciality: 'Chauffeur',
    pricePerDay: 80,
  ),
  SearchResultDriver(
    id: '2',
    name: 'Mohammed K.',
    avatarUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
    rating: 4.8,
    trips: 198,
    speciality: 'Airport',
    pricePerDay: 60,
  ),
  SearchResultDriver(
    id: '3',
    name: 'Yusuf Hassan',
    avatarUrl: 'https://randomuser.me/api/portraits/men/61.jpg',
    rating: 4.7,
    trips: 421,
    speciality: 'City Tours',
    pricePerDay: 70,
  ),
];

const kSearchBrands = ['Toyota', 'Mercedes', 'BMW', 'Porsche', 'Audi', 'Ferrari', 'Lamborghini'];
