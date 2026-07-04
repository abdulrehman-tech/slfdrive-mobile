import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../../constants/endpoints.dart';
import '../../../../../constants/storage_keys.dart';
import '../../../../../core/data/repositories/customer_repository.dart';
import '../../../../../core/data/repositories/driver_repository.dart';
import '../../../../../core/data/repositories/lookup_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/models/lookup/location_option.dart';
import '../../../../providers/auth_provider.dart';
import '../../../../providers/role_provider.dart';
import '../../auth/profile_completion_models/profile_field_codecs.dart';

/// The editable field group a focused editor renders. Driver editing is split
/// into these; customers use [personal] and [documents] only.
enum EditProfileSection { personal, vehicle, professional, documents }

/// Owns the edit-profile form state for both roles.
///
/// On [load] it fetches the current customer/driver record and pre-fills every
/// editable field, keeping the existing photo / civil-id URLs so they round-trip
/// through the `PUT` (the backend preserves a stored file when no new one is
/// uploaded). Admin-controlled flags (`isActive`/`isVerified`/`allCompanyId`)
/// are captured from the GET response and sent back unchanged — never exposed in
/// the UI — so a self-service edit can't flip them.
class EditProfileProvider extends ChangeNotifier {
  EditProfileProvider({
    required this.role,
    required this.userId,
    required CustomerRepository customerRepository,
    required DriverRepository driverRepository,
    required LookupRepository lookupRepository,
    required AuthProvider authProvider,
  })  : _customerRepository = customerRepository,
        _driverRepository = driverRepository,
        _lookupRepository = lookupRepository,
        _authProvider = authProvider;

  final UserRole role;
  final int userId;
  final CustomerRepository _customerRepository;
  final DriverRepository _driverRepository;
  final LookupRepository _lookupRepository;
  final AuthProvider _authProvider;
  final FlutterSecureStorage _storage = getIt<FlutterSecureStorage>();

  bool get isDriver => role == UserRole.driver;

  // ── Controllers ─────────────────────────────────────────────────────────────
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nameArController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();
  // Driver-only
  final TextEditingController licenseNumberController = TextEditingController();
  final TextEditingController licenseExpiryController = TextEditingController();
  final TextEditingController carPlateController = TextEditingController();
  final TextEditingController yearsExperienceController = TextEditingController();
  final TextEditingController amountPerDayController = TextEditingController();
  final TextEditingController amountPerHourController = TextEditingController();

  // Read-only phone (login identity).
  String? _phoneNumber;
  String? get phoneNumber => _phoneNumber;

  // ── Selections ──────────────────────────────────────────────────────────────
  String? _selectedGender;
  String? get selectedGender => _selectedGender;
  set selectedGender(String? value) {
    _selectedGender = value;
    notifyListeners();
  }

  List<String> _selectedLanguages = <String>[];
  List<String> get selectedLanguages => List.unmodifiable(_selectedLanguages);
  set selectedLanguages(List<String> values) {
    _selectedLanguages = List<String>.from(values);
    notifyListeners();
  }

  bool _hasVehicle = false;
  bool get hasVehicle => _hasVehicle;
  set hasVehicle(bool value) {
    _hasVehicle = value;
    notifyListeners();
  }

  // ── Location dropdown (driver base location) ────────────────────────────────
  List<LocationOption> _locations = const [];
  List<LocationOption> get locations => List.unmodifiable(_locations);
  List<String> get locationNames => _locations.map((l) => l.name).toList();

  int? _selectedLocationId;
  int? get selectedLocationId => _selectedLocationId;
  String? _selectedLocationName;
  String? get selectedLocationName => _selectedLocationName;

  void selectLocationByName(String? name) {
    _selectedLocationName = name;
    final match = _locations.where((l) => l.name == name);
    _selectedLocationId = match.isEmpty ? null : match.first.id;
    notifyListeners();
  }

  // ── Picked files (null = keep existing) ─────────────────────────────────────
  XFile? _avatar;
  XFile? get avatar => _avatar;
  Uint8List? _avatarBytes;
  Uint8List? get avatarBytes => _avatarBytes;

