import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../../../../constants/storage_keys.dart';
import '../../../../../core/di/injection_container.dart';

/// Holds the driver's notification-channel preferences. There is no backend
/// endpoint for these, so they're persisted locally in secure storage and
/// survive app restarts (previously they were dead in-memory state).
class DriverProfileProvider extends ChangeNotifier {
  DriverProfileProvider({FlutterSecureStorage? storage})
      : _storage = storage ?? getIt<FlutterSecureStorage>() {
    _load();
  }

  final FlutterSecureStorage _storage;

  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;

  bool get pushNotifications => _pushNotifications;
  bool get emailNotifications => _emailNotifications;
  bool get smsNotifications => _smsNotifications;

  Future<void> _load() async {
    Future<bool> read(String key, bool fallback) async =>
        (await _storage.read(key: key)) == null
            ? fallback
            : (await _storage.read(key: key)) == 'true';

    _pushNotifications = await read(StorageKeys.driverNotifPush, true);
    _emailNotifications = await read(StorageKeys.driverNotifEmail, true);
    _smsNotifications = await read(StorageKeys.driverNotifSms, false);
    notifyListeners();
  }

  void setPushNotifications(bool value) {
    if (_pushNotifications == value) return;
    _pushNotifications = value;
    _storage.write(key: StorageKeys.driverNotifPush, value: '$value');
    notifyListeners();
  }

  void setEmailNotifications(bool value) {
    if (_emailNotifications == value) return;
    _emailNotifications = value;
    _storage.write(key: StorageKeys.driverNotifEmail, value: '$value');
    notifyListeners();
  }

  void setSmsNotifications(bool value) {
    if (_smsNotifications == value) return;
    _smsNotifications = value;
    _storage.write(key: StorageKeys.driverNotifSms, value: '$value');
    notifyListeners();
  }
}
