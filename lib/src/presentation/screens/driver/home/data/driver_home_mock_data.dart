import '../models/trip_request.dart';

const List<TripRequest> kMockTripRequests = [
  TripRequest(
    id: '1',
    customer: 'Ahmed Al-Farsi',
    pickup: 'Muscat Grand Mall',
    destination: 'Ruwi',
    distance: '5.2 km',
    fare: 12.50,
    time: '2 min',
  ),
  TripRequest(
    id: '2',
    customer: 'Sarah Johnson',
    pickup: 'Airport Terminal 1',
    destination: 'Al Khuwair',
    distance: '8.5 km',
    fare: 18.00,
    time: '5 min',
  ),
];

const double kMockTodayEarnings = 145.50;
const int kMockTotalTrips = 12;
const double kMockRating = 4.8;
