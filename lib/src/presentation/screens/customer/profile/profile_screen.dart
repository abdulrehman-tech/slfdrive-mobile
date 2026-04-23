import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../constants/breakpoints.dart';
import '../../../providers/theme_provider.dart';
import 'provider/profile_provider.dart';
import 'widgets/account_section.dart';
import 'widgets/glass_header_overlay.dart';
import 'widgets/my_data_section.dart';
import 'widgets/preferences_section.dart';
import 'widgets/profile_header_card.dart';
import 'widgets/sign_out_button.dart';
import 'widgets/support_section.dart';

// ============================================================
// PROFILE — simplified
//
// Pragmatic sections only:
//   Sliver glass header (name + tier)
//   Account
//   Preferences
//   My data  (addresses / cards / docs as navigation tiles)
//   Support
//   Sign out
// ============================================================

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ProfileProvider(),
      child: const _ProfileView(),
    );
  }
}

class _ProfileView extends StatelessWidget {
  const _ProfileView();

  bool _isDark(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(MediaQuery.of(context).size.width);
    final isDark = _isDark(context);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: isDesktop ? _buildDesktop(context, isDark) : _buildMobile(context, isDark),
    );
  }

  Widget _buildMobile(BuildContext context, bool isDark) {
    final cs = Theme.of(context).colorScheme;
    final topPad = MediaQuery.of(context).padding.top;
    final scroll = context.read<ProfileProvider>().scroll;

    return Stack(
      children: [
        CustomScrollView(
          controller: scroll,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16.r, topPad + 12.r, 16.r, 0),
                child: ProfileHeaderCard(isDark: isDark),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 100.r),
              sliver: SliverList.list(
                children: [
                  AccountSection(isDark: isDark),
                  SizedBox(height: 16.r),
                  PreferencesSection(isDark: isDark),
                  SizedBox(height: 16.r),
                  MyDataSection(isDark: isDark),
                  SizedBox(height: 16.r),
                  SupportSection(isDark: isDark),
                  SizedBox(height: 16.r),
                  SignOutButton(isDark: isDark),
                  SizedBox(height: 20.r),
                  Center(
                    child: Text(
                      'profile_version'.tr(),
                      style: TextStyle(
                        fontSize: 11.r,
                        color: cs.onSurface.withValues(alpha: 0.35),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: GlassHeaderOverlay(isDark: isDark),
        ),
      ],
    );
  }

  Widget _buildDesktop(BuildContext context, bool isDark) {
    final cs = Theme.of(context).colorScheme;
    final scroll = context.read<ProfileProvider>().scroll;

    return SingleChildScrollView(
      controller: scroll,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 40.r, vertical: 28.r),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 960.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'profile_screen_title'.tr(),
                style: TextStyle(fontSize: 24.r, fontWeight: FontWeight.bold, color: cs.onSurface),
              ),
              SizedBox(height: 20.r),
              ProfileHeaderCard(isDark: isDark),
              SizedBox(height: 20.r),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        AccountSection(isDark: isDark),
                        SizedBox(height: 16.r),
                        MyDataSection(isDark: isDark),
                        SizedBox(height: 16.r),
                        SupportSection(isDark: isDark),
                      ],
                    ),
                  ),
                  SizedBox(width: 20.r),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        PreferencesSection(isDark: isDark),
                        SizedBox(height: 16.r),
                        SignOutButton(isDark: isDark),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