  XFile? _civilIdFront;
  String? get civilIdFrontFileName => _civilIdFront?.name;
  XFile? _civilIdBack;
  String? get civilIdBackFileName => _civilIdBack?.name;
  XFile? _drivingLicenseFront;
  String? get drivingLicenseFrontFileName => _drivingLicenseFront?.name;
  XFile? _drivingLicenseBack;
  String? get drivingLicenseBackFileName => _drivingLicenseBack?.name;
  XFile? _medicalCertificate;
  String? get medicalCertificateFileName => _medicalCertificate?.name;

  // ── Existing values round-tripped through the PUT ───────────────────────────
  String? _photoUrl;
  String? get photoUrl => _photoUrl;

  /// Absolute URL of the current avatar (for display when no new pick).
  String? get avatarUrl => ApiEndpoints.resolveMediaUrl(_photoUrl);
  bool get avatarPicked => _avatar != null;

  String? _civilIdUrlF;
  String? _civilIdUrlB;
  bool get hasCivilIdFront => _civilIdUrlF != null && _civilIdUrlF!.isNotEmpty;
  bool get hasCivilIdBack => _civilIdUrlB != null && _civilIdUrlB!.isNotEmpty;

  // Admin-controlled / hidden, captured from GET and sent back unchanged.
  bool _isActive = true;
  bool _isVerified = false;
  int? _allCompanyId;
  double? _lat;
  double? _lon;

  DateTime? _dateOfBirth;
  DateTime? _licenseExpiry;
  String _preferredLang = 'en';

  // ── Status flags ────────────────────────────────────────────────────────────
  bool _isInitialLoading = true;
  bool get isInitialLoading => _isInitialLoading;

  String? _loadError;
  String? get loadError => _loadError;

  bool _isSaving = false;
  bool get isSaving => _isSaving;

  String? _error;
  String? get error => _error;

  bool get _personalValid =>
      nameController.text.trim().isNotEmpty &&
      emailController.text.trim().isNotEmpty &&
      _isValidEmail(emailController.text.trim()) &&
      dobController.text.trim().isNotEmpty &&
      _selectedGender != null;

  /// Whether the fields for [section] are valid enough to submit. Other groups
  /// keep their pre-filled values and round-trip through the PUT untouched.
  bool canSaveSection(EditProfileSection section) {
    switch (section) {
      case EditProfileSection.personal:
        return _personalValid;
      case EditProfileSection.vehicle:
        return licenseNumberController.text.trim().isNotEmpty &&
            licenseExpiryController.text.trim().isNotEmpty;
      case EditProfileSection.professional:
      case EditProfileSection.documents:
        return true;
    }
  }

  // ── Load ────────────────────────────────────────────────────────────────────
  Future<void> load() async {
    _isInitialLoading = true;
    _loadError = null;
    notifyListeners();
    try {
      if (isDriver) {
        await _loadDriver();
      } else {
        await _loadCustomer();
      }
    } on AppException catch (e) {
      _loadError = e.message;
    } catch (e) {
      _loadError = e.toString();
    } finally {
      _isInitialLoading = false;
      notifyListeners();
    }
  }

  Future<void> _loadCustomer() async {
    final c = await _customerRepository.getById(userId);
    if (c == null) {
      _loadError = 'profile_edit_load_error'.tr();
      return;
    }
    nameController.text = c.fullName ?? '';
    nameArController.text = c.fullNameAr ?? '';
    emailController.text = c.email ?? '';
    _phoneNumber = c.phoneNumber;
    // The Customer GET DTO doesn't return gender — fall back to the value cached
    // from the login/profile user so the dropdown pre-selects correctly.
    _selectedGender = ProfileFieldCodecs.decodeGender(c.gender) ??
        ProfileFieldCodecs.decodeGender(await _storage.read(key: StorageKeys.userGender));
    _setDob(c.dateOfBirth);
    _photoUrl = c.photoUrl;
    _civilIdUrlF = c.civilIdUrlF;
    _civilIdUrlB = c.civilIdUrlB;
    _isActive = c.isActive;
    _lat = c.lat;
    _lon = c.lon;
    if (c.preferredLang != null && c.preferredLang!.isNotEmpty) {
      _preferredLang = c.preferredLang!;
    }
  }

