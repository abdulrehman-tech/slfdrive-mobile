import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import 'logout_dialog.dart';

class SignOutButton extends StatelessWidget {
  final bool isDark;
  const SignOutButton({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showProfileLogoutDialog(context, isDark: isDark),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.r),
        decoration: BoxDecoration(
          color: const Color(0xFFE53935).withValues(alpha: isDark ? 0.18 : 0.1),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE53935).withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.logout_copy, size: 17.r, color: const Color(0xFFE53935)),
            SizedBox(width: 8.r),
            Text(
              'profile_sign_out'.tr(),
              style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w800, color: const Color(0xFFE53935)),
            ),
          ],
        ),
      ),
    );
  }
}
