import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/countries.dart';

import '../../../../../core/data/repositories/lookup_repository.dart';
import '../../../../../core/models/lookup/location_option.dart';
import '../../../../../core/services/location_service.dart';
import '../profile_completion_models/profile_field_codecs.dart';

/// Owns all form state for the profile completion flow.
///
/// One [ChangeNotifier] backs both the customer and driver forms; the driver
/// branch simply has more fields. Picked files are kept as [XFile]s so they
/// upload on web (bytes) and mobile (path) alike. Every field that the
/// `complete-individual-profile` / `complete-profile-driver` endpoints accept
/// is represented here.
class ProfileCompletionProvider extends ChangeNotifier {
  ProfileCompletionProvider({
    required this.userId,
    required this.isDriver,
    LookupRepository? lookupRepository,
  }) : _lookupRepository = lookupRepository {
    nameController.addListener(_validate);
    emailController.addListener(_validate);
    dobController.addListener(_validate);
    if (isDriver) {
      licenseNumberController.addListener(_validate);
      licenseExpiryController.addListener(_validate);
      yearsExperienceController.addListener(_validate);
      _loadLocations();
    }
  }

  /// Backend user id returned from verify-otp — the row this profile completes.
  final int userId;
  final bool isDriver;

  final LookupRepository? _lookupRepository;
  final LocationService _locationService = const LocationService();

  // ── Common controllers ────────────────────────────────────────────────────
  final TextEditingController nameController = TextEditingController();
  final TextEditingController nameArController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  // ── Driver-only controllers ───────────────────────────────────────────────
  final TextEditingController licenseNumberController = TextEditingController();
  final TextEditingController licenseExpiryController = TextEditingController();
  final TextEditingController carPlateController = TextEditingController();
  final TextEditingController yearsExperienceController = TextEditingController();
  final TextEditingController amountPerDayController = TextEditingController();
  final TextEditingController amountPerHourController = TextEditingController();

  Country? _selectedCountry;
  Country? get selectedCountry => _selectedCountry;
  set selectedCountry(Country? value) {
    _selectedCountry = value;
    _validate();
  }

  String? _selectedGender;
  String? get selectedGender => _selectedGender;
  set selectedGender(String? value) {
    _selectedGender = value;
    _validate();
  }

  List<String> _selectedLanguages = <String>[];
  List<String> get selectedLanguages => List.unmodifiable(_selectedLanguages);
  set selectedLanguages(List<String> values) {
    _selectedLanguages = List<String>.from(values);
    _validate();
  }

  bool _hasVehicle = false;
  bool get hasVehicle => _hasVehicle;
  set hasVehicle(bool value) {
    _hasVehicle = value;
    notifyListeners();
  }

  // ── Location dropdown (driver base location) ──────────────────────────────
  List<LocationOption> _locations = const [];
  List<LocationOption> get locations => List.unmodifiable(_locations);
  bool _loadingLocations = false;
  bool get loadingLocations => _loadingLocations;

  int? _selectedLocationId;
  int? get selectedLocationId => _selectedLocationId;

  String? _selectedLocationName;
  String? get selectedLocationName => _selectedLocationName;

  /// Display labels fed to the dropdown widget.
  List<String> get locationNames => _locations.map((l) => l.name).toList();

  void selectLocationByName(String? name) {
    _selectedLocationName = name;
    final match = _locations.where((l) => l.name == name);
    _selectedLocationId = match.isEmpty ? null : match.first.id;
    _validate();
  }

  Future<void> _loadLocations() async {
    final repo = _lookupRepository;
    if (repo == null) return;
    _loadingLocations = true;
    notifyListeners();
    try {
      _locations = await repo.getActiveLocations();
    } catch (_) {
      _locations = const [];
    } finally {
      _loadingLocations = false;
      notifyListeners();
    }
  }

  // ── Picked files ──────────────────────────────────────────────────────────
  XFile? _avatar;
  XFile? get avatar => _avatar;
  bool get avatarPicked => _avatar != null;

  // In-memory bytes of the picked avatar, used to render a live preview
  // (works on web and mobile, where XFile has no usable path on web).
  Uint8List? _avatarBytes;
  Uint8List? get avatarBytes => _avatarBytes;

  XFile? _civilIdFront;
  XFile? get civilIdFront => _civilIdFront;
  String? get civilIdFrontFileName => _civilIdFront?.name;

  XFile? _civilIdBack;
  XFile? get civilIdBack => _civilIdBack;
  String? get civilIdBackFileName => _civilIdBack?.name;

  XFile? _drivingLicenseFront;
  XFile? get drivingLicenseFront => _drivingLicenseFront;
  String? get drivingLicenseFrontFileName => _drivingLicenseFront?.name;

  XFile? _drivingLicenseBack;
  XFile? get drivingLicenseBack => _drivingLicenseBack;
  String? get drivingLicenseBackFileName => _drivingLicenseBack?.name;

  XFile? _medicalCertificate;
  XFile? get medicalCertificate => _medicalCertificate;
  String? get medicalCertificateFileName => _medicalCertificate?.name;

