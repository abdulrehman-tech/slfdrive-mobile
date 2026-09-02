import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Android notification channels.
///
/// Shared by the UI isolate and the FCM background isolate, which is why the
/// names are plain strings rather than translation keys: the background isolate
/// has no EasyLocalization, and Android caches a channel's name at creation
/// anyway (recreating it to rename would wipe the user's per-channel sound and
/// importance choices).
///
/// [channelDefault] must match the `default_notification_channel_id` meta-data
/// in AndroidManifest.xml and the `channel_id` the backend sends. A notification
/// addressed to a channel that was never created is silently dropped on
/// Android 8+.
class NotificationChannels {
  const NotificationChannels._();

  static const String defaultId = 'slfdrive_default';
  static const String promotionsId = 'slfdrive_promotions';

  static const AndroidNotificationChannel defaultChannel =
      AndroidNotificationChannel(
    defaultId,
    'Booking updates',
    description: 'Booking confirmations, trip updates and account notices.',
    importance: Importance.high,
  );

  /// Lower importance so marketing can be muted without silencing trip alerts.
  static const AndroidNotificationChannel promotionsChannel =
      AndroidNotificationChannel(
    promotionsId,
    'Offers and promotions',
    description: 'Discounts and promotional messages.',
    importance: Importance.defaultImportance,
  );

  /// Idempotent — safe to call from either isolate, on every launch.
  static Future<void> createAll(FlutterLocalNotificationsPlugin plugin) async {
    final android = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android == null) return;
    await android.createNotificationChannel(defaultChannel);
    await android.createNotificationChannel(promotionsChannel);
  }

  static String idFor(String category) =>
      category == 'promotion' ? promotionsId : defaultId;

  static AndroidNotificationChannel channelFor(String category) =>
      category == 'promotion' ? promotionsChannel : defaultChannel;
}
