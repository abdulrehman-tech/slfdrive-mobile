import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/company/all_company.dart';
import '../../../../core/models/corporate/corporate_membership.dart';
import '../../../providers/theme_provider.dart';
import '../booking/provider/corporate_companies_provider.dart';
import '../booking/steps/corporate_widgets/corporate_company_picker.dart';
import 'provider/corporate_membership_provider.dart';

/// Form to apply for a corporate membership: pick a company (required) plus
/// optional employment details. On success pops `true`.
class CorporateMembershipApplyScreen extends StatelessWidget {
  const CorporateMembershipApplyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CorporateCompaniesProvider()),
        ChangeNotifierProvider(create: (_) => CorporateMembershipProvider()),
      ],
      child: const _ApplyView(),
    );
  }
}

class _ApplyView extends StatefulWidget {
  const _ApplyView();

  @override
  State<_ApplyView> createState() => _ApplyViewState();
}

class _ApplyViewState extends State<_ApplyView> {
  AllCompany? _company;
  final _employeeId = TextEditingController();
  final _designation = TextEditingController();
  final _department = TextEditingController();
  final _officeAddress = TextEditingController();
  final _officeNumber = TextEditingController();
  final _managerName = TextEditingController();
  bool _submitting = false;
  bool _autoValidate = false;
  String? _companyError;

  @override
  void dispose() {
    _employeeId.dispose();
    _designation.dispose();
    _department.dispose();
    _officeAddress.dispose();
    _officeNumber.dispose();
    _managerName.dispose();
    super.dispose();
  }

  bool _isDark(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode ||
        (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  Future<void> _pickCompany(BuildContext context, bool isDark) async {
    final companies = context.read<CorporateCompaniesProvider>();
    await companies.ensureLoaded();
    if (!context.mounted) return;
    final picked = await showCompanyPickerSheet(
      context,
      companies: companies.companies,
      isDark: isDark,
      selected: _company,
      isLoading: companies.isLoading,
      error: companies.error,
    );
    if (picked != null) {
      setState(() {
        _company = picked;
        _companyError = null;
      });
    }
  }

  /// All employment fields plus the company are required; the backend treats
  /// them as optional, so the gate lives here.
  bool _validate() {
    final companyOk = _company != null;
    final fieldsOk = [
      _employeeId,
      _designation,
      _department,
      _managerName,
      _officeNumber,
      _officeAddress,
    ].every((c) => c.text.trim().isNotEmpty);
    setState(() {
      _autoValidate = true;
      _companyError = companyOk ? null : 'corporate_apply_company_required'.tr();
    });
    return companyOk && fieldsOk;
  }

  Future<void> _submit(BuildContext context) async {
    if (!_validate()) return;
    setState(() => _submitting = true);
    final provider = context.read<CorporateMembershipProvider>();
    final ok = await provider.apply(CorporateMembershipRequest(
      allCompanyId: _company!.id,
      employeeId: _employeeId.text,
      designation: _designation.text,
      department: _department.text,
      officeAddress: _officeAddress.text,
      officeNumber: _officeNumber.text,
      managerName: _managerName.text,
    ));
    if (!context.mounted) return;
    setState(() => _submitting = false);
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('corporate_apply_success'.tr())),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.error ?? 'corporate_apply_failed'.tr())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('corporate_apply_title'.tr()),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 32.r),
        children: [
          Text(
            'corporate_apply_subtitle'.tr(),
            style: TextStyle(fontSize: 13.r, color: cs.onSurface.withValues(alpha: 0.55)),
          ),
          SizedBox(height: 18.r),
          _label('corporate_apply_company'.tr(), cs, required: true),
          SizedBox(height: 8.r),
          _CompanyField(
            company: _company,
            isDark: isDark,
            onTap: () => _pickCompany(context, isDark),
          ),
          if (_companyError != null)
            Padding(
              padding: EdgeInsets.only(top: 6.r),
              child: Text(_companyError!, style: TextStyle(fontSize: 12.r, color: cs.error)),
            ),
          SizedBox(height: 18.r),
          _field('corporate_apply_employee_id'.tr(), _employeeId, cs, isDark),
          _field('corporate_apply_designation'.tr(), _designation, cs, isDark),
          _field('corporate_apply_department'.tr(), _department, cs, isDark),
          _field('corporate_apply_manager'.tr(), _managerName, cs, isDark),
          _field('corporate_apply_office_number'.tr(), _officeNumber, cs, isDark,
              keyboard: TextInputType.phone),
          _field('corporate_apply_office_address'.tr(), _officeAddress, cs, isDark, maxLines: 2),
          // ^ every field above is required; see _field's inline error.
          SizedBox(height: 24.r),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _submitting ? null : () => _submit(context),
              child: _submitting
                  ? SizedBox(
                      height: 18.r,
                      width: 18.r,
                      child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text('corporate_apply_submit'.tr()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text, ColorScheme cs, {bool required = false}) {
    return Row(
      children: [
        Text(text, style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface)),
        if (required) Text(' *', style: TextStyle(fontSize: 13.r, color: cs.error)),
      ],
    );
  }

  Widget _field(
    String label,
    TextEditingController controller,
    ColorScheme cs,
    bool isDark, {
    TextInputType? keyboard,
    int maxLines = 1,
  }) {
    final showError = _autoValidate && controller.text.trim().isEmpty;
    final errorColor = cs.error;
    return Padding(
      padding: EdgeInsets.only(bottom: 14.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label(label, cs, required: true),
          SizedBox(height: 8.r),
          TextField(
            controller: controller,
            keyboardType: keyboard,
            maxLines: maxLines,
            onChanged: (_) {
              if (_autoValidate) setState(() {});
            },
            style: TextStyle(fontSize: 14.r, color: cs.onSurface),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
              contentPadding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 12.r),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: showError ? BorderSide(color: errorColor) : BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide(color: showError ? errorColor : const Color(0xFF4D63DD)),
              ),
            ),
          ),
          if (showError)
            Padding(
              padding: EdgeInsets.only(top: 6.r),
              child: Text(
                'corporate_apply_field_required'.tr(),
                style: TextStyle(fontSize: 12.r, color: errorColor),
              ),
            ),
        ],
      ),
    );
  }
}

class _CompanyField extends StatelessWidget {
  final AllCompany? company;
  final bool isDark;
  final VoidCallback onTap;
  const _CompanyField({required this.company, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
          ),
        ),
        child: Row(
          children: [
            Icon(Iconsax.buildings_copy, size: 20.r, color: const Color(0xFF4D63DD)),
            SizedBox(width: 12.r),
            Expanded(
              child: Text(
                company != null ? company!.displayName() : 'corporate_apply_select_company'.tr(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14.r,
                  fontWeight: FontWeight.w600,
                  color: company != null ? cs.onSurface : cs.onSurface.withValues(alpha: 0.5),
                ),
              ),
            ),
            Icon(Iconsax.arrow_right_3_copy, size: 18.r, color: cs.onSurface.withValues(alpha: 0.4)),
          ],
        ),
      ),
    );
  }
}
