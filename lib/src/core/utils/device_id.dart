import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../constants/storage_keys.dart';
import '../../presentation/utils/platform_utils.dart';

/// Stable per-install device identifier, sent with the FCM token so the backend
/// can key device rows as `(userId, deviceId)`.
///
/// Resolved once from the platform — `Settings.Secure.ANDROID_ID` on Android,
/// `identifierForVendor` on iOS — then cached in secure storage and served from
/// there forever after. The caching is the point: neither platform value is
/// permanent (ANDROID_ID resets on factory reset and is scoped to the app
/// signing key; identifierForVendor rotates once every app from the vendor is
/// uninstalled), so reading it fresh each time would let a rotation silently
/// fork a second device row mid-session. It also keeps the hot path off a
/// platform channel.
///
/// Neither value is the advertising ID, which this app strips entirely (see the
/// AD_ID `tools:node="remove"` in AndroidManifest.xml). They do count as
/// "Device or other IDs" on the Play Data Safety form.
Future<String> ensureDeviceId(FlutterSecureStorage storage) {
  final cached = _cachedDeviceId;
  if (cached != null) return Future.value(cached);
  // Single-flight. syncToken() legitimately fires from several places at once
  // right after login (session hydration, _applyUser, the permission grant), and
  // without this each one races to write the same key — on iOS the losers throw
  // errSecDuplicateItem (-25299) out of an unawaited call.
  return _inflight ??=
      _resolveAndCache(storage).whenComplete(() => _inflight = null);
}

String? _cachedDeviceId;
Future<String>? _inflight;

/// Test hook: drops the in-memory cache so a fresh resolve can be exercised.
@visibleForTesting
void resetDeviceIdCache() {
  _cachedDeviceId = null;
  _inflight = null;
}

Future<String> _resolveAndCache(FlutterSecureStorage storage) async {
  final stored = await storage.read(key: StorageKeys.deviceId);
  if (stored != null && stored.isNotEmpty) return _cachedDeviceId = stored;

  final resolved = await _resolvePlatformId() ?? _randomId();
  try {
    await storage.write(key: StorageKeys.deviceId, value: resolved);
  } catch (e) {
    // Most likely errSecDuplicateItem from a concurrent writer. Whatever
    // actually landed in the keychain wins, so both callers agree on one id.
    debugPrint('[Push] Device id write failed, re-reading: $e');
    final raced = await storage.read(key: StorageKeys.deviceId);
    if (raced != null && raced.isNotEmpty) return _cachedDeviceId = raced;
  }
  return _cachedDeviceId = resolved;
}

Future<String?> _resolvePlatformId() async {
  try {
    final info = DeviceInfoPlugin();
    if (PlatformUtils.isAndroid) {
      final id = (await info.androidInfo).id;
      return id.isEmpty ? null : id;
    }
    if (PlatformUtils.isIOS) {
      // Genuinely nullable — notably before the first device unlock.
      final id = (await info.iosInfo).identifierForVendor;
      return (id == null || id.isEmpty) ? null : id;
    }
  } catch (e) {
    debugPrint('[Push] Could not read platform device id: $e');
  }
  return null;
}

/// Fallback only, for when the platform returns nothing. Persisted like any
/// other resolved value, so it stays stable for this install.
String _randomId() {
  final rnd = Random.secure();
  final bytes = List<int>.generate(16, (_) => rnd.nextInt(256));
  return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
