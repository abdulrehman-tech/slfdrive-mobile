import 'package:flutter/foundation.dart';

class DriverProfileProvider extends ChangeNotifier {
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;

  bool get pushNotifications => _pushNotifications;
  bool get emailNotifications => _emailNotifications;
  bool get smsNotifications => _smsNotifications;

  void setPushNotifications(bool value) {
    if (_pushNotifications == value) return;
    _pushNotifications = value;
    notifyListeners();
  }

  void setEmailNotifications(bool value) {
    if (_emailNotifications == value) return;
    _emailNotifications = value;
    notifyListeners();
  }

  void setSmsNotifications(bool value) {
    if (_smsNotifications == value) return;
    _smsNotifications = value;
    notifyListeners();
  }
}
