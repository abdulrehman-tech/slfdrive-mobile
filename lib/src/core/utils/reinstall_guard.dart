import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../constants/storage_keys.dart';

/// SharedPreferences key written once this install has been checked.
const String installMarkerKey = 'install_marker';

/// Key EasyLocalization persists the chosen locale under. Every install that got
/// past language selection has it, so it identifies installs that predate
/// [installMarkerKey] (an app upgrade, not a reinstall).
const String _easyLocalizationLocaleKey = 'locale';

/// Clears a previous install's session on a fresh install.
///
/// iOS keeps Keychain items (our secure storage) after the app is deleted, while
/// SharedPreferences is wiped. Without this a reinstalled app boots straight into
/// the old account and skips language selection and onboarding. The device id is
/// kept: it is meant to stay stable for the backend's device rows.
Future<void> clearSessionOnReinstall(FlutterSecureStorage storage) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey(installMarkerKey)) return;

    final isUpgrade = prefs.containsKey(_easyLocalizationLocaleKey);
    if (!isUpgrade) {
      final deviceId = await storage.read(key: StorageKeys.deviceId);
      await storage.deleteAll();
      if (deviceId != null) {
        await storage.write(key: StorageKeys.deviceId, value: deviceId);
      }
    }
    await prefs.setBool(installMarkerKey, true);
  } catch (e) {
    // Never block startup on this; worst case the old session survives.
    debugPrint('clearSessionOnReinstall failed: $e');
  }
}
