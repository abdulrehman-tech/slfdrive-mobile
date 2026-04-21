import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import '../../../../constants/icon_constants.dart';
import '../../../../constants/image_constants.dart';
import '../../../../constants/breakpoints.dart';
import '../../../providers/role_provider.dart';

/// "Skip & explore" grants a guest customer session so the role guard lets
/// the user into `/home` without completing OTP. Signed-up customers overwrite
/// this in the profile-completion step.
Future<void> _continueAsGuest(BuildContext context) async {
  await context.read<RoleProvider>().setRole(UserRole.customer);
  if (context.mounted) context.go('/home');
}

class PreLoginScreen extends StatelessWidget {
  const PreLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = Breakpoints.isDesktop(constraints.maxWidth);
          if (isDesktop) {
            return _buildDesktopLayout(context);
          }
          return _buildMobileLayout(context);
        },
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Hero background image
        Image.asset(ImageConstants.preloginGif, fit: BoxFit.cover),

        // Gradient overlay — lighter top, heavy dark bottom
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.45, 0.72, 1.0],
              colors: [Color(0x1A000000), Color(0x33000000), Color(0xCC000000), Color(0xFF000000)],
            ),
          ),
        ),

        // Content
        SafeArea(
          child: Column(
            children: [
              // Top logo
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 24.r),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: SvgPicture.asset(IconConstants.logoWhite, width: 110.r, height: 110.r, fit: BoxFit.contain),
                ),
              ),

              const Spacer(),

              // Tagline
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 28.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'pre_login_title'.tr(),
                      style: TextStyle(
                        fontSize: 36.r,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        height: 1.15,
                        letterSpacing: -0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10.r),
                    Text(
                      'pre_login_subtitle'.tr(),
                      style: TextStyle(fontSize: 15.r, color: Colors.white70, height: 1.5),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 28.r),

              // Role cards row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.r),
                child: Row(
                  children: [
                    Expanded(
                      child: _RoleCard(
                        icon: Icons.person_outline_rounded,
                        title: 'pre_login_passenger'.tr(),
                        subtitle: 'pre_login_passenger_desc'.tr(),
                        onTap: () => context.push('/auth/phone', extra: {'isDriver': false}),
                      ),
                    ),
                    SizedBox(width: 12.r),
                    Expanded(
                      child: _RoleCard(
                        icon: Icons.drive_eta_rounded,
                        title: 'become_driver'.tr(),
                        subtitle: 'pre_login_driver_desc'.tr(),
                        onTap: () => context.push('/auth/phone', extra: {'isDriver': true}),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.r),

              // Bottom skip / sign in row
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.r),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => _continueAsGuest(context),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 4.r, vertical: 8.r),
                      ),
                      child: Text(
                        'skip'.tr(),
                        style: TextStyle(
                          fontSize: 15.r,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white70,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/auth/phone', extra: {'isDriver': false}),
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.symmetric(horizontal: 4.r, vertical: 8.r),
                      ),
                      child: Text(
                        'sign_in'.tr(),
                        style: TextStyle(
                          fontSize: 15.r,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          decoration: TextDecoration.underline,
                          decorationColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 16.r),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    final isRtl = Directionality.of(context) == ui.TextDirection.rtl;
    return Stack(
      fit: StackFit.expand,
      children: [
        // Hero background image
        Image.asset(ImageConstants.preloginGif, fit: BoxFit.cover),

        // Gradient overlay
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.0, 0.4, 0.7, 1.0],
              colors: [Color(0x1A000000), Color(0x4D000000), Color(0xCC000000), Color(0xFF000000)],
            ),
          ),
        ),

        // Content
        SafeArea(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 1100),
              padding: EdgeInsets.symmetric(horizontal: 60.r),
              child: Column(
                children: [
                  // Top logo
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.r),
                    child: Align(
                      alignment: AlignmentDirectional.topStart,
                      child: SvgPicture.asset(
                        IconConstants.logoWhite,
                        width: 140.r,
                        height: 140.r,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),

                  const Spacer(),

                  // Tagline
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'pre_login_title'.tr(),
                          style: TextStyle(
                            fontSize: 52.r,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.1,
                            letterSpacing: -1,
                          ),
                        ),
                        SizedBox(height: 12.r),
                        Text(
                          'pre_login_subtitle'.tr(),
                          style: TextStyle(fontSize: 18.r, color: Colors.white.withOpacity(0.75), height: 1.5),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40.r),

                  // Role cards row
                  Row(
                    children: [
                      Expanded(
                        child: _RoleCardDesktop(
                          icon: Icons.person_outline_rounded,
                          title: 'pre_login_passenger'.tr(),
                          subtitle: 'pre_login_passenger_desc'.tr(),
                          onTap: () => context.push('/auth/phone', extra: {'isDriver': false}),
                        ),
                      ),
                      SizedBox(width: 20.r),
                      Expanded(
                        child: _RoleCardDesktop(
                          icon: Icons.drive_eta_rounded,
                          title: 'become_driver'.tr(),
                          subtitle: 'pre_login_driver_desc'.tr(),
                          onTap: () => context.push('/auth/phone', extra: {'isDriver': true}),
                        ),
                      ),
                      // if (!isRtl) const Spacer(),
                    ],
                  ),

                  SizedBox(height: 32.r),

                  // Bottom skip / sign in row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () => _continueAsGuest(context),
                        child: Text(
                          'skip'.tr(),
                          style: TextStyle(
                            fontSize: 16.r,
                            fontWeight: FontWeight.w600,
                            color: Colors.white70,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white70,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/auth/phone', extra: {'isDriver': false}),
                        child: Text(
                          'sign_in'.tr(),
                          style: TextStyle(
                            fontSize: 16.r,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                            decoration: TextDecoration.underline,
                            decorationColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),

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

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCard({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.r),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.13),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.white.withOpacity(0.22), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48.r,
                  height: 48.r,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.white.withOpacity(0.25), width: 1),
                  ),
                  child: Icon(icon, color: Colors.white, size: 26.r),
                ),
                SizedBox(height: 14.r),
                Text(
                  title,
                  style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 6.r),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12.r, color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCardDesktop extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _RoleCardDesktop({required this.icon, required this.title, required this.subtitle, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18.r),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 14, sigmaY: 14),
          child: Container(
            padding: EdgeInsets.all(28.r),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22), width: 1.2),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 56.r,
                  height: 56.r,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14.r),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 1),
                  ),
                  child: Icon(icon, color: Colors.white, size: 30.r),
                ),
                SizedBox(height: 16.r),
                Text(
                  title,
                  style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                SizedBox(height: 8.r),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 14.r, color: Colors.white.withValues(alpha: 0.7), height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
