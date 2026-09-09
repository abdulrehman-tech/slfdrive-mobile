import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../constants/storage_keys.dart';
import '../../presentation/utils/platform_utils.dart';
import '../data/repositories/push_repository.dart';
import '../models/notification/push_payload.dart';
import '../utils/device_id.dart';
import 'notification_channels.dart';
import 'notification_inbox_store.dart';

/// Normalised notification-permission state. Wraps FCM's [AuthorizationStatus]
/// so callers don't have to think about platform differences.
enum PushAuthStatus {
  /// Never asked. The only state in which the OS prompt may be shown.
  notDetermined,
  authorized,
  provisional,
  denied,

  /// Web, or a build where Firebase failed to initialise.
  unsupported,
}

/// The slice of push behaviour the notification inbox needs.
///
/// Exists so [NotificationsProvider] depends on two methods rather than the
/// whole messaging service — which also keeps the inbox unit-testable without
/// standing up Firebase.
abstract class NotificationTray {
  /// Clears every notification this app has posted from the system tray.
  Future<void> clearDeliveredNotifications();

  /// Clears one, matched by the id it was displayed with.
  Future<void> cancelDelivered(String payloadId);
}

/// Owns everything FCM: channels, permission, token lifecycle, and the routing
/// of received messages and taps.
///
/// Registered as a lazy **singleton** — the message listeners and the pending-tap
/// queue must survive across screens, and a factory would drop them.
///
/// Two things it deliberately never does in [init]: request permission (that is
/// the pre-permission sheet's job, at a moment of user intent) and upload a
/// token (that needs a JWT, so it is driven by the auth lifecycle).
class PushMessagingService implements NotificationTray {
  PushMessagingService(this._repo, this._storage, this._inbox);

  final PushRepository _repo;
  final FlutterSecureStorage _storage;
  final NotificationInboxStore _inbox;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _local = FlutterLocalNotificationsPlugin();

  bool _initialised = false;
  bool _firebaseReady = true;

  /// Set false by `main()` when `Firebase.initializeApp()` throws, so a fresh
  /// clone without `google-services.json` still runs.
  set firebaseReady(bool value) => _firebaseReady = value;

  bool get _supported => PlatformUtils.isMobile && _firebaseReady;

  /// Called when a tap needs routing. Same idiom as `SessionManager.expiredSignal`.
  final ValueNotifier<int> tapSignal = ValueNotifier<int>(0);

  final List<PushPayload> _pendingTaps = [];

  /// Foreground-message sink, wired by `main()` to `NotificationsProvider.ingest`.
  /// Injected rather than resolved so this core service stays free of providers.
  Future<void> Function(PushPayload)? onMessageReceived;

  bool get hasPendingTap => _pendingTaps.isNotEmpty;

  PushPayload? takePendingTap() =>
      _pendingTaps.isEmpty ? null : _pendingTaps.removeAt(0);

  /// Puts a tap back at the head of the queue when the app wasn't ready to route
  /// it yet (splash still owns navigation, or there is no context).
  void requeueTap(PushPayload payload) => _pendingTaps.insert(0, payload);

  // ── lifecycle ────────────────────────────────────────────────────────────