  // Best-effort captured location (optional — null when permission denied).
  double? _lat;
  double? _lon;
  double? get lat => _lat;
  double? get lon => _lon;

  // Date values backing the display controllers — used to build ISO payloads.
  DateTime? _dateOfBirth;
  DateTime? _licenseExpiry;

  bool _isButtonEnabled = false;
  bool get isButtonEnabled => _isButtonEnabled;

  // True while the profile is being submitted (location capture + upload), so
  // the submit button can show a spinner and block double taps.
  bool _submitting = false;
  bool get isSubmitting => _submitting;
  void setSubmitting(bool value) {
    if (_submitting == value) return;
    _submitting = value;
    notifyListeners();
  }

  // ── Driver multi-step wizard state ────────────────────────────────────────
  static const int driverStepCount = 4;
  int _driverStep = 0;
  int get driverStep => _driverStep;
  bool get isFirstStep => _driverStep == 0;
  bool get isLastStep => _driverStep == driverStepCount - 1;

  void nextStep() {
    if (_driverStep < driverStepCount - 1) {
      _driverStep++;
      notifyListeners();
    }
  }

  void prevStep() {
    if (_driverStep > 0) {
      _driverStep--;
      notifyListeners();
    }
  }

  /// Whether the fields on [step] are sufficiently filled to advance. Optional
  /// fields (Arabic name, car plate, location, rates, has-vehicle, licence back)
  /// never block progression.
  bool isStepValid(int step) {
    switch (step) {
      case 0:
        return _commonValid;
      case 1:
        return licenseNumberController.text.trim().isNotEmpty &&
            licenseExpiryController.text.trim().isNotEmpty;
      case 2:
        return yearsExperienceController.text.trim().isNotEmpty &&
            _selectedLanguages.isNotEmpty;
      case 3:
        return _civilIdFront != null &&
            _civilIdBack != null &&
            _drivingLicenseFront != null &&
            _medicalCertificate != null;
      default:
        return true;
    }
  }

  bool get _commonValid =>
      nameController.text.trim().isNotEmpty &&
      emailController.text.trim().isNotEmpty &&
      _isValidEmail(emailController.text.trim()) &&
      dobController.text.trim().isNotEmpty &&
      _selectedCountry != null &&
      _selectedGender != null;

  // ── Derived payload values ────────────────────────────────────────────────
  String? get dateOfBirthIso => _dateOfBirth?.toIso8601String();
  String? get licenseExpiryIso => _licenseExpiry?.toIso8601String();

  /// Backend gender code (`M`/`F`/`O`) for the selected option.
  String get genderCode => ProfileFieldCodecs.encodeGender(_selectedGender);

  /// Comma-separated backend language codes for the selected languages.
  String get languagesKnownCsv =>
      ProfileFieldCodecs.encodeLanguages(_selectedLanguages);

  int? get yearsOfExperience => int.tryParse(yearsExperienceController.text.trim());
  double? get amountPerDay => double.tryParse(amountPerDayController.text.trim());
  double? get amountPerHour => double.tryParse(amountPerHourController.text.trim());

  // ── Pickers ───────────────────────────────────────────────────────────────
  Future<void> captureLocation() async {
    final loc = await _locationService.getCurrentLocation();
    if (loc != null) {
      _lat = loc.lat;
      _lon = loc.lon;
    }
  }

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
      _validate();
    }
  }

  Future<void> pickCivilIdBack() async {
    final f = await _pickDocument();
    if (f != null) {
      _civilIdBack = f;
      _validate();
    }
  }

  Future<void> pickDrivingLicenseFront() async {
    final f = await _pickDocument();
    if (f != null) {
      _drivingLicenseFront = f;
      _validate();
    }
  }

  Future<void> pickDrivingLicenseBack() async {
    final f = await _pickDocument();
    if (f != null) {
      _drivingLicenseBack = f;
      _validate();
    }
  }

  Future<void> pickMedicalCertificate() async {
    final f = await _pickDocument();
    if (f != null) {
      _medicalCertificate = f;
      _validate();
    }
  }

  /// Picks a document (image or PDF) and returns it as an [XFile] carrying its
  /// bytes, so the upload works identically on web and mobile.
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
    // Listener on the controller triggers validation.
  }

  void setLicenseExpiry(DateTime date) {
    _licenseExpiry = date;
    licenseExpiryController.text = _formatDate(date);
  }

  static String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  bool _isValidEmail(String email) => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  void _validate() {
    bool next;
    if (!isDriver) {
      next = _commonValid;
    } else {
      next = _commonValid &&
          isStepValid(1) &&
          isStepValid(2) &&
          isStepValid(3);
    }

    if (next != _isButtonEnabled) {
      _isButtonEnabled = next;
      notifyListeners();
    } else {
      // Still notify so dependent widgets (country, gender, languages, file
      // names, location) repaint when changes don't flip enablement.
      notifyListeners();
    }
  }

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
