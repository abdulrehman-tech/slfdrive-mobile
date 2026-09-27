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

  String? get bookingId => bookingIdFrom(data);

  /// The booking a push refers to. The UAT backend doesn't send `bookingId`;
  /// it sends `related_entity: BOOKING` + `related_id: <id>` (with an
  /// `event_code` such as `BOOKING_CREATED` instead of `type`), so accept both.
  static String? bookingIdFrom(Map<String, String> data) {
    final direct = _nonEmpty(data['bookingId']);
    if (direct != null) return direct;
    final entity = _nonEmpty(data['related_entity'])?.toLowerCase();
    return entity == 'booking' ? _nonEmpty(data['related_id']) : null;
  }

  /// `type`, else the backend's `event_code` (e.g. `BOOKING_CREATED`).
  static String typeFrom(Map<String, String> data) =>
      _nonEmpty(data['type']) ?? _nonEmpty(data['event_code'])?.toLowerCase() ?? 'system';

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
    final type = typeFrom(data);
    return PushPayload(
      id: _nonEmpty(data['notificationId']) ??
          _nonEmpty(message.messageId) ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      type: type,
      category: resolveCategory(
        category: data['category'],
        type: type,
        bookingId: bookingIdFrom(data),
      ),
      title: _nonEmpty(message.notification?.title) ?? _nonEmpty(data['title']),
      body: _nonEmpty(message.notification?.body) ?? _nonEmpty(data['body']),
      sentAt: _parseDate(data['sentAt']) ?? DateTime.now(),
      data: data,
    );
  }

  factory PushPayload.fromJson(Map<String, dynamic> json) {
    final data = <String, String>{
      for (final e in (json['data'] as Map? ?? const {}).entries) '${e.key}': '${e.value}',
    };
    final type = _nonEmpty(json['type'] as String?) ?? typeFrom(data);
    return PushPayload(
      id: '${json['id']}',
      type: type,
      category: resolveCategory(
        category: json['category'] as String?,
        type: type,
        bookingId: bookingIdFrom(data),
      ),
      title: _nonEmpty(json['title'] as String?),
      body: _nonEmpty(json['body'] as String?),
      sentAt: _parseDate(json['sentAt'] as String?) ?? DateTime.now(),
      data: data,
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
    final t = type.trim().toLowerCase();
    if (t.contains('booking') || t.contains('payment') || t.contains('trip')) return 'booking';
    if (t.contains('promo') || t.contains('offer')) return 'promotion';
    return 'system';
  }

  /// Picks the inbox category for a push. The backend has been seen sending
  /// booking pushes with no usable `category`/`type` (they landed in System and
  /// the Bookings tab stayed empty), so a push that carries a `bookingId` is
  /// treated as a booking unless the server explicitly says otherwise.
  static String resolveCategory({String? category, required String type, String? bookingId}) {
    final explicit = _nonEmpty(category)?.toLowerCase();
    if (explicit == 'booking' || explicit == 'promotion') return explicit!;
    final inferred = categoryForType(type);
    if (inferred != 'system') return inferred;
    return _nonEmpty(bookingId) != null ? 'booking' : 'system';
  }

  static String? _nonEmpty(String? v) =>
      (v == null || v.trim().isEmpty) ? null : v.trim();

  static DateTime? _parseDate(String? v) {
    final s = _nonEmpty(v);
    if (s == null) return null;
    return DateTime.tryParse(s)?.toLocal();
  }
}
