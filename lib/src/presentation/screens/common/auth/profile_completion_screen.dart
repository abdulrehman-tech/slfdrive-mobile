import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:provider/provider.dart';
import '../../../../constants/icon_constants.dart';
import '../../../../constants/color_constants.dart';
import '../../../../constants/breakpoints.dart';
import '../../../providers/role_provider.dart';
import '../../../widgets/bottom_sheets/dropdown_bottom_sheet.dart';
import '../../../widgets/bottom_sheets/multi_select_bottom_sheet.dart';
import '../../../widgets/country_selector_field.dart';

class ProfileCompletionScreen extends StatefulWidget {
  final String phoneNumber;
  final bool isDriver;

  const ProfileCompletionScreen({super.key, required this.phoneNumber, this.isDriver = false});

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  // Common
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _dobController = TextEditingController();
  Country? _selectedCountry;
  String? _selectedGender;

  // Driver-only
  final _licenseNumberController = TextEditingController();
  final _licenseExpiryController = TextEditingController();
  final _nationalIdController = TextEditingController();
  final _yearsExperienceController = TextEditingController();
  List<String> _selectedLanguages = [];

  String? _civilIdFrontFileName;
  String? _civilIdBackFileName;
  String? _medicalCertificateFileName;
  String? _drivingLicenseFileName;
  bool _avatarPicked = false;
  bool _isButtonEnabled = false;

  // Language options
  final _languages = ['English', 'Arabic', 'Hindi', 'Urdu', 'Malayalam', 'Tamil', 'Tagalog', 'Bengali', 'French'];

