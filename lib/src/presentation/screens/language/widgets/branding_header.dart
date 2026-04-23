import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../constants/icon_constants.dart';

class BrandingHeader extends StatelessWidget {
  final bool isDesktop;

  const BrandingHeader({super.key, this.isDesktop = false});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final String logoAsset = isDark ? IconConstants.logoWhite : IconConstants.logo;

    if (isDesktop) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(logoAsset, width: 200.r, height: 200.r),
          SizedBox(height: 40.r),
          Text(
            'choose_language'.tr(),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF3D3D3D),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'choose_language_subtitle'.tr(),
            style: TextStyle(
              fontSize: 18,
              color: isDark ? Colors.white70 : const Color(0xFF757575),
              height: 1.5,
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        SvgPicture.asset(logoAsset, width: 140.r, height: 120.r),
        SizedBox(height: 32.r),
        Text(
          'choose_language'.tr(),
          style: TextStyle(
            fontSize: 24.r,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF3D3D3D),
          ),
        ),
        SizedBox(height: 8.r),
        Text(
          'choose_language_subtitle'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.r,
            color: isDark ? Colors.white70 : const Color(0xFF757575),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
