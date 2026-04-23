import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'pre_login_background.dart';
import 'pre_login_footer_actions.dart';
import 'pre_login_logo.dart';
import 'pre_login_tagline.dart';
import 'role_cards_row.dart';

/// Mobile/tablet stacked layout: hero background, top-left logo, centered
/// tagline, role cards, then the skip/sign-in footer.
class PreLoginMobileLayout extends StatelessWidget {
  const PreLoginMobileLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const PreLoginBackground.mobile(),
        SafeArea(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 24.r),
                child: PreLoginLogo(size: 110.r),
              ),
              const Spacer(),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 28.r),
                child: PreLoginTagline(
                  titleSize: 36.r,
                  subtitleSize: 15.r,
                  titleHeight: 1.15,
                  titleLetterSpacing: -0.5,
                  spacing: 10.r,
                  titleAlign: TextAlign.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  subtitleColor: Colors.white70,
                ),
              ),
              SizedBox(height: 28.r),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.r),
                child: const RoleCardsRow(isDesktop: false),
              ),
              SizedBox(height: 24.r),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.r),
                child: PreLoginFooterActions.mobile(),
              ),
              SizedBox(height: 16.r),
            ],
          ),
        ),
      ],
    );
  }
}
