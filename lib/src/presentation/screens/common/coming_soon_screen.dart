import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../constants/color_constants.dart';
import '../../providers/theme_provider.dart';

class ComingSoonScreen extends StatelessWidget {
  final String? titleKey;

  const ComingSoonScreen({super.key, this.titleKey});

  @override
  Widget build(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    final isDark =
        tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);

    final title = titleKey != null ? titleKey!.tr() : 'coming_soon_title'.tr();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left_2),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 32.r),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120.r,
                height: 120.r,
                decoration: BoxDecoration(
                  gradient: isDark ? darkGradient : lightPrimaryGradient,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Iconsax.clock,
                  size: 56.r,
                  color: isDark ? whiteColor : primaryColor,
                ),
              ),
              SizedBox(height: 28.r),
              Text(
                'coming_soon_heading'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: isDark ? whiteColor : primaryColorDark,
                ),
              ),
              SizedBox(height: 12.r),
              Text(
                'coming_soon_message'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15.sp,
                  height: 1.5,
                  color: isDark ? whiteColor.withValues(alpha: 0.7) : darkGrayColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