  // Gender options
  final _genders = ['Male', 'Female', 'Other', 'Prefer not to say'];

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _dobController.addListener(_validateForm);
    if (widget.isDriver) {
      _licenseNumberController.addListener(_validateForm);
      _licenseExpiryController.addListener(_validateForm);
      _nationalIdController.addListener(_validateForm);
      _yearsExperienceController.addListener(_validateForm);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _licenseNumberController.dispose();
    _licenseExpiryController.dispose();
    _nationalIdController.dispose();
    _yearsExperienceController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) => RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);

  void _validateForm() {
    final commonOk =
        _nameController.text.trim().isNotEmpty &&
        _emailController.text.trim().isNotEmpty &&
        _isValidEmail(_emailController.text.trim()) &&
        _dobController.text.trim().isNotEmpty &&
        _selectedCountry != null &&
        _selectedGender != null;

    if (!widget.isDriver) {
      setState(() => _isButtonEnabled = commonOk);
      return;
    }

    final driverOk =
        commonOk &&
        _licenseNumberController.text.trim().isNotEmpty &&
        _licenseExpiryController.text.trim().isNotEmpty &&
        _nationalIdController.text.trim().isNotEmpty &&
        _yearsExperienceController.text.trim().isNotEmpty &&
        _selectedLanguages.isNotEmpty &&
        _civilIdFrontFileName != null &&
        _civilIdBackFileName != null &&
        _medicalCertificateFileName != null &&
        _drivingLicenseFileName != null;

    setState(() => _isButtonEnabled = driverOk);
  }

  Future<void> _onComplete() async {
    if (!_isButtonEnabled) return;
    await context.read<RoleProvider>().setRole(widget.isDriver ? UserRole.driver : UserRole.customer);
    if (!mounted) return;
    if (widget.isDriver) {
      context.go('/driver/home');
    } else {
      context.go('/home');
    }
  }

  void _pickLicenseExpiry(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2040),
    );
    if (picked != null) {
      _licenseExpiryController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      _validateForm();
    }
  }

  void _pickDateOfBirth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990, 1, 1),
      firstDate: DateTime(1950),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
    );
    if (picked != null) {
      _dobController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
      _validateForm();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = Breakpoints.isDesktop(constraints.maxWidth);
          if (isDesktop) return _buildDesktopLayout(isDark);
          return _buildMobileLayout(isDark);
        },
      ),
    );
  }

  // ─── Mobile Layout ──────────────────────────────────────────────────────────

  Widget _buildMobileLayout(bool isDark) {
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 8.r),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => context.pop(),
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                    size: 20.r,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.r),
                  Text(
                    widget.isDriver ? 'driver_profile_title'.tr() : 'profile_title'.tr(),
                    style: TextStyle(
                      fontSize: 26.r,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                    ),
                  ),
                  SizedBox(height: 6.r),
                  Text(
                    'profile_subtitle'.tr(),
                    style: TextStyle(
                      fontSize: 14.r,
                      color: isDark ? Colors.white70 : const Color(0xFF757575),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 24.r),

                  // ── Profile Avatar ──
                  Center(
                    child: _ProfileAvatarPicker(
                      picked: _avatarPicked,
                      isDark: isDark,
                      size: 100.r,
                      onTap: () => setState(() => _avatarPicked = true),
                    ),
                  ),

                  SizedBox(height: 28.r),

                  // ── Common Fields ──
                  _SectionHeader(label: 'section_personal_info'.tr(), isDark: isDark),
                  SizedBox(height: 14.r),
                  _InputField(
                    controller: _nameController,
                    hint: 'enter_name'.tr(),
                    label: 'full_name'.tr(),
                    icon: Icons.person_outline,
                    isDark: isDark,
                  ),
                  SizedBox(height: 16.r),
                  _InputField(
                    controller: _emailController,
                    hint: 'enter_email'.tr(),
                    label: 'email'.tr(),
                    icon: Icons.email_outlined,
                    isDark: isDark,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  SizedBox(height: 16.r),
                  // Date of Birth
                  GestureDetector(
                    onTap: () => _pickDateOfBirth(context),
                    child: AbsorbPointer(
                      child: _InputField(
                        controller: _dobController,
                        hint: 'DD/MM/YYYY',
                        label: 'date_of_birth'.tr(),
                        icon: Icons.calendar_today_outlined,
                        isDark: isDark,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.r),
                  // Country Selector
                  CountrySelectorField(
                    selectedCountry: _selectedCountry,
                    onCountrySelected: (country) {
                      setState(() {
                        _selectedCountry = country;
                        _validateForm();
                      });
                    },
                    isDark: isDark,
                    label: 'country'.tr(),
                    icon: Icons.public_outlined,
                  ),
                  SizedBox(height: 16.r),
                  // Gender Dropdown
                  _DropdownField(
                    value: _selectedGender,
                    hint: 'select_gender'.tr(),
                    label: 'gender'.tr(),
                    icon: Icons.people_outline,
                    isDark: isDark,
                    items: _genders,
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                        _validateForm();
                      });
                    },
                  ),

                  if (widget.isDriver) ...[
                    SizedBox(height: 28.r),

                    // ── Additional Info ──
                    _SectionHeader(label: 'section_additional_info'.tr(), isDark: isDark),
                    SizedBox(height: 14.r),
                    // Years of Experience
                    _InputField(
                      controller: _yearsExperienceController,
                      hint: 'enter_years_experience'.tr(),
                      label: 'years_driving_experience'.tr(),
                      icon: Icons.timer_outlined,
                      isDark: isDark,
                      keyboardType: TextInputType.number,
                    ),
                    SizedBox(height: 16.r),
                    // Languages Multi-select
                    _MultiSelectField(
                      values: _selectedLanguages,
                      hint: 'select_languages'.tr(),
                      label: 'languages_spoken'.tr(),
                      icon: Icons.language_outlined,
                      isDark: isDark,
                      items: _languages,
                      onChanged: (values) {
                        setState(() {
                          _selectedLanguages = values;
                          _validateForm();
                        });
                      },
                    ),

                    SizedBox(height: 28.r),

                    // ── License ──
                    _SectionHeader(label: 'section_license'.tr(), isDark: isDark),
                    SizedBox(height: 14.r),
                    _InputField(
                      controller: _licenseNumberController,
                      hint: 'enter_license_number'.tr(),
                      label: 'license_number'.tr(),
                      icon: Icons.badge_outlined,
                      isDark: isDark,
                    ),
                    SizedBox(height: 16.r),
                    GestureDetector(
                      onTap: () => _pickLicenseExpiry(context),
                      child: AbsorbPointer(
                        child: _InputField(
                          controller: _licenseExpiryController,
                          hint: 'DD/MM/YYYY',
                          label: 'license_expiry'.tr(),
                          icon: Icons.calendar_today_outlined,
                          isDark: isDark,
                        ),
                      ),
                    ),
                    SizedBox(height: 16.r),
                    _InputField(
                      controller: _nationalIdController,
                      hint: 'enter_national_id'.tr(),
                      label: 'national_id'.tr(),
                      icon: Icons.credit_card_outlined,
                      isDark: isDark,
                    ),

                    SizedBox(height: 28.r),

                    // ── Documents ──
                    _SectionHeader(label: 'section_documents'.tr(), isDark: isDark),
                    SizedBox(height: 14.r),
                    _DocumentPickerTile(
                      label: 'civil_id_front'.tr(),
                      subtitle: 'civil_id_front_hint'.tr(),
                      icon: Icons.badge_outlined,
                      fileName: _civilIdFrontFileName,
                      isDark: isDark,
                      onTap: () => setState(() => _civilIdFrontFileName = 'civil_id_front.pdf'),
                    ),
                    SizedBox(height: 12.r),
                    _DocumentPickerTile(
                      label: 'civil_id_back'.tr(),
                      subtitle: 'civil_id_back_hint'.tr(),
                      icon: Icons.badge_outlined,
                      fileName: _civilIdBackFileName,
                      isDark: isDark,
                      onTap: () => setState(() => _civilIdBackFileName = 'civil_id_back.pdf'),
                    ),
                    SizedBox(height: 12.r),
                    _DocumentPickerTile(
                      label: 'medical_certificate'.tr(),
                      subtitle: 'medical_certificate_hint'.tr(),
                      icon: Icons.medical_services_outlined,
                      fileName: _medicalCertificateFileName,
                      isDark: isDark,
                      onTap: () => setState(() => _medicalCertificateFileName = 'medical_certificate.pdf'),
                    ),
                    SizedBox(height: 12.r),
                    _DocumentPickerTile(
                      label: 'driving_license'.tr(),
                      subtitle: 'driving_license_hint'.tr(),
                      icon: Icons.contact_mail_outlined,
                      fileName: _drivingLicenseFileName,
                      isDark: isDark,
                      onTap: () => setState(() => _drivingLicenseFileName = 'driving_license.pdf'),
                    ),

                    SizedBox(height: 20.r),

                    // Pending approval notice
                    Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4D63DD).withOpacity(0.08),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFF4D63DD).withOpacity(0.2)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: const Color(0xFF4D63DD), size: 20.r),
                          SizedBox(width: 10.r),
                          Expanded(
                            child: Text(
                              'pending_approval_note'.tr(),
                              style: TextStyle(
                                fontSize: 13.r,
                                color: isDark ? Colors.white70 : const Color(0xFF555555),
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  SizedBox(height: 32.r),

                  // Submit button
                  _SubmitButton(
                    label: widget.isDriver ? 'submit_for_approval'.tr() : 'get_started'.tr(),
                    enabled: _isButtonEnabled,
                    onTap: () => _onComplete(),
                  ),

                  SizedBox(height: 32.r),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Desktop Layout ─────────────────────────────────────────────────────────

  Widget _buildDesktopLayout(bool isDark) {
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;

    final brandingColumn = Expanded(
      flex: 4,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SvgPicture.asset(isDark ? IconConstants.logoWhite : IconConstants.logo, width: 160.r, height: 160.r),
          SizedBox(height: 32.r),
          Text(
            widget.isDriver ? 'driver_profile_title'.tr() : 'profile_title'.tr(),
            style: TextStyle(
              fontSize: 44.r,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF3D3D3D),
            ),
          ),
          SizedBox(height: 14.r),
          Text(
            'profile_subtitle'.tr(),
            style: TextStyle(fontSize: 17.r, color: isDark ? Colors.white70 : const Color(0xFF757575), height: 1.6),
          ),
          if (widget.isDriver) ...[
            SizedBox(height: 24.r),
            Container(
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: const Color(0xFF4D63DD).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFF4D63DD).withOpacity(0.2)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: const Color(0xFF4D63DD), size: 20.r),
                  SizedBox(width: 10.r),
                  Expanded(
                    child: Text(
                      'pending_approval_note'.tr(),
                      style: TextStyle(
                        fontSize: 13.r,
                        color: isDark ? Colors.white70 : const Color(0xFF555555),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    final formColumn = Expanded(
      flex: 5,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(vertical: 40.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () => context.pop(),
              icon: Icon(
                isRtl ? Icons.arrow_forward_ios : Icons.arrow_back_ios_new,
                color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                size: 22.r,
              ),
            ),
            SizedBox(height: 24.r),
            Center(
              child: _ProfileAvatarPicker(
                picked: _avatarPicked,
                isDark: isDark,
                size: 110.r,
                onTap: () => setState(() => _avatarPicked = true),
              ),
            ),
            SizedBox(height: 28.r),
            _SectionHeaderDesktop(label: 'section_personal_info'.tr(), isDark: isDark),
            SizedBox(height: 14.r),
            _InputFieldDesktop(
              controller: _nameController,
              hint: 'enter_name'.tr(),
              label: 'full_name'.tr(),
              icon: Icons.person_outline,
              isDark: isDark,
            ),
            SizedBox(height: 16.r),
            _InputFieldDesktop(
              controller: _emailController,
              hint: 'enter_email'.tr(),
              label: 'email'.tr(),
              icon: Icons.email_outlined,
              isDark: isDark,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.r),
            // Date of Birth
            GestureDetector(
              onTap: () => _pickDateOfBirth(context),
              child: AbsorbPointer(
                child: _InputFieldDesktop(
                  controller: _dobController,
                  hint: 'DD/MM/YYYY',
                  label: 'date_of_birth'.tr(),
                  icon: Icons.calendar_today_outlined,
                  isDark: isDark,
                ),
              ),
            ),
            SizedBox(height: 16.r),
            // Country Selector
            CountrySelectorField(
              selectedCountry: _selectedCountry,
              onCountrySelected: (country) {
                setState(() {
                  _selectedCountry = country;
                  _validateForm();
                });
              },
              isDark: isDark,
              label: 'country'.tr(),
              icon: Icons.public_outlined,
            ),
            SizedBox(height: 16.r),
            // Gender Dropdown
            _DropdownField(
              value: _selectedGender,
              hint: 'select_gender'.tr(),
              label: 'gender'.tr(),
              icon: Icons.people_outline,
              isDark: isDark,
              items: _genders,
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                  _validateForm();
                });
              },
            ),
            if (widget.isDriver) ...[
              SizedBox(height: 28.r),
              _SectionHeaderDesktop(label: 'section_additional_info'.tr(), isDark: isDark),
              SizedBox(height: 14.r),
              _InputFieldDesktop(
                controller: _yearsExperienceController,
                hint: 'enter_years_experience'.tr(),
                label: 'years_driving_experience'.tr(),
                icon: Icons.timer_outlined,
                isDark: isDark,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.r),
              _MultiSelectField(
                values: _selectedLanguages,
                hint: 'select_languages'.tr(),
                label: 'languages_spoken'.tr(),
                icon: Icons.language_outlined,
                isDark: isDark,
                items: _languages,
                onChanged: (values) {
                  setState(() {
                    _selectedLanguages = values;
                    _validateForm();
                  });
                },
              ),
              SizedBox(height: 28.r),
              _SectionHeaderDesktop(label: 'section_license'.tr(), isDark: isDark),
              SizedBox(height: 14.r),
              _InputFieldDesktop(
                controller: _licenseNumberController,
                hint: 'enter_license_number'.tr(),
                label: 'license_number'.tr(),
                icon: Icons.badge_outlined,
                isDark: isDark,
              ),
              SizedBox(height: 16.r),
              GestureDetector(
                onTap: () => _pickLicenseExpiry(context),
                child: AbsorbPointer(
                  child: _InputFieldDesktop(
                    controller: _licenseExpiryController,
                    hint: 'DD/MM/YYYY',
                    label: 'license_expiry'.tr(),
                    icon: Icons.calendar_today_outlined,
                    isDark: isDark,
                  ),
                ),
              ),
              SizedBox(height: 16.r),
              _InputFieldDesktop(
                controller: _nationalIdController,
                hint: 'enter_national_id'.tr(),
                label: 'national_id'.tr(),
                icon: Icons.credit_card_outlined,
                isDark: isDark,
              ),
              SizedBox(height: 28.r),
              _SectionHeaderDesktop(label: 'section_documents'.tr(), isDark: isDark),
              SizedBox(height: 14.r),
              _DocumentPickerTileDesktop(
                label: 'civil_id_front'.tr(),
                subtitle: 'civil_id_front_hint'.tr(),
                icon: Icons.badge_outlined,
                fileName: _civilIdFrontFileName,
                isDark: isDark,
                onTap: () => setState(() => _civilIdFrontFileName = 'civil_id_front.pdf'),
              ),
              SizedBox(height: 12.r),
              _DocumentPickerTileDesktop(
                label: 'civil_id_back'.tr(),
                subtitle: 'civil_id_back_hint'.tr(),
                icon: Icons.badge_outlined,
                fileName: _civilIdBackFileName,
                isDark: isDark,
                onTap: () => setState(() => _civilIdBackFileName = 'civil_id_back.pdf'),
              ),
              SizedBox(height: 12.r),
              _DocumentPickerTileDesktop(
                label: 'medical_certificate'.tr(),
                subtitle: 'medical_certificate_hint'.tr(),
                icon: Icons.medical_services_outlined,
                fileName: _medicalCertificateFileName,
                isDark: isDark,
                onTap: () => setState(() => _medicalCertificateFileName = 'medical_certificate.pdf'),
              ),
              SizedBox(height: 12.r),
              _DocumentPickerTileDesktop(
                label: 'driving_license'.tr(),
                subtitle: 'driving_license_hint'.tr(),
                icon: Icons.contact_mail_outlined,
                fileName: _drivingLicenseFileName,
                isDark: isDark,
                onTap: () => setState(() => _drivingLicenseFileName = 'driving_license.pdf'),
              ),
            ],
            SizedBox(height: 36.r),
            _SubmitButtonDesktop(
              label: widget.isDriver ? 'submit_for_approval'.tr() : 'get_started'.tr(),
              enabled: _isButtonEnabled,
              onTap: () => _onComplete(),
            ),
            SizedBox(height: 40.r),
          ],
        ),
      ),
    );

    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        padding: EdgeInsets.symmetric(horizontal: 80.r),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: isRtl
              ? [formColumn, SizedBox(width: 60.r), brandingColumn]
              : [brandingColumn, SizedBox(width: 60.r), formColumn],
        ),
      ),
    );
  }
}

