import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart' show XFile;

import '../../../constants/endpoints.dart';
import '../../errors/error_handler.dart';
import '../../models/auth/auth_session.dart';
import '../../models/user/user_model.dart';
import '../../network/api_client.dart';
import '../../network/api_response.dart';

/// Remote calls for the auth flow.
///
/// Each method posts to its [ApiEndpoints] path and decodes the standard
/// `{ isSuccess, message, messageAr, data, errors }` envelope into an
/// [ApiResponse]. Transport-level failures (timeouts, 5xx, no network) are
/// normalised via [ErrorHandler.handleError].
abstract class AuthRemoteDataSource {
  /// Request an OTP for [phoneNumber]. Response carries the user (incl. `id`,
  /// needed for verify) and `requiresOtp`/`otpId`; tokens are still empty.
  Future<ApiResponse<AuthSession>> loginMobile({
    required String phoneNumber,
    required String preferredLang,
    String channel = 'sms',
  });

  /// Verify [otpCode] for [userId]; on success the response carries tokens.
  Future<ApiResponse<AuthSession>> verifyOtp({
    required int userId,
    required String otpCode,
    String otpType = 'Login',
  });

  /// Exchange a refresh token for a fresh token pair.
  Future<ApiResponse<AuthSession>> refresh(String refreshToken);

  /// Revoke [refreshToken] server-side. Best-effort — the caller clears local
  /// tokens regardless of the result.
  Future<void> signout(String refreshToken);

  /// Soft-deletes the signed-in user's account. Hits the role-specific endpoint
  /// (`DELETE /api/Driver/{userId}` or `DELETE /api/Customer/{userId}`) — both
  /// take the *user* id, not the role-entity id. Throws on failure so the UI
  /// can keep the session when the server rejects the deletion.
  Future<void> deleteAccount({required int userId, required bool isDriver});

  /// Update the user's last known coordinates.
  Future<void> setLocation({
    required int userId,
    required double lat,
    required double lon,
  });

  /// Assigns / changes the user's role (2 = driver, 3 = individual customer).
  Future<void> setRole({required int userId, required int roleId});

  /// Complete an individual customer's profile (role 3) after OTP signup.
  /// Sent as multipart/form-data; [photo] is optional.
  Future<ApiResponse<User>> completeIndividualProfile({
    required int userId,
    required String fullName,
    String? fullNameAr,
    required String email,
    required String gender,
    required String preferredLang,
    required String dateOfBirthIso,
    XFile? photo,
  });

