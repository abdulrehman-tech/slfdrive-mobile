import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart' show XFile;

import '../../../constants/storage_keys.dart';
import '../../errors/app_exception.dart';
import '../../models/auth/auth_session.dart';
import '../../models/user/user_model.dart';
import '../datasources/auth_remote_data_source.dart';

/// Orchestrates the auth flow and persists tokens / session to secure storage.
///
/// On a successful verify the access + refresh tokens are written under the keys
/// the [AuthInterceptor] reads ([StorageKeys.accessToken] /
/// [StorageKeys.refreshToken]), so authenticated requests work immediately.
abstract class AuthRepository {
  /// Sends an OTP and returns the session (read `user.id` for verify,
  /// `requiresOtp`/`otpId` for flow control).
  Future<AuthSession> sendOtp({required String phoneNumber, required String preferredLang, String channel});

  /// Verifies the OTP, persists tokens + user, and returns the user.
  Future<User> verifyOtp({required int userId, required String otpCode});

  /// Completes an individual customer's profile (role 3) and persists the
  /// updated user + role. Returns the updated user.
  Future<User> completeIndividualProfile({
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
  });

  /// Completes a driver's profile (role 2) and persists the updated user +
  /// role. Returns the updated user.
  Future<User> completeDriverProfile({
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
  });

  /// Persists the user's chosen location server-side
  /// (`POST /api/User/set-location`). Used by the home location picker.
  Future<void> setUserLocation({required int userId, required double lat, required double lon});

  Future<void> logout();

  /// Soft-deletes the signed-in user's account server-side, then clears the
  /// local session (same cleanup as [logout]). Throws [AppException] when the
  /// server rejects the deletion — local state is left intact in that case.
  Future<void> deleteAccount();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remote;
  final FlutterSecureStorage storage;

  AuthRepositoryImpl(this.remote, this.storage);

  @override
  Future<AuthSession> sendOtp({
    required String phoneNumber,
    required String preferredLang,
    String channel = 'sms',
  }) async {
    final res = await remote.loginMobile(phoneNumber: phoneNumber, preferredLang: preferredLang, channel: channel);
    if (!res.isSuccess || res.data == null) {
      throw AppException(message: res.message ?? 'Failed to send OTP', messageAr: res.messageAr, errors: res.errors);
    }
    return res.data!;
  }

  @override
  Future<User> verifyOtp({required int userId, required String otpCode}) async {
    final res = await remote.verifyOtp(userId: userId, otpCode: otpCode);
    final session = res.data;
    if (!res.isSuccess || session == null || session.user == null) {
      throw AppException(
        message: res.message ?? 'OTP verification failed',
        messageAr: res.messageAr,
        errors: res.errors,
      );
    }
    await _persistSession(session);
    return session.user!;
  }