// ─── Shared helper widgets ───────────────────────────────────────────────────

class _ProfileAvatarPicker extends StatelessWidget {
  final bool picked;
  final bool isDark;
  final double size;
  final VoidCallback onTap;

  const _ProfileAvatarPicker({required this.picked, required this.isDark, required this.size, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              // Outer glow ring
              Container(
                width: size + 8.r,
                height: size + 8.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [secondaryColor.withOpacity(0.6), const Color(0xFF0C2485).withOpacity(0.4)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.all(3.r),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                    ),
                    child: picked
                        ? ClipOval(
                            child: Container(
                              color: secondaryColor.withOpacity(0.12),
                              child: Icon(Icons.person, size: size * 0.55, color: secondaryColor),
                            ),
                          )
                        : ClipOval(
                            child: Container(
                              color: isDark ? const Color(0xFF2A2A2A) : const Color(0xFFF0F2FF),
                              child: Icon(
                                Icons.person_outline,
                                size: size * 0.5,
                                color: isDark ? Colors.white38 : const Color(0xFFB0BAE8),
                              ),
                            ),
                          ),
                  ),
                ),
              ),

              // Camera badge
              Container(
                width: size * 0.32,
                height: size * 0.32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4D63DD), Color(0xFF677EF0)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  border: Border.all(color: isDark ? const Color(0xFF1E1E1E) : Colors.white, width: 2.r),
                  boxShadow: [
                    BoxShadow(color: secondaryColor.withOpacity(0.35), blurRadius: 8.r, offset: const Offset(0, 2)),
                  ],
                ),
                child: Icon(
                  picked ? Icons.edit_outlined : Icons.camera_alt_outlined,
                  color: Colors.white,
                  size: size * 0.16,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 10.r),
        Text(
          picked ? 'photo_added'.tr() : 'tap_to_add_photo'.tr(),
          style: TextStyle(
            fontSize: 12.r,
            color: picked ? secondaryColor : (isDark ? Colors.white38 : const Color(0xFF9E9E9E)),
            fontWeight: picked ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionHeader({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3.r,
          height: 18.r,
          decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(2.r)),
        ),
        SizedBox(width: 8.r),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.r,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF3D3D3D),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _SectionHeaderDesktop extends StatelessWidget {
  final String label;
  final bool isDark;
  const _SectionHeaderDesktop({required this.label, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 3.r,
          height: 20.r,
          decoration: BoxDecoration(color: secondaryColor, borderRadius: BorderRadius.circular(2.r)),
        ),
        SizedBox(width: 10.r),
        Text(
          label,
          style: TextStyle(
            fontSize: 15.r,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : const Color(0xFF3D3D3D),
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

class _InputField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String label;
  final IconData icon;
  final bool isDark;
  final TextInputType keyboardType;

  const _InputField({
    required this.controller,
    required this.hint,
    required this.label,
    required this.icon,
    required this.isDark,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.r,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF555555),
          ),
        ),
        SizedBox(height: 8.r),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 15.r,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF3D3D3D),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontSize: 14.r, color: isDark ? Colors.white38 : const Color(0xFF9E9E9E)),
              prefixIcon: Icon(icon, color: isDark ? Colors.white38 : const Color(0xFF9E9E9E), size: 20.r),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 16.r),
            ),
          ),
        ),
      ],
    );
  }
}

