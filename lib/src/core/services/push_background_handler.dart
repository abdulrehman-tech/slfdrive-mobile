import 'dart:convert';
import 'dart:ui' show DartPluginRegistrant;

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../../../firebase_options.dart';
import '../models/notification/push_payload.dart';
import 'notification_channels.dart';
import 'notification_inbox_store.dart';

/// FCM background/terminated message handler.
///
/// Runs in a **separate isolate on a cold Dart VM**: there is no `getIt`, no
/// provider tree, no EasyLocalization (so no `.tr()`), and no live navigator.
/// It records the message for the inbox, and displays it only in the one case
/// where nothing else will.
///
/// Requirements, each of which fails silently if missed:
///  * must be a top-level function, never a closure or an instance method;
///  * must carry `@pragma('vm:entry-point')` or AOT tree-shaking removes it from
///    release builds;
///  * must initialise Firebase itself;
///  * must be registered via `FirebaseMessaging.onBackgroundMessage` before
///    `runApp`, passing the bare tear-off.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  try {
    DartPluginRegistrant.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    final payload = PushPayload.fromRemoteMessage(message);
    await NotificationInboxStore.appendPending(payload.toJson());

    // Display ONLY for a data-only message. When the send carries a
    // `notification` block the OS has already put it in the tray, and showing
    // one here would duplicate it. Without this branch a data-only push is
    // invisible while the app is backgrounded — it lands in the inbox and
    // nowhere else, which reads as "notifications only work when the app is
    // open".
    if (message.notification == null) {
      await _showDataOnlyNotification(payload);
    }
  } catch (e) {
    // Delivery already happened; the rest is best-effort. Never let this
    // isolate throw — a crash here can suppress later background wakeups.
    debugPrint('[Push] Background handler failed: $e');
  }
}

Future<void> _showDataOnlyNotification(PushPayload payload) async {
  if (payload.title == null && payload.body == null) return;

  // A fresh isolate means a fresh plugin instance: it has to be initialised and
  // the channels re-created here. Both calls are idempotent.
  final local = FlutterLocalNotificationsPlugin();
  await local.initialize(
    const InitializationSettings(
      android: AndroidInitializationSettings('ic_stat_notification'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    ),
  );
  await NotificationChannels.createAll(local);

  final channel = NotificationChannels.channelFor(payload.category);
  await local.show(
    payload.id.hashCode,
    payload.title,
    payload.body,
    NotificationDetails(
      android: AndroidNotificationDetails(
        channel.id,
        channel.name,
        channelDescription: channel.description,
        importance: channel.importance,
        priority: channel.importance == Importance.high
            ? Priority.high
            : Priority.defaultPriority,
        icon: 'ic_stat_notification',
      ),
      iOS: const DarwinNotificationDetails(),
    ),
    // Carries the deep link through a tap: the main isolate reads it back via
    // getNotificationAppLaunchDetails() when the app relaunches.
    payload: jsonEncode(payload.toJson()),
  );
}