  @override
  Future<User> completeIndividualProfile({
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
    // Assign the customer role (3) up front — the completion endpoint doesn't
    // set it, so without this the user has no role on the next login.
    try {
      await remote.setRole(userId: userId, roleId: 3);
    } catch (_) {
      /* non-fatal — completion still proceeds */
    }
    final res = await remote.completeIndividualProfile(
      userId: userId,
      fullName: fullName,
      fullNameAr: fullNameAr,
      email: email,
      gender: gender,
      preferredLang: preferredLang,
      dateOfBirthIso: dateOfBirthIso,
      photo: photo,
    );
    if (!res.isSuccess) {
      throw AppException(
        message: res.message ?? 'Failed to complete profile',
        messageAr: res.messageAr,
        errors: res.errors,
      );
    }
    // The endpoint returns no body on success — fall back to what we submitted
    // so the session/UI still has a name + role to show.
    final user = res.data ?? User(id: userId, fullName: fullName, email: email, roleId: 3);
    await _persistProfileUser(user, isDriver: false);
    // The individual-profile endpoint has no lat/lon — persist the captured
    // location separately (best-effort, never fails the signup).
    if (lat != null && lon != null) {
      try {
        await remote.setLocation(userId: userId, lat: lat, lon: lon);
      } catch (_) {
        /* location is optional */
      }
    }
    return user;
  }

  @override
  Future<User> completeDriverProfile({
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
    // Assign the driver role (2) up front — the completion endpoint doesn't set
    // it, so without this the user lands on the customer home on the next login.
    try {
      await remote.setRole(userId: userId, roleId: 2);
    } catch (_) {
      /* non-fatal — completion still proceeds */
    }
    final res = await remote.completeDriverProfile(
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
      lat: lat,
      lon: lon,
      photo: photo,
      civilIdFront: civilIdFront,
      civilIdBack: civilIdBack,
      drivingLicenseFront: drivingLicenseFront,
      drivingLicenseBack: drivingLicenseBack,
      medicalReport: medicalReport,
    );
    if (!res.isSuccess) {
      throw AppException(
        message: res.message ?? 'Failed to complete profile',
        messageAr: res.messageAr,
        errors: res.errors,
      );
    }
    // The endpoint returns no body on success — synthesize from the submitted
    // fields. A freshly completed driver is unverified (pending admin review).
    final user = res.data ?? User(id: userId, fullName: fullName, email: email, roleId: 2, isVerified: false);
    await _persistProfileUser(user, isDriver: true);
    return user;
  }

  /// Revokes the refresh token server-side (best-effort) then clears all auth +
  /// user-identity keys. Deliberately leaves app prefs (theme, language,
  @override
  Future<void> setUserLocation({required int userId, required double lat, required double lon}) {
    return remote.setLocation(userId: userId, lat: lat, lon: lon);
  }

  /// onboarding-seen) so logout doesn't reset the intro flow.
  @override
  Future<void> logout() async {
    final refreshToken = await storage.read(key: StorageKeys.refreshToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await remote.signout(refreshToken);
      } catch (_) {
        // Revocation is best-effort — proceed to clear local state regardless.
      }
    }
    await _clearLocalSession();
  }

  @override
  Future<void> deleteAccount() async {
    final idStr = await storage.read(key: StorageKeys.userId);
    final userId = int.tryParse(idStr ?? '');
    if (userId == null) {
      throw AppException(message: 'No signed-in user to delete');
    }
    final isDriver = (await storage.read(key: StorageKeys.userRole)) == 'driver';
    // Must succeed before any local cleanup — a failed server delete keeps the
    // session so the user can retry.
    await remote.deleteAccount(userId: userId, isDriver: isDriver);
    // Revoke the refresh token too (best-effort; the account is already gone).
    final refreshToken = await storage.read(key: StorageKeys.refreshToken);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await remote.signout(refreshToken);
      } catch (_) {
        /* best-effort */
      }
    }
    await _clearLocalSession();
  }

  Future<void> _clearLocalSession() async {
    const keys = [
      StorageKeys.accessToken,
      StorageKeys.refreshToken,
      StorageKeys.userId,
      StorageKeys.driverId,
      StorageKeys.userRole,
      StorageKeys.userEmail,
      StorageKeys.userPhone,
      StorageKeys.userName,
      StorageKeys.userGender,
      StorageKeys.userProfileImage,
      StorageKeys.isLoggedIn,
      StorageKeys.isVerified,
      StorageKeys.verifiedBadgeDismissed,
      StorageKeys.fcmToken,
    ];
    for (final key in keys) {
      await storage.delete(key: key);
    }
  }

  Future<void> _persistSession(AuthSession session) async {
    if (session.accessToken.isNotEmpty) {
      await storage.write(key: StorageKeys.accessToken, value: session.accessToken);
    }
    if (session.refreshToken.isNotEmpty) {
      await storage.write(key: StorageKeys.refreshToken, value: session.refreshToken);
    }
    final user = session.user;
    if (user != null) {
      await _persistProfileUser(user, isDriver: user.isDriver);
    }
    await storage.write(key: StorageKeys.isLoggedIn, value: 'true');
  }

  /// Persists user-identity fields (and role). Used after verify and after
  /// profile completion. [isDriver] is passed explicitly because the profile
  /// completion responses don't always echo the role back.
  Future<void> _persistProfileUser(User user, {required bool isDriver}) async {
    await storage.write(key: StorageKeys.userId, value: user.id.toString());
    await storage.write(key: StorageKeys.userRole, value: isDriver ? 'driver' : 'customer');
    if (user.email != null) {
      await storage.write(key: StorageKeys.userEmail, value: user.email);
    }
    if (user.phoneNumber != null) {
      await storage.write(key: StorageKeys.userPhone, value: user.phoneNumber);
    }
    if (user.fullName != null) {
      await storage.write(key: StorageKeys.userName, value: user.fullName);
    }
    if (user.gender != null && user.gender!.isNotEmpty) {
      await storage.write(key: StorageKeys.userGender, value: user.gender);
    }
    if (user.photoUrl != null) {
      await storage.write(key: StorageKeys.userProfileImage, value: user.photoUrl);
    }
    await storage.write(key: StorageKeys.isVerified, value: (user.isVerified ?? false).toString());
    await storage.write(key: StorageKeys.isLoggedIn, value: 'true');
  }
}