class _InputFieldDesktop extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final String label;
  final IconData icon;
  final bool isDark;
  final TextInputType keyboardType;

  const _InputFieldDesktop({
    required this.controller,
    required this.hint,
    required this.label,
    required this.icon,
    required this.isDark,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.r,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF555555),
          ),
        ),
        SizedBox(height: 10.r),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 16.r,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white : const Color(0xFF3D3D3D),
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(fontSize: 15.r, color: isDark ? Colors.white38 : const Color(0xFF9E9E9E)),
              prefixIcon: Icon(icon, color: isDark ? Colors.white38 : const Color(0xFF9E9E9E), size: 22.r),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 18.r),
            ),
          ),
        ),
      ],
    );
  }
}

class _DocumentPickerTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final String? fileName;
  final bool isDark;
  final VoidCallback onTap;

  const _DocumentPickerTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.fileName,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: hasFile ? secondaryColor.withOpacity(0.5) : (isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
            width: hasFile ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40.r,
              height: 40.r,
              decoration: BoxDecoration(
                color: hasFile ? secondaryColor.withOpacity(0.12) : (isDark ? Colors.white12 : Colors.white),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                hasFile ? Icons.check_circle_outline : icon,
                color: hasFile ? secondaryColor : (isDark ? Colors.white54 : const Color(0xFF9E9E9E)),
                size: 22.r,
              ),
            ),
            SizedBox(width: 12.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14.r,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                    ),
                  ),
                  SizedBox(height: 2.r),
                  Text(
                    hasFile ? fileName! : subtitle,
                    style: TextStyle(
                      fontSize: 12.r,
                      color: hasFile ? secondaryColor : (isDark ? Colors.white38 : const Color(0xFF9E9E9E)),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              hasFile ? Icons.edit_outlined : Icons.upload_file_outlined,
              color: isDark ? Colors.white38 : const Color(0xFF9E9E9E),
              size: 18.r,
            ),
          ],
        ),
      ),
    );
  }
}

