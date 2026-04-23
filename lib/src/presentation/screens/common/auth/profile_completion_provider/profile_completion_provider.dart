import 'package:flutter/material.dart';
import 'package:intl_phone_field/countries.dart';

/// Owns all form state for the profile completion flow.
///
/// Splitting customer vs driver validation into a single [ChangeNotifier] keeps
/// the screen composable (one provider, many widgets) while preserving the
/// original submit-button enablement semantics.
class ProfileCompletionProvider extends ChangeNotifier {
  ProfileCompletionProvider({required this.isDriver}) {
    nameController.addListener(_validate);
    emailController.addListener(_validate);
    dobController.addListener(_validate);
    if (isDriver) {
      licenseNumberController.addListener(_validate);
      licenseExpiryController.addListener(_validate);
      nationalIdController.addListener(_validate);
      yearsExperienceController.addListener(_validate);
    }
  }

  final bool isDriver;

  // Common controllers
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController = TextEditingController();

  // Driver-only controllers
  final TextEditingController licenseNumberController = TextEditingController();
  final TextEditingController licenseExpiryController = TextEditingController();
  final TextEditingController nationalIdController = TextEditingController();
  final TextEditingController yearsExperienceController = TextEditingController();

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

  String? _civilIdFrontFileName;
  String? get civilIdFrontFileName => _civilIdFrontFileName;

  String? _civilIdBackFileName;
  String? get civilIdBackFileName => _civilIdBackFileName;

  String? _medicalCertificateFileName;
  String? get medicalCertificateFileName => _medicalCertificateFileName;

  String? _drivingLicenseFileName;
  String? get drivingLicenseFileName => _drivingLicenseFileName;

  bool _avatarPicked = false;
  bool get avatarPicked => _avatarPicked;

  bool _isButtonEnabled = false;
  bool get isButtonEnabled => _isButtonEnabled;

  void pickAvatar() {
    _avatarPicked = true;
    notifyListeners();
  }

  void setCivilIdFront(String fileName) {
    _civilIdFrontFileName = fileName;
    _validate();
  }

  void setCivilIdBack(String fileName) {
    _civilIdBackFileName = fileName;
    _validate();
  }

  void setMedicalCertificate(String fileName) {
    _medicalCertificateFileName = fileName;
    _validate();
  }

  void setDrivingLicense(String fileName) {
    _drivingLicenseFileName = fileName;
    _validate();
  }

  void setDateOfBirth(DateTime date) {
    dobController.text = _formatDate(date);
    // Listener on controller triggers validation.
  }

  void setLicenseExpiry(DateTime date) {
    licenseExpiryController.text = _formatDate(date);
  }

  static String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d/$m/${date.year}';
  }

  bool _isValidEmail(String email) => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  void _validate() {
    final commonOk =
        nameController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        _isValidEmail(emailController.text.trim()) &&
        dobController.text.trim().isNotEmpty &&
        _selectedCountry != null &&
        _selectedGender != null;

    bool next;
    if (!isDriver) {
      next = commonOk;
    } else {
      next =
          commonOk &&
          licenseNumberController.text.trim().isNotEmpty &&
          licenseExpiryController.text.trim().isNotEmpty &&
          nationalIdController.text.trim().isNotEmpty &&
          yearsExperienceController.text.trim().isNotEmpty &&
          _selectedLanguages.isNotEmpty &&
          _civilIdFrontFileName != null &&
          _civilIdBackFileName != null &&
          _medicalCertificateFileName != null &&
          _drivingLicenseFileName != null;
    }

    if (next != _isButtonEnabled) {
      _isButtonEnabled = next;
      notifyListeners();
    } else {
      // Still notify so dependent widgets (selected country, gender,
      // languages, file names) repaint when changes don't flip enablement.
      notifyListeners();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    dobController.dispose();
    licenseNumberController.dispose();
    licenseExpiryController.dispose();
    nationalIdController.dispose();
    yearsExperienceController.dispose();
    super.dispose();
  }
}