  /// Complete a driver's profile (role 2) after OTP signup. Sent as
  /// multipart/form-data; all file parts are optional at the transport layer.
  Future<ApiResponse<User>> completeDriverProfile({
    required int userId,
    required String fullName,
    String? fullNameAr,
    required String email,
    required String gender,
    required String preferredLang,
    required String dateOfBirthIso,
    double? lat,
    double? lon,
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
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<ApiResponse<AuthSession>> loginMobile({
    required String phoneNumber,
    required String preferredLang,
    String channel = 'sms',
  }) async {
    try {
      final res = await apiClient.post(
        ApiEndpoints.loginMobile,
        data: {'phoneNumber': phoneNumber, 'preferredLang': preferredLang, 'channel': channel},
      );
      return ApiResponse<AuthSession>.fromJson(
        res.data as Map<String, dynamic>,
        (d) => AuthSession.fromJson(d),
      );
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<ApiResponse<AuthSession>> verifyOtp({
    required int userId,
    required String otpCode,
    String otpType = 'Login',
  }) async {
    try {
      final res = await apiClient.post(
        ApiEndpoints.verifyOtp,
        data: {'userId': userId, 'otpCode': otpCode, 'otpType': otpType},
      );
      return ApiResponse<AuthSession>.fromJson(
        res.data as Map<String, dynamic>,
        (d) => AuthSession.fromJson(d),
      );
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<ApiResponse<AuthSession>> refresh(String refreshToken) async {
    try {
      final res = await apiClient.post(
        ApiEndpoints.refresh,
        data: {'refreshToken': refreshToken},
      );
      return ApiResponse<AuthSession>.fromJson(
        res.data as Map<String, dynamic>,
        (d) => AuthSession.fromJson(d),
      );
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<void> signout(String refreshToken) async {
    try {
      await apiClient.post(
        ApiEndpoints.signout,
        data: {'refreshToken': refreshToken},
      );
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<void> deleteAccount({required int userId, required bool isDriver}) async {
    try {
      await apiClient.delete(
        isDriver ? ApiEndpoints.driverById(userId) : ApiEndpoints.customerById(userId),
      );
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<void> setLocation({
    required int userId,
    required double lat,
    required double lon,
  }) async {
    try {
      await apiClient.post(
        ApiEndpoints.setLocation,
        data: {'userId': userId, 'lat': lat, 'lon': lon},
      );
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<void> setRole({required int userId, required int roleId}) async {
    try {
      await apiClient.post(
        ApiEndpoints.setRole,
        data: {'userId': userId, 'roleId': roleId},
      );
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<ApiResponse<User>> completeIndividualProfile({
    required int userId,
    required String fullName,
    String? fullNameAr,
    required String email,
    required String gender,
    required String preferredLang,
    required String dateOfBirthIso,
    XFile? photo,
  }) async {
    try {
      final photoPart = photo == null ? null : await _toMultipart(photo);
      final map = <String, dynamic>{
        'UserId': userId,
        'Full_Name': fullName,
        if (fullNameAr != null && fullNameAr.isNotEmpty) 'Full_NameAr': fullNameAr,
        'Email': email,
        'Gender': gender,
        'PreferredLang': preferredLang,
        'DateOfBirth': dateOfBirthIso,
        'Photo': ?photoPart,
      };
      final res = await apiClient.postMultipart(
        ApiEndpoints.completeIndividualProfile,
        data: FormData.fromMap(map),
      );
      return ApiResponse<User>.fromJson(
        res.data as Map<String, dynamic>,
        (d) => User.fromJson(d as Map<String, dynamic>),
      );
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<ApiResponse<User>> completeDriverProfile({
    required int userId,
    required String fullName,
    String? fullNameAr,
    required String email,
    required String gender,
    required String preferredLang,
    required String dateOfBirthIso,
    double? lat,
    double? lon,
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
  }) async {
    try {
      final photoPart = photo == null ? null : await _toMultipart(photo);
      final civilFrontPart =
          civilIdFront == null ? null : await _toMultipart(civilIdFront);
      final civilBackPart =
          civilIdBack == null ? null : await _toMultipart(civilIdBack);
      final licenseFrontPart = drivingLicenseFront == null
          ? null
          : await _toMultipart(drivingLicenseFront);
      final licenseBackPart = drivingLicenseBack == null
          ? null
          : await _toMultipart(drivingLicenseBack);
      final medicalPart =
          medicalReport == null ? null : await _toMultipart(medicalReport);
      final map = <String, dynamic>{
        'UserId': userId,
        'FullName': fullName,
        if (fullNameAr != null && fullNameAr.isNotEmpty) 'FullNameAr': fullNameAr,
        'Email': email,
        'Gender': gender,
        'PreferredLang': preferredLang,
        'DateOfBirth': dateOfBirthIso,
        'Lat': ?lat,
        'Lon': ?lon,
        'LiscenceNumber': licenceNumber,
        if (carPlateNumber != null && carPlateNumber.isNotEmpty)
          'CarPlateNumber': carPlateNumber,
        'LiscenceExpiryDate': licenceExpiryIso,
        'LocationId': ?locationId,
        'HasVehicle': ?hasVehicle,
        if (languagesKnown != null && languagesKnown.isNotEmpty)
          'LanguagesKnown': languagesKnown,
        'YearsOfExperience': ?yearsOfExperience,
        'AmountPerDay': ?amountPerDay,
        'AmountPerHour': ?amountPerHour,
        'Photo': ?photoPart,
        'CivilIdFileF': ?civilFrontPart,
        'CivilIdFileB': ?civilBackPart,
        'DrivingLicenseFront': ?licenseFrontPart,
        'DrivingLicenseBack': ?licenseBackPart,
        'MedicalReport': ?medicalPart,
      };
      final res = await apiClient.postMultipart(
        ApiEndpoints.completeDriverProfile,
        data: FormData.fromMap(map),
      );
      return ApiResponse<User>.fromJson(
        res.data as Map<String, dynamic>,
        (d) => User.fromJson(d as Map<String, dynamic>),
      );
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  /// Builds a dio [MultipartFile] from an [XFile], reading bytes so it works on
  /// web (no file path) as well as mobile.
  Future<MultipartFile> _toMultipart(XFile file) async {
    final bytes = await file.readAsBytes();
    return MultipartFile.fromBytes(bytes, filename: file.name);
  }
}