  Future<void> _loadDriver() async {
    // Fetch the record and the location list concurrently.
    final driverFuture = _driverRepository.getById(userId);
    final locFuture = _safeLoadLocations();
    final d = await driverFuture;
    await locFuture;
    if (d == null) {
      _loadError = 'profile_edit_load_error'.tr();
      return;
    }
    nameController.text = d.fullName ?? '';
    nameArController.text = d.fullNameAr ?? '';
    emailController.text = d.email ?? '';
    _phoneNumber = d.phoneNumber;
    _selectedGender = ProfileFieldCodecs.decodeGender(d.gender) ??
        ProfileFieldCodecs.decodeGender(await _storage.read(key: StorageKeys.userGender));
    _setDob(d.dateOfBirth);
    licenseNumberController.text = d.licenceNumber ?? '';
    _setLicenseExpiry(d.licenceExpiryDate);
    carPlateController.text = d.carPlateNumber ?? '';
    yearsExperienceController.text =
        d.yearsOfExperience == null ? '' : d.yearsOfExperience.toString();
    amountPerDayController.text =
        d.amountPerDay == null ? '' : d.amountPerDay.toString();
    amountPerHourController.text =
        d.amountPerHour == null ? '' : d.amountPerHour.toString();
    _selectedLanguages = ProfileFieldCodecs.decodeLanguages(d.languagesKnown);
    _hasVehicle = d.hasVehicle ?? false;
    _selectedLocationId = d.locationId;
    _selectedLocationName = d.locationName ??
        (_locations.where((l) => l.id == d.locationId).isEmpty
            ? null
            : _locations.firstWhere((l) => l.id == d.locationId).name);
    _photoUrl = d.photoUrl;
    _civilIdUrlF = d.civilIdUrlF;
    _civilIdUrlB = d.civilIdUrlB;
    _isActive = d.isActive;
    _isVerified = d.isVerified;
    _allCompanyId = d.allCompanyId;
    _lat = d.lat;
    _lon = d.lon;
    if (d.preferredLang != null && d.preferredLang!.isNotEmpty) {
      _preferredLang = d.preferredLang!;
    }
  }

  Future<void> _safeLoadLocations() async {
    try {
      _locations = await _lookupRepository.getActiveLocations();
    } catch (_) {
      _locations = const [];
    }
  }

