import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

enum UserRole { customer, driver }

class RoleProvider extends ChangeNotifier {
  static const _storageKey = 'user_role';

  final FlutterSecureStorage _storage;
  UserRole? _role;

  RoleProvider(this._storage);

  UserRole? get role => _role;
  bool get isCustomer => _role == UserRole.customer;
  bool get isDriver => _role == UserRole.driver;
  bool get isAuthenticated => _role != null;

  Future<void> load() async {
    final raw = await _storage.read(key: _storageKey);
    if (raw != null) {
      _role = UserRole.values.firstWhere(
        (r) => r.name == raw,
        orElse: () => UserRole.customer,
      );
      notifyListeners();
    }
  }

  Future<void> setRole(UserRole role) async {
    _role = role;
    await _storage.write(key: _storageKey, value: role.name);
    notifyListeners();
  }

  Future<void> clear() async {
    _role = null;
    await _storage.delete(key: _storageKey);
    notifyListeners();
  }
}
