import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/breakpoints.dart';
import '../../../../../constants/color_constants.dart';
import '../../../../providers/theme_provider.dart';
import '../../../common/auth/profile_completion_widgets/input_field.dart';
import '../../../common/auth/profile_completion_widgets/section_header.dart';
import '../../../common/auth/profile_completion_widgets/submit_button.dart';
import 'models/organization.dart';
import 'provider/corporate_provider.dart';
import 'widgets/organization_logo.dart';
import 'widgets/organization_picker_sheet.dart';

class CorporateMembershipApplyScreen extends StatefulWidget {
  const CorporateMembershipApplyScreen({super.key});

  @override
  State<CorporateMembershipApplyScreen> createState() => _CorporateMembershipApplyScreenState();
}

class _CorporateMembershipApplyScreenState extends State<CorporateMembershipApplyScreen> {
  final _employeeId = TextEditingController();
  final _position = TextEditingController();
  final _department = TextEditingController();
  final _workEmail = TextEditingController();
  final _manager = TextEditingController();

  Organization? _organization;
  DateTime? _joinDate;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    for (final c in [_employeeId, _position, _department, _workEmail, _manager]) {
      c.addListener(_onAnyChange);
    }
  }

  void _onAnyChange() => setState(() {});

  @override
  void dispose() {
    _employeeId.dispose();
    _position.dispose();
    _department.dispose();
    _workEmail.dispose();
    _manager.dispose();
    super.dispose();
  }

  bool get _canSubmit =>
      _organization != null &&
      _employeeId.text.trim().isNotEmpty &&
      _position.text.trim().isNotEmpty &&
      _department.text.trim().isNotEmpty &&
      _workEmail.text.trim().isNotEmpty &&
      _joinDate != null &&
      _manager.text.trim().isNotEmpty;

  Future<void> _pickOrganization(bool isDark) async {
    final corporate = context.read<CorporateProvider>();
    final picked = await showOrganizationPickerSheet(
      context,
      organizations: corporate.organizations,
      isDark: isDark,
      selected: _organization,
    );
    if (picked != null) setState(() => _organization = picked);
  }

  Future<void> _pickJoinDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _joinDate ?? now,
      firstDate: DateTime(now.year - 50),
      lastDate: now,
    );
    if (picked != null) setState(() => _joinDate = picked);
  }

  Future<void> _submit() async {
    if (!_canSubmit) return;
    setState(() => _submitting = true);
    final corporate = context.read<CorporateProvider>();
    await corporate.submitApplication(
      organizationId: _organization!.id,
      employeeId: _employeeId.text.trim(),
      position: _position.text.trim(),
      department: _department.text.trim(),
      workEmail: _workEmail.text.trim(),
      joinDate: _joinDate!,
      managerName: _manager.text.trim(),
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('corporate_apply_submitted'.tr()),
        behavior: SnackBarBehavior.floating,
      ),
    );
    Navigator.of(context).pop();
  }

  bool _isDark(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = Breakpoints.isDesktop(constraints.maxWidth);
            final isTablet = Breakpoints.isTablet(constraints.maxWidth);
            final maxWidth = isDesktop ? 720.0 : (isTablet ? 640.0 : double.infinity);
            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxWidth),
                child: Column(
                  children: [
                    _TopBar(isDark: isDark),
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(24.r, 8.r, 24.r, 28.r),
                        child: _Form(state: this, isDark: isDark),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final bool isDark;
  const _TopBar({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 8.r),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.of(context).maybePop(),
            icon: Icon(
              CupertinoIcons.back,
              color: isDark ? Colors.white : const Color(0xFF3D3D3D),
              size: 20.r,
            ),
          ),
        ],
      ),
    );
  }
}

