import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../../constants/storage_keys.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/utils/safe_notifier.dart';

/// Holds the driver's push-notification preference. There is no backend
/// endpoint for it, so it's persisted locally in secure storage and survives
/// app restarts.
class DriverProfileProvider extends ChangeNotifier with SafeNotifier {
  DriverProfileProvider({FlutterSecureStorage? storage})
      : _storage = storage ?? getIt<FlutterSecureStorage>() {
    _load();
  }

  final FlutterSecureStorage _storage;

  bool _pushNotifications = true;
  bool get pushNotifications => _pushNotifications;

  Future<void> _load() async {
    final stored = await _storage.read(key: StorageKeys.driverNotifPush);
    if (stored != null) _pushNotifications = stored == 'true';
    safeNotify();
  }

  Future<void> setPushNotifications(bool value) async {
    if (_pushNotifications == value) return;
    _pushNotifications = value;
    safeNotify();
    try {
      await _storage.write(key: StorageKeys.driverNotifPush, value: '$value');
    } catch (_) {
      // Persistence failed — revert so the UI never lies about a saved state.
      _pushNotifications = !value;
      safeNotify();
    }
  }
}
