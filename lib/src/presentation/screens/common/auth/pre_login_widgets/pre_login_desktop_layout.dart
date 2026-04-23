import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'pre_login_background.dart';
import 'pre_login_footer_actions.dart';
import 'pre_login_logo.dart';
import 'pre_login_tagline.dart';
import 'role_cards_row.dart';

/// Desktop layout: same content as mobile but constrained to a 1100px column,
/// left-aligned tagline, larger type, and wider role cards.
class PreLoginDesktopLayout extends StatelessWidget {
  const PreLoginDesktopLayout({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const PreLoginBackground.desktop(),
        SafeArea(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1100),
              padding: EdgeInsets.symmetric(horizontal: 60.r),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.r),
                    child: PreLoginLogo(size: 140.r),
                  ),
                  const Spacer(),
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: PreLoginTagline(
                      titleSize: 52.r,
                      subtitleSize: 18.r,
                      titleHeight: 1.1,
                      titleLetterSpacing: -1,
                      spacing: 12.r,
                      titleAlign: TextAlign.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      subtitleColor: Colors.white.withValues(alpha: 0.75),
                    ),
                  ),
                  SizedBox(height: 40.r),
                  const RoleCardsRow(isDesktop: true),
                  SizedBox(height: 32.r),
                  PreLoginFooterActions.desktop(),
                  SizedBox(height: 24.r),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
