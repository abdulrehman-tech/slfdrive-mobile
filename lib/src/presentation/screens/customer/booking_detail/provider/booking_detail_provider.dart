import 'package:flutter/material.dart';

import '../data/booking_detail_mock_data.dart';
import '../models/booking_detail.dart';

class BookingDetailProvider extends ChangeNotifier {
  BookingDetailProvider({BookingDetail? booking})
      : booking = booking ?? buildMockBookingDetail();

  final BookingDetail booking;
}