  /// Idempotent bootstrap. Fire-and-forget from `main()`; never blocks the first
  /// frame.
  Future<void> init() async {
    if (_initialised || !_supported) return;
    _initialised = true;

    try {
      await _initLocalNotifications();
      await NotificationChannels.createAll(_local);

      // iOS renders its own foreground banner from this; Android has no
      // equivalent, so there we display a local notification ourselves.
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: false,
        sound: true,
      );

      FirebaseMessaging.onMessage.listen(_onForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_onOpenedFromBackground);
      _messaging.onTokenRefresh.listen((token) => _uploadToken(token: token));

      // Cold start: the app was launched by tapping a notification. Queue it —
      // no listener exists yet and the router is still on the splash route.
      final initial = await _messaging.getInitialMessage();
      if (initial != null) {
        final payload = PushPayload.fromRemoteMessage(initial);
        // Record it as well as routing it. On Android the background isolate
        // already queued this one and ingest dedupes by id, but on iOS that
        // isolate is not guaranteed to run for a terminated app — without this
        // the message the user just tapped would never appear in the inbox.
        onMessageReceived?.call(payload);
        _enqueueTap(payload);
      }

      // Same, for a locally-displayed notification (foreground message shown by
      // us, then tapped after the app was backgrounded and killed). FCM's
      // getInitialMessage does not cover these.
      final launch = await _local.getNotificationAppLaunchDetails();
      if (launch?.didNotificationLaunchApp ?? false) {
        _decodeLocalPayload(launch!.notificationResponse?.payload);
      }
    } catch (e) {
      debugPrint('[Push] init failed: $e');
    }
  }

  Future<void> _initLocalNotifications() async {
    await _local.initialize(
      const InitializationSettings(
        // Monochrome silhouette; see res/drawable/ic_stat_notification.xml.
        android: AndroidInitializationSettings('ic_stat_notification'),
        // All three false: permission is owned solely by the pre-permission
        // sheet via FirebaseMessaging.requestPermission(). Leaving these true is
        // the classic cause of a double prompt on iOS.
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
      onDidReceiveBackgroundNotificationResponse:
          localNotificationBackgroundTapHandler,
    );
  }


  // ── permission ───────────────────────────────────────────────────────────

  Future<PushAuthStatus> currentStatus() async {
    if (!_supported) return PushAuthStatus.unsupported;
    try {
      if (PlatformUtils.isAndroid) {
        // firebase_messaging reports only authorized/denied on Android — it
        // maps straight off POST_NOTIFICATIONS, so a fresh install that has
        // never been asked is indistinguishable from a hard refusal, and both
        // arrive as `denied`. That silently suppressed the priming sheet (which
        // only offers on notDetermined) and the token upload with it.
        // permission_handler can tell the two apart, which is exactly what the
        // gate needs.
        final status = await Permission.notification.status;
        if (status.isGranted) return PushAuthStatus.authorized;
        // permanentlyDenied on Android 13+ means the OS will no longer show the
        // prompt; on Android 12- it means notifications were switched off in
        // settings. Either way, Settings is the only way back.
        if (status.isPermanentlyDenied || status.isRestricted) {
          return PushAuthStatus.denied;
        }
        return PushAuthStatus.notDetermined;
      }
      final settings = await _messaging.getNotificationSettings();
      return _map(settings.authorizationStatus);
    } catch (e) {
      debugPrint('[Push] Could not read notification settings: $e');
      return PushAuthStatus.unsupported;
    }
  }

  /// Fires the OS dialog. Only ever called from the pre-permission sheet's
  /// "Allow" — iOS shows this exactly once per install, so it must never be
  /// spent on a user who hasn't seen the rationale.
  Future<PushAuthStatus> requestSystemPermission() async {
    if (!_supported) return PushAuthStatus.unsupported;
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );
      final status = _map(settings.authorizationStatus);
      final granted = status == PushAuthStatus.authorized ||
          status == PushAuthStatus.provisional;
      await setEnabled(granted);
      return status;
    } catch (e) {
      debugPrint('[Push] Permission request failed: $e');
      return PushAuthStatus.denied;
    }
  }

  /// Recovery path for a permanently denied permission — the OS will not show
  /// the prompt again, so the only way back is Settings.
  Future<void> openSystemSettings() => openAppSettings();

  static PushAuthStatus _map(AuthorizationStatus s) {
    switch (s) {
      case AuthorizationStatus.authorized:
        return PushAuthStatus.authorized;
      case AuthorizationStatus.provisional:
        return PushAuthStatus.provisional;
      case AuthorizationStatus.denied:
        return PushAuthStatus.denied;
      case AuthorizationStatus.notDetermined:
        return PushAuthStatus.notDetermined;
    }
  }

  // ── user preference ──────────────────────────────────────────────────────

  /// Defaults to true: once the OS permission is granted, delivery is on unless
  /// the user turns it off in-app.
  Future<bool> isEnabled() async =>
      (await _storage.read(key: StorageKeys.notificationsEnabled)) != 'false';

  Future<void> setEnabled(bool value) async {
    await _storage.write(
      key: StorageKeys.notificationsEnabled,
      value: value ? 'true' : 'false',
    );
    if (value) {
      await syncToken();
    } else {
      await _deleteToken();
    }
  }

  // ── token lifecycle ──────────────────────────────────────────────────────

  /// Called after login and on every cold start with a live session — cheap
  /// self-healing for a token that rotated while the app was closed.
  Future<void> onUserSignedIn() => syncToken();

  /// Called from every session-teardown path (logout, delete account, guest
  /// mode, forced expiry).
  Future<void> onUserSignedOut() async {
    await _deleteToken();
    await _inbox.clear();
    _pendingTaps.clear();
  }

  /// Re-check on resume: the user may have granted or revoked permission in
  /// system Settings while the app was backgrounded. Also folds in anything the
  /// background isolate queued.
  Future<void> onAppResumed() async {
    if (!_supported) return;
    await syncToken();
  }

  Future<void>? _syncInFlight;

  /// Registers the current token with the backend. Idempotent and silent —
  /// every guard below is a no-op, not an error.
  ///
  /// Single-flighted: login legitimately triggers this from several places at
  /// once (session hydration, _applyUser, the permission grant). Overlapping
  /// runs would race on the device id and could double-PUT, since the
  /// already-registered check only helps once the first run has finished.
  ///
  /// Never throws: every caller is a fire-and-forget `unawaited(...)`, so an
  /// escaping error would surface as an unhandled async exception.
  Future<void> syncToken() =>
      _syncInFlight ??= _syncToken()
          .catchError((Object e) => debugPrint('[Push] syncToken failed: $e'))
          .whenComplete(() => _syncInFlight = null);

  Future<void> _syncToken() async {
    if (!_supported) return _skip('platform unsupported or Firebase not ready');

    // Guard 1: a JWT must exist. This is load-bearing, not defensive: the auth
    // interceptor bearers every request and escalates an unrecoverable 401 into
    // a global forced logout, so firing this against a stale session would eject
    // the user mid-session for a background call they never made.
    final accessToken = await _storage.read(key: StorageKeys.accessToken);
    if (accessToken == null || accessToken.isEmpty) {
      return _skip('no access token (signed out)');
    }

    if (!await isEnabled()) return _skip('user turned notifications off');

    final status = await currentStatus();
    if (status != PushAuthStatus.authorized &&
        status != PushAuthStatus.provisional) {
      return _skip('permission is ${status.name}');
    }

    final token = await _fetchToken();
    if (token == null) {
      return _skip('no FCM token available (iOS Simulator cannot get one)');
    }

    await _uploadToken(token: token);
  }

  /// Debug-only trace of why a sync did nothing. Every branch above is a
  /// legitimate no-op, but silent no-ops are miserable to diagnose on device.
  void _skip(String reason) {
    if (kDebugMode) debugPrint('[Push] syncToken skipped — $reason');
  }

  /// Resolves the FCM token, working around the iOS APNs race.
  ///
  /// On iOS `getToken()` returns null until APNs has handed the device token to
  /// Firebase, which is not guaranteed by the time this first runs even with the
  /// eager `registerForRemoteNotifications()` in AppDelegate. Poll for the APNs
  /// token first, then fall back to the last known good token so registration
  /// still works on a degraded device.
  Future<String?> _fetchToken() async {
    try {
      if (PlatformUtils.isIOS) {
        for (var attempt = 0; attempt < 5; attempt++) {
          if (await _messaging.getAPNSToken() != null) break;
          if (attempt == 4) {
            debugPrint('[Push] APNs token still unavailable after 5 attempts');
            return _storage.read(key: StorageKeys.fcmToken);
          }
          await Future<void>.delayed(const Duration(seconds: 1));
        }
      }
      final token = await _messaging.getToken();
      if (token != null && token.isNotEmpty) return token;
    } catch (e) {
      debugPrint('[Push] getToken failed: $e');
    }
    return _storage.read(key: StorageKeys.fcmToken);
  }

  Future<void> _uploadToken({required String token}) async {
    final userId = await _storage.read(key: StorageKeys.userId);
    if (userId == null || userId.isEmpty) return;

    // Skip a redundant PUT on every cold start. Both keys are written only on a
    // successful upload, so a previous failure naturally retries.
    final storedToken = await _storage.read(key: StorageKeys.fcmToken);
    final storedUser =
        await _storage.read(key: StorageKeys.fcmTokenRegisteredUserId);
    if (storedToken == token && storedUser == userId) {
      return _skip('token already registered for user $userId');
    }

    final ok = await _repo.registerToken(
      deviceId: await ensureDeviceId(_storage),
      platform: PlatformUtils.isIOS ? 'ios' : 'android',
      fcmToken: token,
    );
    if (kDebugMode) {
      debugPrint(ok
          ? '[Push] Token registered for user $userId (${token.substring(0, 12)}…)'
          : '[Push] Token registration REJECTED by the API');
    }
    if (!ok) return;

    await _storage.write(key: StorageKeys.fcmToken, value: token);
    await _storage.write(
      key: StorageKeys.fcmTokenRegisteredUserId,
      value: userId,
    );
  }

  /// Invalidates the token at FCM. There is no server-side delete endpoint, so
  /// this is the only way to stop delivery to a signed-out device — it makes the
  /// backend's stored copy start returning UNREGISTERED, which the backend
  /// should prune on.
  Future<void> _deleteToken() async {
    try {
      if (_supported) await _messaging.deleteToken();
    } catch (e) {
      // Throws on iOS when APNs isn't ready. Clearing locally is still correct.
      debugPrint('[Push] deleteToken failed: $e');
    }
    await _storage.delete(key: StorageKeys.fcmToken);
    await _storage.delete(key: StorageKeys.fcmTokenRegisteredUserId);
  }

  // ── message handling ─────────────────────────────────────────────────────

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    final payload = PushPayload.fromRemoteMessage(message);
    await onMessageReceived?.call(payload);

    // iOS already rendered a banner via setForegroundNotificationPresentationOptions;
    // showing a local one too would duplicate it.
    if (PlatformUtils.isAndroid) {
      await _showLocal(payload);
    }
  }

  Future<void> _showLocal(PushPayload p) async {
    if (p.title == null && p.body == null) return;
    final channel = NotificationChannels.channelFor(p.category);
    try {
      await _local.show(
        p.id.hashCode,
        p.title,
        p.body,
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
        ),
        payload: jsonEncode(p.toJson()),
      );
    } catch (e) {
      debugPrint('[Push] Local notification failed: $e');
    }
  }

  void _onOpenedFromBackground(RemoteMessage message) {
    final payload = PushPayload.fromRemoteMessage(message);
    // Record it too: the foreground handler never saw this one.
    onMessageReceived?.call(payload);
    _enqueueTap(payload);
  }

  void _onLocalNotificationTap(NotificationResponse response) =>
      _decodeLocalPayload(response.payload);

  void _decodeLocalPayload(String? raw) {
    if (raw == null || raw.isEmpty) return;
    try {
      _enqueueTap(
        PushPayload.fromJson(jsonDecode(raw) as Map<String, dynamic>),
      );
    } catch (e) {
      debugPrint('[Push] Could not decode local notification payload: $e');
    }
  }

  /// Removes every notification this app has posted from the system tray.
  ///
  /// Cancels FCM-rendered notifications too, not just the ones displayed via
  /// flutter_local_notifications: on Android this maps to
  /// `NotificationManager.cancelAll()`, which is app-wide. That also clears the
  /// launcher badge dot, which Android derives from the active notifications
  /// rather than from any count we control.
  @override
  Future<void> clearDeliveredNotifications() async {
    if (!_supported) return;
    try {
      await _local.cancelAll();
    } catch (e) {
      debugPrint('[Push] cancelAll failed: $e');
    }
  }

  /// Removes one notification, matched by the same id used when displaying it.
  @override
  Future<void> cancelDelivered(String payloadId) async {
    if (!_supported) return;
    try {
      await _local.cancel(payloadId.hashCode);
    } catch (e) {
      debugPrint('[Push] cancel failed: $e');
    }
  }

  void _enqueueTap(PushPayload payload) {
    _pendingTaps.add(payload);
    tapSignal.value++;
  }
}

/// Tap on a local notification while the app is backgrounded. Must be top-level
/// and entry-point annotated for the same reasons as the FCM background handler.
///
/// Nothing to do in the isolate itself: Android relaunches the app for the tap,
/// and [PushMessagingService.init] picks the payload back up via
/// `getNotificationAppLaunchDetails()`.
@pragma('vm:entry-point')
void localNotificationBackgroundTapHandler(NotificationResponse response) {}