class _DocumentPickerTileDesktop extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final String? fileName;
  final bool isDark;
  final VoidCallback onTap;

  const _DocumentPickerTileDesktop({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.fileName,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasFile = fileName != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: hasFile ? secondaryColor.withOpacity(0.5) : (isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
            width: hasFile ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: hasFile ? secondaryColor.withOpacity(0.12) : (isDark ? Colors.white12 : Colors.white),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                hasFile ? Icons.check_circle_outline : icon,
                color: hasFile ? secondaryColor : (isDark ? Colors.white54 : const Color(0xFF9E9E9E)),
                size: 24.r,
              ),
            ),
            SizedBox(width: 14.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 15.r,
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : const Color(0xFF3D3D3D),
                    ),
                  ),
                  SizedBox(height: 3.r),
                  Text(
                    hasFile ? fileName! : subtitle,
                    style: TextStyle(
                      fontSize: 13.r,
                      color: hasFile ? secondaryColor : (isDark ? Colors.white38 : const Color(0xFF9E9E9E)),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              hasFile ? Icons.edit_outlined : Icons.upload_file_outlined,
              color: isDark ? Colors.white38 : const Color(0xFF9E9E9E),
              size: 20.r,
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _SubmitButton({required this.label, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 56.r,
      decoration: BoxDecoration(
        gradient: enabled
            ? const LinearGradient(
                colors: [Color(0xFF4D63DD), Color(0xFF677EF0)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: enabled ? null : Colors.grey[300],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16.r),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 17.r,
                fontWeight: FontWeight.w600,
                color: enabled ? Colors.white : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SubmitButtonDesktop extends StatelessWidget {
  final String label;
  final bool enabled;
  final VoidCallback onTap;

  const _SubmitButtonDesktop({required this.label, required this.enabled, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 60.r,
      decoration: BoxDecoration(
        gradient: enabled
            ? const LinearGradient(
                colors: [Color(0xFF4D63DD), Color(0xFF677EF0)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              )
            : null,
        color: enabled ? null : Colors.grey[300],
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(16.r),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 18.r,
                fontWeight: FontWeight.w600,
                color: enabled ? Colors.white : Colors.grey[600],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final String? value;
  final String hint;
  final String label;
  final IconData icon;
  final bool isDark;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.value,
    required this.hint,
    required this.label,
    required this.icon,
    required this.isDark,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.r,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF555555),
          ),
        ),
        SizedBox(height: 8.r),
        GestureDetector(
          onTap: () {
            DropdownBottomSheet.show(
              context: context,
              selectedValue: value,
              items: items,
              title: label,
              onSelected: onChanged,
            );
          },
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 16.r),
            child: Row(
              children: [
                Icon(icon, color: isDark ? Colors.white38 : const Color(0xFF9E9E9E), size: 20.r),
                SizedBox(width: 12.r),
                Expanded(
                  child: Text(
                    value ?? hint,
                    style: TextStyle(
                      fontSize: 15.r,
                      fontWeight: FontWeight.w500,
                      color: value == null
                          ? (isDark ? Colors.white38 : const Color(0xFF9E9E9E))
                          : (isDark ? Colors.white : const Color(0xFF3D3D3D)),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: isDark ? Colors.white54 : const Color(0xFF9E9E9E)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MultiSelectField extends StatelessWidget {
  final List<String> values;
  final String hint;
  final String label;
  final IconData icon;
  final bool isDark;
  final List<String> items;
  final ValueChanged<List<String>> onChanged;

  const _MultiSelectField({
    required this.values,
    required this.hint,
    required this.label,
    required this.icon,
    required this.isDark,
    required this.items,
    required this.onChanged,
  });

  void _showMultiSelectBottomSheet(BuildContext context) {
    MultiSelectBottomSheet.show(
      context: context,
      selectedValues: values,
      items: items,
      title: label,
      onSelectionChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayText = values.isEmpty ? hint : values.join(', ');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.r,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF555555),
          ),
        ),
        SizedBox(height: 8.r),
        GestureDetector(
          onTap: () => _showMultiSelectBottomSheet(context),
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 16.r),
            child: Row(
              children: [
                Icon(icon, color: isDark ? Colors.white38 : const Color(0xFF9E9E9E), size: 20.r),
                SizedBox(width: 12.r),
                Expanded(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      fontSize: 15.r,
                      fontWeight: FontWeight.w500,
                      color: values.isEmpty
                          ? (isDark ? Colors.white38 : const Color(0xFF9E9E9E))
                          : (isDark ? Colors.white : const Color(0xFF3D3D3D)),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: isDark ? Colors.white54 : const Color(0xFF9E9E9E)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
