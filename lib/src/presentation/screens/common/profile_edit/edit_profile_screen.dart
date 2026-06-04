import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../constants/breakpoints.dart';
import '../../../../constants/storage_keys.dart';
import '../../../../core/data/repositories/customer_repository.dart';
import '../../../../core/data/repositories/driver_repository.dart';
import '../../../../core/data/repositories/lookup_repository.dart';
import '../../../../core/di/injection_container.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/role_provider.dart';
import '../auth/profile_completion_models/gender_option.dart';
import '../auth/profile_completion_models/language_option.dart';
import '../auth/profile_completion_widgets/document_picker_tile.dart';
import '../auth/profile_completion_widgets/dropdown_field.dart';
import '../auth/profile_completion_widgets/input_field.dart';
import '../auth/profile_completion_widgets/multi_select_field.dart';
import '../auth/profile_completion_widgets/profile_avatar_picker.dart';
import '../auth/profile_completion_widgets/section_header.dart';
import '../auth/profile_completion_widgets/submit_button.dart';
import 'provider/edit_profile_provider.dart';

/// A focused profile editor for one [EditProfileSection]. Resolves the user id
/// from storage, builds an [EditProfileProvider] pre-filled from the current
/// record, and saves via `PUT /api/Customer` / `PUT /api/Driver`. The provider
/// always sends the full payload, so untouched groups round-trip unchanged.
class EditProfileScreen extends StatefulWidget {
  final EditProfileSection section;
  const EditProfileScreen({super.key, this.section = EditProfileSection.personal});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late final Future<int?> _userIdFuture;

  @override
  void initState() {
    super.initState();
    _userIdFuture = _readUserId();
  }

  Future<int?> _readUserId() async {
    final raw = await getIt<FlutterSecureStorage>().read(key: StorageKeys.userId);
    return int.tryParse(raw ?? '');
  }

  String _title() {
    switch (widget.section) {
      case EditProfileSection.personal:
        return 'profile_edit_personal'.tr();
      case EditProfileSection.vehicle:
        return 'profile_edit_vehicle'.tr();
      case EditProfileSection.professional:
        return 'profile_edit_professional'.tr();
      case EditProfileSection.documents:
        return 'profile_edit_documents'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FutureBuilder<int?>(
      future: _userIdFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return _scaffold(isDark, const Center(child: CircularProgressIndicator()));
        }
        final userId = snapshot.data;
        if (userId == null) {
          return _scaffold(isDark, _ErrorState(message: 'profile_edit_load_error'.tr()));
        }
        final role = context.read<RoleProvider>().role ?? UserRole.customer;
        final auth = context.read<AuthProvider>();
        return ChangeNotifierProvider<EditProfileProvider>(
          create: (_) => EditProfileProvider(
            role: role,
            userId: userId,
            customerRepository: getIt<CustomerRepository>(),
            driverRepository: getIt<DriverRepository>(),
            lookupRepository: getIt<LookupRepository>(),
            authProvider: auth,
          )..load(),
          child: _EditProfileView(isDark: isDark, section: widget.section, title: _title()),
        );
      },
    );
  }

  Widget _scaffold(bool isDark, Widget body) {
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        elevation: 0,
        title: Text(_title()),
      ),
      body: body,
    );
  }
}

class _EditProfileView extends StatelessWidget {
  final bool isDark;
  final EditProfileSection section;
  final String title;
  const _EditProfileView({required this.isDark, required this.section, required this.title});

  // ── Date pickers ────────────────────────────────────────────────────────────
  Future<void> _pickDob(BuildContext context) async {
    final eighteenYearsAgo = DateTime.now().subtract(const Duration(days: 365 * 18));
    final provider = context.read<EditProfileProvider>();
    final picked = await _showDatePicker(
      context,
      initial: provider.dateOfBirth ?? DateTime(1990, 1, 1),
      minimum: DateTime(1950),
      maximum: eighteenYearsAgo,
    );
    if (picked != null && context.mounted) provider.setDateOfBirth(picked);
  }

  Future<void> _pickLicenseExpiry(BuildContext context) async {
    final now = DateTime.now();
    final provider = context.read<EditProfileProvider>();
    final picked = await _showDatePicker(
      context,
      initial: provider.licenseExpiry ?? now.add(const Duration(days: 365)),
      minimum: now,
      maximum: DateTime(2040),
    );
    if (picked != null && context.mounted) provider.setLicenseExpiry(picked);
  }