class _Form extends StatelessWidget {
  final _CorporateMembershipApplyScreenState state;
  final bool isDark;
  const _Form({required this.state, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Hero(isDark: isDark),
        SizedBox(height: 24.r),
        SectionHeader(label: 'corporate_apply_section_org'.tr(), isDark: isDark),
        SizedBox(height: 14.r),
        _OrgPickerField(
          organization: state._organization,
          isDark: isDark,
          onTap: () => state._pickOrganization(isDark),
        ),
        SizedBox(height: 28.r),
        SectionHeader(label: 'corporate_apply_section_employment'.tr(), isDark: isDark),
        SizedBox(height: 14.r),
        InputField(
          controller: state._employeeId,
          label: 'corporate_field_employee_id'.tr(),
          hint: 'corporate_field_employee_id_hint'.tr(),
          icon: Iconsax.personalcard_copy,
          isDark: isDark,
        ),
        SizedBox(height: 16.r),
        InputField(
          controller: state._position,
          label: 'corporate_field_position'.tr(),
          hint: 'corporate_field_position_hint'.tr(),
          icon: Iconsax.briefcase_copy,
          isDark: isDark,
        ),
        SizedBox(height: 16.r),
        InputField(
          controller: state._department,
          label: 'corporate_field_department'.tr(),
          hint: 'corporate_field_department_hint'.tr(),
          icon: Iconsax.category_2_copy,
          isDark: isDark,
        ),
        SizedBox(height: 16.r),
        InputField(
          controller: state._workEmail,
          label: 'corporate_field_work_email'.tr(),
          hint: 'corporate_field_work_email_hint'.tr(),
          icon: Iconsax.sms_copy,
          isDark: isDark,
          keyboardType: TextInputType.emailAddress,
        ),
        SizedBox(height: 16.r),
        _DateField(
          date: state._joinDate,
          isDark: isDark,
          onTap: state._pickJoinDate,
        ),
        SizedBox(height: 16.r),
        InputField(
          controller: state._manager,
          label: 'corporate_field_manager'.tr(),
          hint: 'corporate_field_manager_hint'.tr(),
          icon: Iconsax.user_copy,
          isDark: isDark,
        ),
        SizedBox(height: 28.r),
        SubmitButton(
          label: state._submitting ? '...' : 'submit_for_approval'.tr(),
          enabled: state._canSubmit && !state._submitting,
          onTap: state._submit,
        ),
        SizedBox(height: 12.r),
        Center(
          child: Text(
            'corporate_apply_disclaimer'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.r,
              color: isDark ? Colors.white54 : const Color(0xFF9E9E9E),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}

class _Hero extends StatelessWidget {
  final bool isDark;
  const _Hero({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryColor, secondaryColor],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 18.r,
            offset: Offset(0, 8.r),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52.r,
            height: 52.r,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(Iconsax.briefcase_copy, color: Colors.white, size: 24.r),
          ),
          SizedBox(width: 14.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'corporate_apply_title'.tr(),
                  style: TextStyle(
                    fontSize: 18.r,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 4.r),
                Text(
                  'corporate_apply_subtitle'.tr(),
                  style: TextStyle(
                    fontSize: 12.r,
                    color: Colors.white.withValues(alpha: 0.85),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OrgPickerField extends StatelessWidget {
  final Organization? organization;
  final bool isDark;
  final VoidCallback onTap;
  const _OrgPickerField({required this.organization, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasOrg = organization != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'corporate_field_organization'.tr(),
          style: TextStyle(
            fontSize: 13.r,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF555555),
          ),
        ),
        SizedBox(height: 8.r),
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: hasOrg
                    ? organization!.accentColor.withValues(alpha: 0.4)
                    : (isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
                width: hasOrg ? 1.5 : 1,
              ),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 12.r),
            child: Row(
              children: [
                if (hasOrg)
                  OrganizationLogo(organization: organization!, size: 36.r, isDark: isDark)
                else
                  Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: secondaryColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Icon(Iconsax.buildings_copy, size: 18.r, color: secondaryColor),
                  ),
                SizedBox(width: 12.r),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        hasOrg ? organization!.name : 'corporate_select_organization'.tr(),
                        style: TextStyle(
                          fontSize: 15.r,
                          fontWeight: hasOrg ? FontWeight.w700 : FontWeight.w500,
                          color: hasOrg
                              ? (isDark ? Colors.white : const Color(0xFF3D3D3D))
                              : (isDark ? Colors.white38 : const Color(0xFF9E9E9E)),
                        ),
                      ),
                      if (hasOrg) ...[
                        SizedBox(height: 2.r),
                        Text(
                          organization!.industry,
                          style: TextStyle(
                            fontSize: 11.r,
                            color: isDark ? Colors.white54 : const Color(0xFF9E9E9E),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 22.r,
                  color: isDark ? Colors.white54 : const Color(0xFF9E9E9E),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DateField extends StatelessWidget {
  final DateTime? date;
  final bool isDark;
  final VoidCallback onTap;
  const _DateField({required this.date, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final formatted = date == null
        ? 'corporate_field_join_date_hint'.tr()
        : '${date!.year}-${date!.month.toString().padLeft(2, '0')}-${date!.day.toString().padLeft(2, '0')}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'corporate_field_join_date'.tr(),
          style: TextStyle(
            fontSize: 13.r,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white70 : const Color(0xFF555555),
          ),
        ),
        SizedBox(height: 8.r),
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: isDark ? Colors.white12 : const Color(0xFFE0E0E0)),
            ),
            padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 16.r),
            child: Row(
              children: [
                Icon(
                  Iconsax.calendar_2_copy,
                  size: 20.r,
                  color: isDark ? Colors.white38 : const Color(0xFF9E9E9E),
                ),
                SizedBox(width: 12.r),
                Expanded(
                  child: Text(
                    formatted,
                    style: TextStyle(
                      fontSize: 15.r,
                      fontWeight: date != null ? FontWeight.w700 : FontWeight.w500,
                      color: date != null
                          ? (isDark ? Colors.white : const Color(0xFF3D3D3D))
                          : (isDark ? Colors.white38 : const Color(0xFF9E9E9E)),
                    ),
                  ),
                ),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 22.r,
                  color: isDark ? Colors.white54 : const Color(0xFF9E9E9E),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
