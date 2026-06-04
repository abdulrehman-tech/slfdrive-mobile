import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart' show XFile;

import '../../../constants/endpoints.dart';
import '../../errors/error_handler.dart';
import '../../models/customer/customer_details.dart';
import '../../network/api_client.dart';

/// Remote reads + updates for customer records.
abstract class CustomerRemoteDataSource {
  /// Fetches a single customer by **user id** (`GET /api/Customer/{id}`), or
  /// null when the call doesn't succeed.
  Future<CustomerDetails?> getById(int id);

  /// Updates an existing customer (`PUT /api/Customer`, multipart/form-data).
  /// File parts are optional; the matching `*Url` value is round-tripped so the
  /// backend keeps the existing file when no new one is uploaded. Returns true
  /// on `isSuccess`.
  Future<bool> updateProfile({
    required int id,
    required String fullName,
    String? fullNameAr,
    required String email,
    required String gender,
    required String preferredLang,
    required String dateOfBirthIso,
    required bool isActive,
    String? phoneNumber,
    double? lat,
    double? lon,
    XFile? photo,
    String? photoUrl,
    XFile? civilIdFront,
    String? civilIdUrlF,
    XFile? civilIdBack,
    String? civilIdUrlB,
  });
}

class CustomerRemoteDataSourceImpl implements CustomerRemoteDataSource {
  final ApiClient apiClient;

  CustomerRemoteDataSourceImpl(this.apiClient);

  @override
  Future<CustomerDetails?> getById(int id) async {
    try {
      final res = await apiClient.get(ApiEndpoints.customerById(id));
      final body = res.data as Map<String, dynamic>;
      if (body['isSuccess'] == true && body['data'] is Map<String, dynamic>) {
        return CustomerDetails.fromJson(body['data'] as Map<String, dynamic>);
      }
      return null;
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
    String? phoneNumber,
    double? lat,
    double? lon,
    XFile? photo,
    String? photoUrl,
    XFile? civilIdFront,
    String? civilIdUrlF,
    XFile? civilIdBack,
    String? civilIdUrlB,
  }) async {
    try {
      final photoPart = photo == null ? null : await _toMultipart(photo);
      final civilFrontPart =
          civilIdFront == null ? null : await _toMultipart(civilIdFront);
      final civilBackPart =
          civilIdBack == null ? null : await _toMultipart(civilIdBack);
      final map = <String, dynamic>{
        'Id': id,
        'FullName': fullName,
        if (fullNameAr != null && fullNameAr.isNotEmpty) 'FullNameAr': fullNameAr,
        'Email': email,
        'Gender': gender,
        'PreferredLang': preferredLang,
        'DateOfBirth': dateOfBirthIso,
        'IsActive': isActive,
        if (phoneNumber != null && phoneNumber.isNotEmpty)
          'PhoneNumber': phoneNumber,
        'Lat': ?lat,
        'Lon': ?lon,
        'Photo': ?photoPart,
        if (photoUrl != null && photoUrl.isNotEmpty) 'PhotoUrl': photoUrl,
        'CivilIdFileF': ?civilFrontPart,
        if (civilIdUrlF != null && civilIdUrlF.isNotEmpty)
          'CivilIdUrlF': civilIdUrlF,
        'CivilIdFileB': ?civilBackPart,
        if (civilIdUrlB != null && civilIdUrlB.isNotEmpty)
          'CivilIdUrlB': civilIdUrlB,
      };
      final res = await apiClient.putMultipart(
        ApiEndpoints.customer,
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
