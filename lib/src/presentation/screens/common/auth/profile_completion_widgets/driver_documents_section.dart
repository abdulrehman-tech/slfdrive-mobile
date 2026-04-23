import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../profile_completion_provider/profile_completion_provider.dart';
import 'document_picker_tile.dart';
import 'section_header.dart';

/// Driver document uploads (civil ID front/back, medical cert, driving license).
class DriverDocumentsSection extends StatelessWidget {
  final bool isDark;
  final bool desktop;

  const DriverDocumentsSection({super.key, required this.isDark, this.desktop = false});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ProfileCompletionProvider>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        desktop
            ? SectionHeaderDesktop(label: 'section_documents'.tr(), isDark: isDark)
            : SectionHeader(label: 'section_documents'.tr(), isDark: isDark),
        SizedBox(height: 14.r),
        _tile(
          label: 'civil_id_front'.tr(),
          subtitle: 'civil_id_front_hint'.tr(),
          icon: Icons.badge_outlined,
          fileName: provider.civilIdFrontFileName,
          onTap: () => provider.setCivilIdFront('civil_id_front.pdf'),
        ),
        SizedBox(height: 12.r),
        _tile(
          label: 'civil_id_back'.tr(),
          subtitle: 'civil_id_back_hint'.tr(),
          icon: Icons.badge_outlined,
          fileName: provider.civilIdBackFileName,
          onTap: () => provider.setCivilIdBack('civil_id_back.pdf'),
        ),
        SizedBox(height: 12.r),
        _tile(
          label: 'medical_certificate'.tr(),
          subtitle: 'medical_certificate_hint'.tr(),
          icon: Icons.medical_services_outlined,
          fileName: provider.medicalCertificateFileName,
          onTap: () => provider.setMedicalCertificate('medical_certificate.pdf'),
        ),
        SizedBox(height: 12.r),
        _tile(
          label: 'driving_license'.tr(),
          subtitle: 'driving_license_hint'.tr(),
          icon: Icons.contact_mail_outlined,
          fileName: provider.drivingLicenseFileName,
          onTap: () => provider.setDrivingLicense('driving_license.pdf'),
        ),
      ],
    );
  }

  Widget _tile({
    required String label,
    required String subtitle,
    required IconData icon,
    required String? fileName,
    required VoidCallback onTap,
  }) {
    if (desktop) {
      return DocumentPickerTileDesktop(
        label: label,
        subtitle: subtitle,
        icon: icon,
        fileName: fileName,
        isDark: isDark,
        onTap: onTap,
      );
    }
    return DocumentPickerTile(
      label: label,
      subtitle: subtitle,
      icon: icon,
      fileName: fileName,
      isDark: isDark,
      onTap: onTap,
    );
  }
}
