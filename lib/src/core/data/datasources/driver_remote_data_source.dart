import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart' show XFile;

import '../../../constants/endpoints.dart';
import '../../errors/error_handler.dart';
import '../../models/driver/driver_details.dart';
import '../../models/driver/driver_stats.dart';
import '../../network/api_client.dart';

/// Remote reads + updates for driver records.
abstract class DriverRemoteDataSource {
  /// Fetches a single driver by **user id** (`GET /api/Driver/{id}`), or null
  /// when the call doesn't succeed.
  Future<DriverDetails?> getById(int id);

  /// Aggregated stats for a driver (`GET /api/Driver/{id}/stats`) — rating,
  /// booking counts, earnings. `id` is the driver's user id. Null when the call
  /// doesn't succeed.
  Future<DriverStats?> getStats(int id);

  /// Flips the driver's online/offline availability
  /// (`POST /api/Driver/toggle-online/{userId}`). Returns the new state
  /// (`true` = online).
  Future<bool> toggleOnline(int userId);

  /// Updates an existing driver (`PUT /api/Driver`, multipart/form-data). File
  /// parts are optional; matching `*Url` values are round-tripped so the backend
  /// keeps existing files. Admin-controlled flags (`isVerified`, `isActive`,
  /// `allCompanyId`) are passed straight back from the current record so a
  /// self-service edit never flips them. Returns true on `isSuccess`.
  Future<bool> updateProfile({
    required int id,
    required String fullName,
    String? fullNameAr,
    required String email,
    required String gender,
    required String preferredLang,
    required String dateOfBirthIso,
    required bool isActive,
    required bool isVerified,
    String? phoneNumber,
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
    int? allCompanyId,
    XFile? photo,
    String? photoUrl,
    XFile? civilIdFront,
    String? civilIdUrlF,
    XFile? civilIdBack,
    String? civilIdUrlB,
    XFile? drivingLicenseFront,
    XFile? drivingLicenseBack,
    XFile? medicalReport,
  });
}

class DriverRemoteDataSourceImpl implements DriverRemoteDataSource {
  final ApiClient apiClient;

  DriverRemoteDataSourceImpl(this.apiClient);

  @override
  Future<DriverDetails?> getById(int id) async {
    try {
      final res = await apiClient.get(ApiEndpoints.driverById(id));
      final body = res.data as Map<String, dynamic>;
      if (body['isSuccess'] == true && body['data'] is Map<String, dynamic>) {
        return DriverDetails.fromJson(body['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<DriverStats?> getStats(int id) async {
    try {
      final res = await apiClient.get(ApiEndpoints.driverStats(id));
      final body = res.data as Map<String, dynamic>;
      if (body['isSuccess'] == true && body['data'] is Map<String, dynamic>) {
        return DriverStats.fromJson(body['data'] as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<bool> toggleOnline(int userId) async {
    try {
      final res = await apiClient.post(ApiEndpoints.driverToggleOnline(userId));
      final body = res.data as Map<String, dynamic>;
      return body['isSuccess'] == true && body['data'] == true;
    } catch (e) {
      throw ErrorHandler.handleError(e);
    }
  }

  @override
  Future<bool> updateProfile({
    required int id,
    required String fullName,
    String? fullNameAr,
    required String email,
    required String gender,
    required String preferredLang,
    required String dateOfBirthIso,
    required bool isActive,
    required bool isVerified,
    String? phoneNumber,
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
    int? allCompanyId,
    XFile? photo,
    String? photoUrl,
    XFile? civilIdFront,
    String? civilIdUrlF,
    XFile? civilIdBack,
    String? civilIdUrlB,
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
        'Id': id,
        'FullName': fullName,
        if (fullNameAr != null && fullNameAr.isNotEmpty) 'FullNameAr': fullNameAr,
        'Email': email,
        'Gender': gender,
        'PreferredLang': preferredLang,
        'DateOfBirth': dateOfBirthIso,
        'IsActive': isActive,
        'IsVerified': isVerified,
        if (phoneNumber != null && phoneNumber.isNotEmpty)
          'PhoneNumber': phoneNumber,
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
        'AllCompanyId': ?allCompanyId,
        'Photo': ?photoPart,
        if (photoUrl != null && photoUrl.isNotEmpty) 'PhotoUrl': photoUrl,
        'CivilIdFileF': ?civilFrontPart,
        if (civilIdUrlF != null && civilIdUrlF.isNotEmpty)
          'CivilIdUrlF': civilIdUrlF,
        'CivilIdFileB': ?civilBackPart,
        if (civilIdUrlB != null && civilIdUrlB.isNotEmpty)
          'CivilIdUrlB': civilIdUrlB,
        'DrivingLicenseFront': ?licenseFrontPart,
        'DrivingLicenseBack': ?licenseBackPart,
        'MedicalReport': ?medicalPart,
      };
      final res = await apiClient.putMultipart(
        ApiEndpoints.driver,
        data: FormData.fromMap(map),
      );
      final body = res.data as Map<String, dynamic>;
      return body['isSuccess'] == true;
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
