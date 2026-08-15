import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart' show XFile;

import '../../constants/endpoints.dart';
import '../../constants/storage_keys.dart';
import '../../core/data/repositories/auth_repository.dart';
import '../../core/data/repositories/customer_repository.dart';
import '../../core/data/repositories/driver_repository.dart';
import '../../core/di/injection_container.dart';
import '../../core/services/driver_session.dart';
import '../../core/errors/app_exception.dart';
import '../../core/models/auth/auth_session.dart';
import '../../core/models/user/user_model.dart';

/// UI-facing auth state. Follows the [RoleProvider] pattern.
///
/// Screens call [sendOtp] then [verifyOtp]; both return null on failure with
/// [error] set to a user-displayable message. The verify call persists tokens
/// via the repository — the caller is responsible for setting the local role
/// (from [User.isDriver]) and navigating.
///
/// Also surfaces the persisted user identity (name, email, phone, photo) so the
/// profile/home screens can render the signed-in user after an app restart, not
/// just within the signup session. Identity is hydrated from secure storage on
/// construction via [loadPersistedSession].
class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository;
  final FlutterSecureStorage _storage;
  final DriverRepository _driverRepository;
  final CustomerRepository _customerRepository;

  AuthProvider(this._repository, this._storage, this._driverRepository, this._customerRepository) {
    loadPersistedSession();
  }

  bool _isLoading = false;
  String? _error;
  int? _pendingUserId;
  bool _requiresOtp = false;
  User? _user;

  // Persisted identity (survives restart; read from secure storage).
  String? _displayName;
  String? _displayEmail;
  String? _displayPhone;
  String? _photoPath;
  bool _isAuthenticated = false;
  bool _isVerified = false;

  bool get isLoading => _isLoading;
  String? get error => _error;

  /// True once the user has signed in (OTP verified). A "guest" who entered via
  /// "Continue as guest" is not authenticated — gate actions on this.
  bool get isAuthenticated => _isAuthenticated;
  bool get isGuest => !_isAuthenticated;

  /// Whether the account is approved/verified by an admin. Drivers start
  /// unverified after profile completion (pending review).
  bool get isVerified => _isVerified;

  /// User id returned by [sendOtp] — pass it to [verifyOtp].
  int? get pendingUserId => _pendingUserId;
  bool get requiresOtp => _requiresOtp;
  User? get user => _user;

  /// Display name of the signed-in user, or null if not signed in.
  String? get displayName => _displayName;
  String? get displayEmail => _displayEmail;
  String? get displayPhone => _displayPhone;

  /// Absolute URL of the user's profile photo (resolved from the stored
  /// relative path), or null when none is set.
  String? get avatarUrl => ApiEndpoints.resolveMediaUrl(_photoPath);

  /// Hydrates the in-memory identity from secure storage. Safe to call on app
  /// start; notifies listeners when done.
  Future<void> loadPersistedSession() async {
    _displayName = await _storage.read(key: StorageKeys.userName);
    _displayEmail = await _storage.read(key: StorageKeys.userEmail);
    _displayPhone = await _storage.read(key: StorageKeys.userPhone);
    _photoPath = await _storage.read(key: StorageKeys.userProfileImage);
    _isAuthenticated = (await _storage.read(key: StorageKeys.isLoggedIn)) == 'true';
    _isVerified = (await _storage.read(key: StorageKeys.isVerified)) == 'true';
    notifyListeners();
  }

  /// Drops any persisted session so the app treats the user as an
  /// unauthenticated guest (used by "Continue as guest"). Clears auth + identity
  /// keys locally — no network call. Leaves the role to [RoleProvider].
  Future<void> enterGuestMode() async {
    const keys = [
      StorageKeys.accessToken,
      StorageKeys.refreshToken,
      StorageKeys.userId,
      StorageKeys.driverId,
      StorageKeys.userEmail,
      StorageKeys.userPhone,
      StorageKeys.userName,
      StorageKeys.userProfileImage,
      StorageKeys.isLoggedIn,
      StorageKeys.isVerified,
    ];
    for (final key in keys) {
      await _storage.delete(key: key);
    }
    _user = null;
    _displayName = null;
    _displayEmail = null;
    _displayPhone = null;
    _photoPath = null;
    _isAuthenticated = false;
    _isVerified = false;
    getIt<DriverSession>().clear();
    notifyListeners();
  }

  /// Re-fetches the driver record (`GET /api/Driver/{id}`) and refreshes the
  /// cached verification status, photo, and profile fields — so admin approval
  /// shows up without a re-login. Best-effort: silently no-ops on failure.
  Future<void> refreshDriverStatus() async {
    final idStr = await _storage.read(key: StorageKeys.userId);
    final id = int.tryParse(idStr ?? '');
    if (id == null) return;
    try {
      final d = await _driverRepository.getById(id);
      if (d == null) return;
      _isVerified = d.isVerified;
      _displayName = d.fullName ?? _displayName;
      _displayEmail = d.email ?? _displayEmail;
      _displayPhone = d.phoneNumber ?? _displayPhone;
      _photoPath = d.photoUrl ?? _photoPath;

      await _storage.write(key: StorageKeys.isVerified, value: d.isVerified.toString());
      if (d.fullName != null) {
        await _storage.write(key: StorageKeys.userName, value: d.fullName);
      }
      if (d.photoUrl != null) {
        await _storage.write(key: StorageKeys.userProfileImage, value: d.photoUrl);
      }
      // Cache the driver-entity id used to filter the driver's bookings.
      if (d.driverId != null) {
        await _storage.write(key: StorageKeys.driverId, value: d.driverId.toString());
      }
      notifyListeners();
    } catch (_) {
      // Status refresh is best-effort; keep the cached value on failure.
    }
  }

  /// Re-fetches the customer record (`GET /api/Customer/{id}`) and refreshes
  /// the cached profile fields. Best-effort: silently no-ops on failure.
  Future<void> refreshCustomerStatus() async {
    final idStr = await _storage.read(key: StorageKeys.userId);
    final id = int.tryParse(idStr ?? '');
    if (id == null) return;
    try {
      final c = await _customerRepository.getById(id);
      if (c == null) return;
      _displayName = c.fullName ?? _displayName;
      _displayEmail = c.email ?? _displayEmail;
      _displayPhone = c.phoneNumber ?? _displayPhone;
      _photoPath = c.photoUrl ?? _photoPath;

      if (c.fullName != null) {
        await _storage.write(key: StorageKeys.userName, value: c.fullName);
      }
      if (c.email != null) {
        await _storage.write(key: StorageKeys.userEmail, value: c.email);
      }
      if (c.photoUrl != null) {
        await _storage.write(key: StorageKeys.userProfileImage, value: c.photoUrl);
      }
      notifyListeners();
    } catch (_) {
      // Best-effort; keep cached values on failure.
    }
  }

  void _applyUser(User user) {
    _user = user;
    _displayName = user.fullName ?? _displayName;
    _displayEmail = user.email ?? _displayEmail;
    _displayPhone = user.phoneNumber ?? _displayPhone;
    _photoPath = user.photoUrl ?? _photoPath;
    _isVerified = user.isVerified ?? _isVerified;
    _isAuthenticated = true;
  }

  /// Sends an OTP to [phoneNumber]. Returns the session on success (also stored
  /// in [pendingUserId]/[requiresOtp]), or null on failure with [error] set.
  Future<AuthSession?> sendOtp({
    required String phoneNumber,
    required String preferredLang,
    String channel = 'sms',
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final session = await _repository.sendOtp(
        phoneNumber: phoneNumber,
        preferredLang: preferredLang,
        channel: channel,
      );
      _pendingUserId = session.user?.id;
      _requiresOtp = session.requiresOtp;
      return session;
    } on AppException catch (e) {
      _error = e.message;
      return null;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Verifies [otpCode] for [userId]. Returns the user on success (tokens are
  /// persisted by the repository), or null on failure with [error] set.
  Future<User?> verifyOtp({required int userId, required String otpCode}) async {
    _setLoading(true);
    _error = null;
    try {
      final user = await _repository.verifyOtp(userId: userId, otpCode: otpCode);
      _applyUser(user);
      return user;
    } on AppException catch (e) {
      _error = e.message;
      return null;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Completes an individual customer's profile (role 3). Returns the updated
  /// user on success (also stored in [user]), or null on failure with [error].
  Future<User?> completeIndividualProfile({
    required int userId,
    required String fullName,
    String? fullNameAr,
    required String email,
    required String gender,
    required String preferredLang,
    required String dateOfBirthIso,
    XFile? photo,
    double? lat,
    double? lon,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final user = await _repository.completeIndividualProfile(
        userId: userId,
        fullName: fullName,
        fullNameAr: fullNameAr,
        email: email,
        gender: gender,
        preferredLang: preferredLang,
        dateOfBirthIso: dateOfBirthIso,
        photo: photo,
        lat: lat,
        lon: lon,
      );
      _applyUser(user);
      return user;
    } on AppException catch (e) {
      _error = e.message;
      return null;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  /// Completes a driver's profile (role 2). Returns the updated user on success
  /// (also stored in [user]), or null on failure with [error].
  Future<User?> completeDriverProfile({
    required int userId,
    required String fullName,
    String? fullNameAr,
    required String email,
    required String gender,
    required String preferredLang,
    required String dateOfBirthIso,
    required String licenceNumber,
    String? carPlateNumber,
    required String licenceExpiryIso,
    int? locationId,
    bool? hasVehicle,
    String? languagesKnown,
    int? yearsOfExperience,
    double? amountPerDay,
    double? amountPerHour,
    XFile? photo,
    XFile? civilIdFront,
    XFile? civilIdBack,
    XFile? drivingLicenseFront,
    XFile? drivingLicenseBack,
    XFile? medicalReport,
    double? lat,
    double? lon,
  }) async {
    _setLoading(true);
    _error = null;
    try {
      final user = await _repository.completeDriverProfile(
        userId: userId,
        fullName: fullName,
        fullNameAr: fullNameAr,
        email: email,
        gender: gender,
        preferredLang: preferredLang,
        dateOfBirthIso: dateOfBirthIso,
        licenceNumber: licenceNumber,
        carPlateNumber: carPlateNumber,
        licenceExpiryIso: licenceExpiryIso,
        locationId: locationId,
        hasVehicle: hasVehicle,
        languagesKnown: languagesKnown,
        yearsOfExperience: yearsOfExperience,
        amountPerDay: amountPerDay,
        amountPerHour: amountPerHour,
        photo: photo,
        civilIdFront: civilIdFront,
        civilIdBack: civilIdBack,
        drivingLicenseFront: drivingLicenseFront,
        drivingLicenseBack: drivingLicenseBack,
        medicalReport: medicalReport,
        lat: lat,
        lon: lon,
      );
      _applyUser(user);
      return user;
    } on AppException catch (e) {
      _error = e.message;
      return null;
    } catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    await _repository.logout();
    _resetSessionState();
  }

  /// Permanently deletes the signed-in user's account (soft-delete server-side)
  /// and clears the local session. Returns true on success; on failure the
  /// session is kept and [error] carries a displayable message.
  Future<bool> deleteAccount() async {
    _error = null;
    try {
      await _repository.deleteAccount();
      _resetSessionState();
      return true;
    } on AppException catch (e) {
      _error = e.message;
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  void _resetSessionState() {
    _user = null;
    _pendingUserId = null;
    _requiresOtp = false;
    _displayName = null;
    _displayEmail = null;
    _displayPhone = null;
    _photoPath = null;
    _isAuthenticated = false;
    _isVerified = false;
    getIt<DriverSession>().clear();
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
