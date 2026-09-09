import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slfdrive/src/core/models/notification/push_payload.dart';
import 'package:slfdrive/src/core/services/notification_inbox_store.dart';
import 'package:slfdrive/src/core/services/push_messaging_service.dart';
import 'package:slfdrive/src/presentation/screens/customer/notifications/models/notif_item.dart';
import 'package:slfdrive/src/presentation/screens/customer/notifications/provider/notifications_provider.dart';

/// A real FCM message id: colons and percent signs, neither of which survives a
/// URL path segment unescaped.
const fcmMessageId = '0:1756900000000000%1e8a2b3c1e8a2b3c';

PushPayload payload({
  required String id,
  String type = 'system',
  String title = 'Title',
  String body = 'Body',
  DateTime? sentAt,
}) =>
    PushPayload(
      id: id,
      type: type,
      category: PushPayload.categoryForType(type),
      title: title,
      body: body,
      sentAt: sentAt ?? DateTime(2026, 9, 3, 12),
      data: {'type': type},
    );

/// Records what the inbox asks the system tray to do.
class FakeTray implements NotificationTray {
  int clearedAll = 0;
  final List<String> cancelled = [];

  @override
  Future<void> clearDeliveredNotifications() async => clearedAll++;

  @override
  Future<void> cancelDelivered(String payloadId) async => cancelled.add(payloadId);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late NotificationsProvider provider;
  late FakeTray tray;

  NotificationsProvider build() => NotificationsProvider(
        store: NotificationInboxStore(),
        tray: tray,
      );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    tray = FakeTray();
    provider = build();
  });

  group('lookup by id', () {
    test('finds an item whose id was escaped for the route path', () async {
      await provider.ingest(payload(id: fcmMessageId));

      // What notif_tile pushes, and what the router hands back if it does not
      // decode the segment itself.
      final escaped = Uri.encodeComponent(fcmMessageId);
      expect(escaped, isNot(fcmMessageId), reason: 'the id needs escaping');

      expect(provider.byId(escaped), isNotNull,
          reason: 'the detail screen must resolve the escaped id');
      expect(provider.byId(fcmMessageId), isNotNull,
          reason: 'and the raw id when the router already decoded it');
    });

    test('an unknown id resolves to null rather than throwing', () async {
      await provider.ingest(payload(id: 'a'));
      expect(provider.byId('nope'), isNull);
      // A stray '%' is not valid percent-encoding; decoding must not blow up.
      expect(provider.byId('100%'), isNull);
    });
  });

  group('dedupe', () {
    test('the same id is never stored twice', () async {
      await provider.ingest(payload(id: fcmMessageId));
      await provider.ingest(payload(id: fcmMessageId));
      expect(provider.items, hasLength(1));
    });

    test('identical content with a fresh id is treated as a redelivery',
        () async {
      // What a backend that omits notificationId produces: FCM assigns a new
      // messageId per delivery attempt.
      await provider.ingest(payload(id: 'msg-1'));
      await provider.ingest(
          payload(id: 'msg-2', sentAt: DateTime(2026, 9, 3, 12, 0, 30)));
      expect(provider.items, hasLength(1));
    });

    test('the same text sent again much later is a real notification',
        () async {
      await provider.ingest(payload(id: 'msg-1'));
      await provider.ingest(
          payload(id: 'msg-2', sentAt: DateTime(2026, 9, 3, 18)));
      expect(provider.items, hasLength(2));
    });
  });

  group('read state', () {
    test('opening an item marks it read and drops it from the tray', () async {
      await provider.ingest(payload(id: 'b', type: 'promotion'));
      expect(provider.unreadCount, 1);

      provider.openAndMarkRead('b');
      expect(provider.unreadCount, 0);
      expect(tray.cancelled, ['b'],
          reason: 'a read notification must not linger in the tray');
    });

    test('opening the inbox clears the tray and the launcher badge', () async {
      await provider.ingest(payload(id: 'b'));
      provider.onInboxOpened();
      expect(tray.clearedAll, 1);
    });

    test('mark-all-read clears the tray', () async {
      await provider.ingest(payload(id: 'b'));
      provider.markAllRead();
      expect(tray.clearedAll, 1);
      expect(provider.unreadCount, 0);
    });

    test('opening by the escaped id still marks it read', () async {
      await provider.ingest(payload(id: fcmMessageId));
      provider.openAndMarkRead(Uri.encodeComponent(fcmMessageId));
      expect(provider.unreadCount, 0);
    });
  });

  test('items persist and reload newest-first', () async {
    await provider.ingest(
        payload(id: 'old', title: 'Old', sentAt: DateTime(2026, 9, 1)));
    await provider.ingest(
        payload(id: 'new', title: 'New', sentAt: DateTime(2026, 9, 3)));

    final reloaded = build();
    await reloaded.load();

    expect(reloaded.items.map((NotifItem n) => n.id).toList(), ['new', 'old']);
  });
}