  Future<DateTime?> _showDatePicker(
    BuildContext context, {
    required DateTime initial,
    required DateTime minimum,
    required DateTime maximum,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    var selected = initial;
    return showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: 320.r,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.of(sheetContext).pop(),
                      child: Text('cancel'.tr()),
                    ),
                    CupertinoButton(
                      onPressed: () => Navigator.of(sheetContext).pop(selected),
                      child: Text('done'.tr()),
                    ),
                  ],
                ),
                Expanded(
                  child: CupertinoDatePicker(
                    mode: CupertinoDatePickerMode.date,
                    initialDateTime: initial,
                    minimumDate: minimum,
                    maximumDate: maximum,
                    onDateTimeChanged: (value) => selected = value,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _onSave(BuildContext context) async {
    final provider = context.read<EditProfileProvider>();
    if (!provider.canSaveSection(section) || provider.isSaving) return;
    final messenger = ScaffoldMessenger.of(context);
    final ok = await provider.submit();
    if (!context.mounted) return;
    if (ok) {
      messenger.showSnackBar(SnackBar(content: Text('profile_edit_saved'.tr())));
      context.pop();
    } else {
      messenger.showSnackBar(SnackBar(content: Text(provider.error ?? 'profile_edit_save_error'.tr())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<EditProfileProvider>();
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        elevation: 0,
        title: Text(title),
      ),
      body: provider.isInitialLoading
          ? const Center(child: CircularProgressIndicator())
          : provider.loadError != null
          ? _ErrorState(message: provider.loadError!, onRetry: provider.load)
          : LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = Breakpoints.isDesktop(constraints.maxWidth);
                final form = _buildForm(context, provider, desktop: isDesktop);
                if (isDesktop) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: 40.r, vertical: 24.r),
                    child: Center(
                      child: ConstrainedBox(constraints: BoxConstraints(maxWidth: 720.r), child: form),
                    ),
                  );
                }
                return SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(20.r, 12.r, 20.r, 32.r),
                  physics: const BouncingScrollPhysics(),
                  child: form,
                );
              },
            ),
    );
  }

  Widget _buildForm(BuildContext context, EditProfileProvider provider, {required bool desktop}) {
    final children = <Widget>[];
    switch (section) {
      case EditProfileSection.personal:
        children.addAll(_personalFields(context, provider, desktop));
      case EditProfileSection.vehicle:
        children.addAll(_vehicleFields(context, provider, desktop));
      case EditProfileSection.professional:
        children.addAll(_professionalFields(provider, desktop));
      case EditProfileSection.documents:
        children.addAll(_documentFields(provider, desktop));
    }

    children.addAll([
      SizedBox(height: 28.r),
      desktop
          ? SubmitButtonDesktop(
              label: 'profile_edit_save'.tr(),
              enabled: provider.canSaveSection(section),
              loading: provider.isSaving,
              onTap: () => _onSave(context),
            )
          : SubmitButton(
              label: 'profile_edit_save'.tr(),
              enabled: provider.canSaveSection(section),
              loading: provider.isSaving,
              onTap: () => _onSave(context),
            ),
    ]);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
  }

  List<Widget> _personalFields(BuildContext context, EditProfileProvider provider, bool desktop) => [
        Center(
          child: ProfileAvatarPicker(
            picked: provider.avatarPicked,
            isDark: isDark,
            size: 96.r,
            imageBytes: provider.avatarBytes,
            networkImageUrl: provider.avatarUrl,
            onTap: provider.pickAvatar,
          ),
        ),
        SizedBox(height: 24.r),
        _header('section_personal_info'.tr(), desktop),
        SizedBox(height: 14.r),
        _text(provider.nameController, 'enter_name'.tr(), 'full_name'.tr(), Icons.person_outline, desktop),
        SizedBox(height: 16.r),
        _text(provider.nameArController, 'enter_name_ar'.tr(), 'full_name_ar'.tr(), Icons.person_outline, desktop),
        SizedBox(height: 16.r),
        _text(provider.emailController, 'enter_email'.tr(), 'email'.tr(), Icons.email_outlined, desktop,
            keyboardType: TextInputType.emailAddress),
        SizedBox(height: 16.r),
        _readOnlyPhone(provider, desktop),
        SizedBox(height: 16.r),
        GestureDetector(
          onTap: () => _pickDob(context),
          child: AbsorbPointer(
            child: _text(provider.dobController, 'DD/MM/YYYY', 'date_of_birth'.tr(),
                Icons.calendar_today_outlined, desktop),
          ),
        ),
        SizedBox(height: 16.r),
        DropdownField(
          value: provider.selectedGender,
          hint: 'select_gender'.tr(),
          label: 'gender'.tr(),
          icon: Icons.people_outline,
          isDark: isDark,
          items: kGenderOptions,
          onChanged: (value) => provider.selectedGender = value,
        ),
      ];

  List<Widget> _vehicleFields(BuildContext context, EditProfileProvider provider, bool desktop) => [
        _header('section_license'.tr(), desktop),
        SizedBox(height: 14.r),
        _text(provider.licenseNumberController, 'enter_license_number'.tr(), 'license_number'.tr(),
            Icons.badge_outlined, desktop),
        SizedBox(height: 16.r),
        GestureDetector(
          onTap: () => _pickLicenseExpiry(context),
          child: AbsorbPointer(
            child: _text(provider.licenseExpiryController, 'DD/MM/YYYY', 'license_expiry'.tr(),
                Icons.calendar_today_outlined, desktop),
          ),
        ),
        SizedBox(height: 16.r),
        _text(provider.carPlateController, 'enter_car_plate'.tr(), 'car_plate_number'.tr(),
            Icons.directions_car_outlined, desktop),
        SizedBox(height: 16.r),
        DropdownField(
          value: provider.selectedLocationName,
          hint: 'select_location'.tr(),
          label: 'driver_location'.tr(),
          icon: Icons.location_on_outlined,
          isDark: isDark,
          items: provider.locationNames,
          onChanged: provider.selectLocationByName,
        ),
        SizedBox(height: 16.r),
        _hasVehicleToggle(provider),
      ];

  List<Widget> _professionalFields(EditProfileProvider provider, bool desktop) => [
        _header('section_additional_info'.tr(), desktop),
        SizedBox(height: 14.r),
        _text(provider.yearsExperienceController, 'enter_years_experience'.tr(),
            'years_driving_experience'.tr(), Icons.timer_outlined, desktop,
            keyboardType: const TextInputType.numberWithOptions(decimal: true)),
        SizedBox(height: 16.r),
        MultiSelectField(
          values: provider.selectedLanguages,
          hint: 'select_languages'.tr(),
          label: 'languages_spoken'.tr(),
          icon: Icons.language_outlined,
          isDark: isDark,
          items: kLanguageOptions,
          onChanged: (values) => provider.selectedLanguages = values,
        ),
        SizedBox(height: 16.r),
        _text(provider.amountPerDayController, 'enter_amount'.tr(), 'amount_per_day'.tr(),
            Icons.payments_outlined, desktop,
            keyboardType: const TextInputType.numberWithOptions(decimal: true)),
        SizedBox(height: 16.r),
        _text(provider.amountPerHourController, 'enter_amount'.tr(), 'amount_per_hour'.tr(),
            Icons.schedule_outlined, desktop,
            keyboardType: const TextInputType.numberWithOptions(decimal: true)),
      ];

  List<Widget> _documentFields(EditProfileProvider provider, bool desktop) {
    final docs = <Widget>[
      _header('section_documents'.tr(), desktop),
      SizedBox(height: 14.r),
      _doc(
        label: 'civil_id_front'.tr(),
        subtitle: 'civil_id_front_hint'.tr(),
        icon: Icons.badge_outlined,
        fileName: provider.civilIdFrontFileName,
        hasExisting: provider.hasCivilIdFront,
        onTap: provider.pickCivilIdFront,
        desktop: desktop,
      ),
      SizedBox(height: 12.r),
      _doc(
        label: 'civil_id_back'.tr(),
        subtitle: 'civil_id_back_hint'.tr(),
        icon: Icons.badge_outlined,
        fileName: provider.civilIdBackFileName,
        hasExisting: provider.hasCivilIdBack,
        onTap: provider.pickCivilIdBack,
        desktop: desktop,
      ),
    ];
    if (provider.isDriver) {
      docs.addAll([
        SizedBox(height: 12.r),
        _doc(
          label: 'medical_certificate'.tr(),
          subtitle: 'medical_certificate_hint'.tr(),
          icon: Icons.medical_services_outlined,
          fileName: provider.medicalCertificateFileName,
          onTap: provider.pickMedicalCertificate,
          desktop: desktop,
        ),
        SizedBox(height: 12.r),
        _doc(
          label: 'driving_license_front'.tr(),
          subtitle: 'driving_license_front_hint'.tr(),
          icon: Icons.contact_mail_outlined,
          fileName: provider.drivingLicenseFrontFileName,
          onTap: provider.pickDrivingLicenseFront,
          desktop: desktop,
        ),
        SizedBox(height: 12.r),
        _doc(
          label: 'driving_license_back'.tr(),
          subtitle: 'driving_license_back_hint'.tr(),
          icon: Icons.contact_mail_outlined,
          fileName: provider.drivingLicenseBackFileName,
          onTap: provider.pickDrivingLicenseBack,
          desktop: desktop,
        ),
      ]);
    }
    return docs;
  }

  Widget _header(String label, bool desktop) =>
      desktop ? SectionHeaderDesktop(label: label, isDark: isDark) : SectionHeader(label: label, isDark: isDark);

  Widget _text(
    TextEditingController controller,
    String hint,
    String label,
    IconData icon,
    bool desktop, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    if (desktop) {
      return InputFieldDesktop(
        controller: controller,
        hint: hint,
        label: label,
        icon: icon,
        isDark: isDark,
        keyboardType: keyboardType,
      );
    }
    return InputField(
      controller: controller,
      hint: hint,
      label: label,
      icon: icon,
      isDark: isDark,
      keyboardType: keyboardType,
    );
  }

  /// Phone is the login identity — shown but not editable. Static (no controller)
  /// so repeated rebuilds don't leak controllers.
  Widget _readOnlyPhone(EditProfileProvider provider, bool desktop) {
    final value = provider.phoneNumber ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'profile_phone'.tr(),
          style: TextStyle(
            fontSize: (desktop ? 14 : 13).r,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF555555),
          ),
        ),
        SizedBox(height: 8.r),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF181818) : const Color(0xFFEDEDED),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 16.r),
          child: Row(
            children: [
              Icon(Icons.call_outlined, color: isDark ? Colors.white38 : const Color(0xFF9E9E9E), size: 20.r),
              SizedBox(width: 12.r),
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 15.r,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white60 : const Color(0xFF6B6B6B),
                  ),
                ),
              ),
              Icon(Icons.lock_outline, color: isDark ? Colors.white24 : const Color(0xFFBDBDBD), size: 16.r),
            ],
          ),
        ),
      ],
    );
  }

  Widget _doc({
    required String label,
    required String subtitle,
    required IconData icon,
    required String? fileName,
    required VoidCallback onTap,
    required bool desktop,
    bool hasExisting = false,
  }) {
    final existingLabel = 'profile_edit_document_on_file'.tr();
    if (desktop) {
      return DocumentPickerTileDesktop(
        label: label,
        subtitle: subtitle,
        icon: icon,
        fileName: fileName,
        isDark: isDark,
        onTap: onTap,
        hasExisting: hasExisting,
        existingLabel: existingLabel,
      );
    }
    return DocumentPickerTile(
      label: label,
      subtitle: subtitle,
      icon: icon,
      fileName: fileName,
      isDark: isDark,
      onTap: onTap,
      hasExisting: hasExisting,
      existingLabel: existingLabel,
    );
  }

  Widget _hasVehicleToggle(EditProfileProvider provider) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 6.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
      ),
      child: Row(
        children: [
          Icon(Icons.directions_car_filled_outlined,
              color: isDark ? Colors.white38 : const Color(0xFF9E9E9E), size: 20.r),
          SizedBox(width: 12.r),
          Expanded(
            child: Text(
              'has_own_vehicle'.tr(),
              style: TextStyle(
                fontSize: 14.r,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : const Color(0xFF3D3D3D),
              ),
            ),
          ),
          Switch(value: provider.hasVehicle, onChanged: (value) => provider.hasVehicle = value),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const _ErrorState({required this.message, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 44.r, color: Colors.redAccent),
            SizedBox(height: 12.r),
            Text(message, textAlign: TextAlign.center),
            if (onRetry != null) ...[
              SizedBox(height: 16.r),
              FilledButton(onPressed: onRetry, child: Text('retry'.tr())),
            ],
          ],
        ),
      ),
    );
  }
}
