import 'package:image_picker/image_picker.dart' show XFile;

import '../../models/customer/customer_details.dart';
import '../datasources/customer_remote_data_source.dart';

/// Exposes customer records to the presentation layer.
abstract class CustomerRepository {
  Future<CustomerDetails?> getById(int id);

  /// Updates the customer profile via `PUT /api/Customer`. Returns true on
  /// success.
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

class CustomerRepositoryImpl implements CustomerRepository {
  final CustomerRemoteDataSource remote;

  CustomerRepositoryImpl(this.remote);

  @override
  Future<CustomerDetails?> getById(int id) => remote.getById(id);

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
  }) => remote.updateProfile(
    id: id,
    fullName: fullName,
    fullNameAr: fullNameAr,
    email: email,
    gender: gender,
    preferredLang: preferredLang,
    dateOfBirthIso: dateOfBirthIso,
    isActive: isActive,
    phoneNumber: phoneNumber,
    lat: lat,
    lon: lon,
    photo: photo,
    photoUrl: photoUrl,
    civilIdFront: civilIdFront,
    civilIdUrlF: civilIdUrlF,
    civilIdBack: civilIdBack,
    civilIdUrlB: civilIdUrlB,
  );
}
