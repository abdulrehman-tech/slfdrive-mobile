import 'package:image_picker/image_picker.dart' show XFile;

import '../../models/driver/driver_details.dart';
import '../../models/driver/driver_stats.dart';
import '../datasources/driver_remote_data_source.dart';

/// Exposes driver records to the presentation layer.
abstract class DriverRepository {
  Future<DriverDetails?> getById(int id);

  /// Aggregated stats for a driver (rating/bookings/earnings). `id` = user id.
  Future<DriverStats?> getStats(int id);

  /// Toggles the driver's online/offline availability. Returns the new state.
  Future<bool> toggleOnline(int userId);

  /// Updates the driver profile via `PUT /api/Driver`. Returns true on success.
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

class DriverRepositoryImpl implements DriverRepository {
  final DriverRemoteDataSource remote;

  DriverRepositoryImpl(this.remote);

  @override
  Future<DriverDetails?> getById(int id) => remote.getById(id);

  @override
  Future<DriverStats?> getStats(int id) => remote.getStats(id);

  @override
  Future<bool> toggleOnline(int userId) => remote.toggleOnline(userId);

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
  }) =>
      remote.updateProfile(
        id: id,
        fullName: fullName,
        fullNameAr: fullNameAr,
        email: email,
        gender: gender,
        preferredLang: preferredLang,
        dateOfBirthIso: dateOfBirthIso,
        isActive: isActive,
        isVerified: isVerified,
        phoneNumber: phoneNumber,
        lat: lat,
        lon: lon,
        licenceNumber: licenceNumber,
        carPlateNumber: carPlateNumber,
        licenceExpiryIso: licenceExpiryIso,
        locationId: locationId,
        hasVehicle: hasVehicle,
        languagesKnown: languagesKnown,
        yearsOfExperience: yearsOfExperience,
        amountPerDay: amountPerDay,
        amountPerHour: amountPerHour,
        allCompanyId: allCompanyId,
        photo: photo,
        photoUrl: photoUrl,
        civilIdFront: civilIdFront,
        civilIdUrlF: civilIdUrlF,
        civilIdBack: civilIdBack,
        civilIdUrlB: civilIdUrlB,
        drivingLicenseFront: drivingLicenseFront,
        drivingLicenseBack: drivingLicenseBack,
        medicalReport: medicalReport,
      );
}