  // ── Pickers ─────────────────────────────────────────────────────────────────
  Future<void> pickAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      _avatar = picked;
      _avatarBytes = await picked.readAsBytes();
      notifyListeners();
    }
  }

  Future<void> pickCivilIdFront() async {
    final f = await _pickDocument();
    if (f != null) {
      _civilIdFront = f;
      notifyListeners();
    }
  }

  Future<void> pickCivilIdBack() async {
    final f = await _pickDocument();
    if (f != null) {
      _civilIdBack = f;
      notifyListeners();
    }
  }

  Future<void> pickDrivingLicenseFront() async {
    final f = await _pickDocument();
    if (f != null) {
      _drivingLicenseFront = f;
      notifyListeners();
    }
  }

  Future<void> pickDrivingLicenseBack() async {
    final f = await _pickDocument();
    if (f != null) {
      _drivingLicenseBack = f;
      notifyListeners();
    }
  }

  Future<void> pickMedicalCertificate() async {
    final f = await _pickDocument();
    if (f != null) {
      _medicalCertificate = f;
      notifyListeners();
    }
  }

  Future<XFile?> _pickDocument() async {
    final result = await FilePicker.platform.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: const ['pdf', 'jpg', 'jpeg', 'png'],
    );
    if (result == null || result.files.isEmpty) return null;
    final file = result.files.first;
    if (file.bytes == null) return null;
    return XFile.fromData(file.bytes!, name: file.name);
  }

  void setDateOfBirth(DateTime date) {
    _dateOfBirth = date;
    dobController.text = _formatDate(date);
    notifyListeners();
  }

  void setLicenseExpiry(DateTime date) {
    _licenseExpiry = date;
    licenseExpiryController.text = _formatDate(date);
    notifyListeners();
  }

  DateTime? get dateOfBirth => _dateOfBirth;
  DateTime? get licenseExpiry => _licenseExpiry;

  // ── Submit ──────────────────────────────────────────────────────────────────
  Future<bool> submit() async {
    _isSaving = true;
    _error = null;
    notifyListeners();
    try {
      final preferredLang = _preferredLang;
      final bool ok;
      if (isDriver) {
        ok = await _driverRepository.updateProfile(
          id: userId,
          fullName: nameController.text.trim(),
          fullNameAr: nameArController.text.trim(),
          email: emailController.text.trim(),
          gender: ProfileFieldCodecs.encodeGender(_selectedGender),
          preferredLang: preferredLang,
          dateOfBirthIso: (_dateOfBirth ?? DateTime.now()).toIso8601String(),
          isActive: _isActive,
          isVerified: _isVerified,
          phoneNumber: _phoneNumber,
          lat: _lat,
          lon: _lon,
          licenceNumber: licenseNumberController.text.trim(),
          carPlateNumber: carPlateController.text.trim(),
          licenceExpiryIso:
              (_licenseExpiry ?? DateTime.now()).toIso8601String(),
          locationId: _selectedLocationId,
          hasVehicle: _hasVehicle,
          languagesKnown: ProfileFieldCodecs.encodeLanguages(_selectedLanguages),
          yearsOfExperience:
              int.tryParse(yearsExperienceController.text.trim()),
          amountPerDay: double.tryParse(amountPerDayController.text.trim()),
          amountPerHour: double.tryParse(amountPerHourController.text.trim()),
          allCompanyId: _allCompanyId,
          photo: _avatar,
          photoUrl: _photoUrl,
          civilIdFront: _civilIdFront,
          civilIdUrlF: _civilIdUrlF,
          civilIdBack: _civilIdBack,
          civilIdUrlB: _civilIdUrlB,
          drivingLicenseFront: _drivingLicenseFront,
          drivingLicenseBack: _drivingLicenseBack,
          medicalReport: _medicalCertificate,
        );
      } else {
        ok = await _customerRepository.updateProfile(
          id: userId,
          fullName: nameController.text.trim(),
          fullNameAr: nameArController.text.trim(),
          email: emailController.text.trim(),
          gender: ProfileFieldCodecs.encodeGender(_selectedGender),
          preferredLang: preferredLang,
          dateOfBirthIso: (_dateOfBirth ?? DateTime.now()).toIso8601String(),
          isActive: _isActive,
          phoneNumber: _phoneNumber,
          lat: _lat,
          lon: _lon,
          photo: _avatar,
          photoUrl: _photoUrl,
          civilIdFront: _civilIdFront,
          civilIdUrlF: _civilIdUrlF,
          civilIdBack: _civilIdBack,
          civilIdUrlB: _civilIdUrlB,
        );
      }

      if (!ok) {
        _error = 'profile_edit_save_error'.tr();
        return false;
      }

      // Cache the saved gender so the form prefills next time (the Customer GET
      // doesn't return gender, so this is the only fresh source post-edit).
      final genderCode = ProfileFieldCodecs.encodeGender(_selectedGender);
      if (genderCode.isNotEmpty) {
        await _storage.write(key: StorageKeys.userGender, value: genderCode);
      }

      // Refresh cached identity (name/email/photo) so profile + home reflect it.
      if (isDriver) {
        await _authProvider.refreshDriverStatus();
      } else {
        await _authProvider.refreshCustomerStatus();
      }
      return true;
    } on AppException catch (e) {
      _error = e.message;
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────
  void _setDob(String? iso) {
    final dt = _parseDate(iso);
    if (dt != null) {
      _dateOfBirth = dt;
      dobController.text = _formatDate(dt);
    }
  }

  void _setLicenseExpiry(String? iso) {
    final dt = _parseDate(iso);
    if (dt != null) {
      _licenseExpiry = dt;
      licenseExpiryController.text = _formatDate(dt);
    }
  }

  static DateTime? _parseDate(String? iso) {
    if (iso == null || iso.trim().isEmpty) return null;
    return DateTime.tryParse(iso.trim());
  }

  static String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  bool _isValidEmail(String email) =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  @override
  void dispose() {
    nameController.dispose();
    nameArController.dispose();
    emailController.dispose();
    dobController.dispose();
    licenseNumberController.dispose();
    licenseExpiryController.dispose();
    carPlateController.dispose();
    yearsExperienceController.dispose();
    amountPerDayController.dispose();
    amountPerHourController.dispose();
    super.dispose();
  }
}
