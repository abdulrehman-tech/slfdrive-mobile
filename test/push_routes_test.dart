import 'package:flutter_test/flutter_test.dart';
import 'package:slfdrive/src/core/models/notification/push_payload.dart';
import 'package:slfdrive/src/presentation/providers/role_provider.dart';
import 'package:slfdrive/src/presentation/routes/push_routes.dart';

PushPayload payload(String type, {Map<String, String> data = const {}}) =>
    PushPayload(
      id: 'n1',
      type: type,
      category: PushPayload.categoryForType(type),
      title: 't',
      body: 'b',
      sentAt: DateTime(2026, 9, 2),
      data: {'type': type, ...data},
    );

void main() {
  group('resolvePushRoute — customer', () {
    test('booking with an id deep-links to the booking detail', () {
      expect(
        resolvePushRoute(payload('booking', data: {'bookingId': '1042'}),
            UserRole.customer),
        '/bookings/1042',
      );
    });

    test('booking without an id falls back to the list', () {
      expect(resolvePushRoute(payload('booking_status'), UserRole.customer),
          '/bookings');
    });

    test('promotions and unknown types land on the inbox', () {
      expect(resolvePushRoute(payload('promotion'), UserRole.customer),
          '/notifications');
      expect(resolvePushRoute(payload('who_knows'), UserRole.customer),
          '/notifications');
    });
  });

  group('resolvePushRoute — driver', () {
    // The router's redirect guard bounces a driver off any non-/driver route
    // that isn't shared-authed, so a driver must never be sent to the
    // customer-scoped booking detail.
    test('booking pushes go to the driver trips tab, never /bookings/:id', () {
      final route = resolvePushRoute(
          payload('booking', data: {'bookingId': '1042'}), UserRole.driver);
      expect(route, '/driver/trips');
      expect(route, isNot(startsWith('/bookings')));
    });

    test('earnings pushes go to the driver earnings tab', () {
      expect(resolvePushRoute(payload('earnings'), UserRole.driver),
          '/driver/earnings');
    });

    test('the inbox is reachable — it is exempt from the role fence', () {
      expect(resolvePushRoute(payload('system'), UserRole.driver),
          '/notifications');
    });
  });

  group('resolvePushRoute — guards', () {
    test('a guest is never routed', () {
      expect(resolvePushRoute(payload('booking'), null), isNull);
    });

    test('a cross-role send is suppressed', () {
      expect(
        resolvePushRoute(
            payload('booking', data: {'targetRole': 'driver'}),
            UserRole.customer),
        isNull,
      );
      expect(
        resolvePushRoute(
            payload('booking', data: {'targetRole': 'customer'}),
            UserRole.customer),
        '/bookings',
      );
    });

    test('an explicit route is honoured for a customer', () {
      expect(
        resolvePushRoute(
            payload('system', data: {'route': '/cars/7'}), UserRole.customer),
        '/cars/7',
      );
    });

    test('an explicit customer-scoped route cannot strand a driver', () {
      // Would otherwise be redirected to /driver/home by the router anyway;
      // resolving it here keeps the destination predictable.
      expect(
        resolvePushRoute(
            payload('system', data: {'route': '/cars/7'}), UserRole.driver),
        '/driver/home',
      );
    });

    test('a non-path route value is ignored', () {
      expect(
        resolvePushRoute(
            payload('system', data: {'route': 'https://evil.example'}),
            UserRole.customer),
        '/notifications',
      );
    });
  });
}
