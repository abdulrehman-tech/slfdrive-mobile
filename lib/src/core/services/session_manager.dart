import 'package:flutter/foundation.dart';

/// Global signal for an unrecoverable authentication failure — the access token
/// expired (or was rejected) AND the refresh token could not renew it. The
/// [AuthInterceptor] fires [notifyExpired]; the app root listens and forces a
/// logout (clear session → toast "session expired" → route to /auth).
///
/// A plain [ValueNotifier] counter is used (not a bool) so consecutive expiries
/// still notify listeners even if the value was already "expired".
class SessionManager {
  final ValueNotifier<int> expiredSignal = ValueNotifier<int>(0);

  void notifyExpired() => expiredSignal.value++;
}
