import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slfdrive/src/constants/storage_keys.dart';
import 'package:slfdrive/src/core/models/booking/booking.dart';
import 'package:slfdrive/src/core/models/notification/push_payload.dart';
import 'package:slfdrive/src/core/utils/reinstall_guard.dart';
import 'package:slfdrive/src/presentation/screens/customer/notifications/models/notif_item.dart';
import 'package:slfdrive/src/presentation/screens/driver/home/models/trip_request.dart';
import 'package:slfdrive/src/presentation/screens/driver/trips/models/driver_trip.dart';

void main() {
  group('push category', () {
    test('explicit booking/promotion wins', () {
      expect(PushPayload.resolveCategory(category: 'Booking', type: 'x'), 'booking');
      expect(PushPayload.resolveCategory(category: 'promotion', type: 'booking'), 'promotion');
    });

    test('booking-like types are bookings regardless of case', () {
      expect(PushPayload.resolveCategory(type: 'BookingCreated'), 'booking');
      expect(PushPayload.resolveCategory(type: 'PAYMENT_RECEIVED'), 'booking');
    });

    test('a bookingId turns an otherwise-system push into a booking', () {
      expect(PushPayload.resolveCategory(category: 'system', type: 'system', bookingId: '42'), 'booking');
      expect(PushPayload.resolveCategory(type: 'system'), 'system');
    });

    test('backend event_code / related_id payload is a booking with an id', () {
      final p = PushPayload.fromJson({
        'id': 'n1',
        'data': {'event_code': 'BOOKING_CREATED', 'related_entity': 'BOOKING', 'related_id': '161'},
      });
      expect(p.category, 'booking');
      expect(p.bookingId, '161');
    });

    test('inbox rows stored as system before the fix are re-categorised on load', () {
      final item = NotifItem.fromJson({
        'id': '1',
        'category': 'system',
        'title': 't',
        'subtitle': 's',
        'at': DateTime(2026, 9, 23).toIso8601String(),
        'data': {'bookingId': '7'},
      });
      expect(item.category, NotifCategory.booking);
    });
  });

  group('reinstall guard', () {
    setUp(() => FlutterSecureStorage.setMockInitialValues({
          StorageKeys.accessToken: 'old-token',
          StorageKeys.userRole: 'customer',
          StorageKeys.deviceId: 'device-1',
        }));

    test('fresh install (empty prefs) wipes the old session but keeps the device id', () async {
      SharedPreferences.setMockInitialValues({});
      const storage = FlutterSecureStorage();
      await clearSessionOnReinstall(storage);
      expect(await storage.read(key: StorageKeys.accessToken), isNull);
      expect(await storage.read(key: StorageKeys.userRole), isNull);
      expect(await storage.read(key: StorageKeys.deviceId), 'device-1');
    });

    test('upgrade from an older build (locale already saved) keeps the session', () async {
      SharedPreferences.setMockInitialValues({'locale': 'en_US'});
      const storage = FlutterSecureStorage();
      await clearSessionOnReinstall(storage);
      expect(await storage.read(key: StorageKeys.accessToken), 'old-token');
    });

    test('runs once: a marked install is never wiped', () async {
      SharedPreferences.setMockInitialValues({installMarkerKey: true});
      const storage = FlutterSecureStorage();
      await clearSessionOnReinstall(storage);
      expect(await storage.read(key: StorageKeys.accessToken), 'old-token');
    });
  });

  group('driver cards', () {
    test('corporate request waits for company approval; personal one does not', () {
      final corporate = TripRequest.fromBooking(
        const Booking(id: 1, statusId: 5, corporateCompanyId: 3),
        pickup: '',
        dropoff: '',
      );
      final personal = TripRequest.fromBooking(const Booking(id: 2, statusId: 5), pickup: '', dropoff: '');
      expect(corporate.awaitingCorporateApproval, isTrue);
      expect(personal.awaitingCorporateApproval, isFalse);
    });

    test('trip without a resolved place shows no raw coordinates or service id', () {
      final trip = DriverTrip.fromBooking(
        const Booking(id: 3, statusId: 8, serviceType: 'driver', dropoffLat: 23.61, dropoffLon: 58.545),
      )!;
      expect(trip.destination, isNull);
      expect(trip.serviceLabel, isNot('driver'));
    });
  });
}
