import 'package:firebase_messaging/firebase_messaging.dart';

/// A received push, normalised into the shape the app stores and routes on.
///
/// Deliberately free of Flutter imports: this is constructed inside the FCM
/// **background isolate**, which runs on a cold Dart VM with no widget binding,
/// no `getIt`, no providers and no EasyLocalization.
///
/// The wire contract (all FCM `data` values arrive as strings):
///
/// | key              | meaning                                              |
/// |------------------|------------------------------------------------------|
/// | `type`           | booking / booking_status / payment / promotion /     |
/// |                  | system / account / earnings — drives routing         |
/// | `category`       | booking / promotion / system — drives tab + channel   |
/// | `bookingId`      | deep-link target for booking-ish types                |
/// | `notificationId` | server-unique dedupe key (falls back to messageId)    |
/// | `sentAt`         | ISO-8601 UTC (falls back to receive time)             |
/// | `title` / `body` | mirror of the `notification` block                    |
/// | `targetRole`     | customer / driver — mismatches are suppressed         |
/// | `route`          | explicit route override, still role-fenced            |
class PushPayload {
  /// Stable dedupe key: `notificationId`, else the FCM message id, else a
  /// timestamp (only reachable for a malformed send).
  final String id;
  final String type;
  final String category;
  final String? title;
  final String? body;
  final DateTime sentAt;
  final Map<String, String> data;

  const PushPayload({
    required this.id,
    required this.type,
    required this.category,
    required this.title,
    required this.body,
    required this.sentAt,
    required this.data,
  });

  String? get bookingId => _nonEmpty(data['bookingId']);
  String? get targetRole => _nonEmpty(data['targetRole']);

  /// Explicit server-supplied route. Only honoured when it looks like an in-app
  /// path; it is still passed through the role fence in [resolvePushRoute].
  String? get explicitRoute {
    final r = _nonEmpty(data['route']);
    return (r != null && r.startsWith('/')) ? r : null;
  }

  factory PushPayload.fromRemoteMessage(RemoteMessage message) {
    final data = <String, String>{
      for (final e in message.data.entries) e.key: '${e.value}',
    };
    final type = _nonEmpty(data['type']) ?? 'system';
    return PushPayload(
      id: _nonEmpty(data['notificationId']) ??
          _nonEmpty(message.messageId) ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      type: type,
      category: _nonEmpty(data['category']) ?? categoryForType(type),
      title: _nonEmpty(message.notification?.title) ?? _nonEmpty(data['title']),
      body: _nonEmpty(message.notification?.body) ?? _nonEmpty(data['body']),
      sentAt: _parseDate(data['sentAt']) ?? DateTime.now(),
      data: data,
    );
  }

  factory PushPayload.fromJson(Map<String, dynamic> json) {
    final type = _nonEmpty(json['type'] as String?) ?? 'system';
    return PushPayload(
      id: '${json['id']}',
      type: type,
      category: _nonEmpty(json['category'] as String?) ?? categoryForType(type),
      title: _nonEmpty(json['title'] as String?),
      body: _nonEmpty(json['body'] as String?),
      sentAt: _parseDate(json['sentAt'] as String?) ?? DateTime.now(),
      data: {
        for (final e in (json['data'] as Map? ?? const {}).entries)
          '${e.key}': '${e.value}',
      },
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'category': category,
        'title': title,
        'body': body,
        'sentAt': sentAt.toIso8601String(),
        'data': data,
      };

  /// Default `category` when the server omits it. Keep in sync with the channel
  /// ids created in `PushMessagingService.init()`.
  static String categoryForType(String type) {
    switch (type) {
      case 'booking':
      case 'booking_status':
      case 'payment':
        return 'booking';
      case 'promotion':
        return 'promotion';
      default:
        return 'system';
    }
  }

  static String? _nonEmpty(String? v) =>
      (v == null || v.trim().isEmpty) ? null : v.trim();

  static DateTime? _parseDate(String? v) {
    final s = _nonEmpty(v);
    if (s == null) return null;
    return DateTime.tryParse(s)?.toLocal();
  }
}
