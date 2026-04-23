import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../../../constants/breakpoints.dart';
import '../../../providers/theme_provider.dart';
import '../booking/models/booking_data.dart';
import 'models/driver_profile.dart';
import 'provider/driver_detail_provider.dart';
import 'widgets/about_card.dart';
import 'widgets/availability_card.dart';
import 'widgets/cover_header.dart';
import 'widgets/desktop_hire_button.dart';
import 'widgets/glass_header_overlay.dart';
import 'widgets/hire_bar.dart';
import 'widgets/languages_card.dart';
import 'widgets/pricing_card.dart';
import 'widgets/reviews_card.dart';
import 'widgets/services_card.dart';
import 'widgets/stats_card.dart';
import 'widgets/trust_card.dart';
import 'widgets/vehicles_card.dart';

class DriverDetailScreen extends StatelessWidget {
  final String driverId;
  const DriverDetailScreen({super.key, required this.driverId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DriverDetailProvider(),
      child: const _DriverDetailView(),
    );
  }
}

class _DriverDetailView extends StatelessWidget {
  const _DriverDetailView();

  bool _isDark(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  void _launchHireFlow(BuildContext context, DriverProfile profile) {
    final driver = BookingDriver(
      id: profile.id,
      name: profile.name,
      avatarUrl: profile.avatarUrl,
      rating: profile.rating,
      pricePerDay: profile.dailyRate,
      speciality: 'Chauffeur',
    );
    context.pushNamed('booking', extra: {'service': BookingServiceType.driverOnly, 'driver': driver});
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(MediaQuery.of(context).size.width);
    final isDark = _isDark(context);
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: isDesktop ? _buildDesktop(context, isDark, cs) : _buildMobile(context, isDark, cs),
    );
  }

  Widget _buildMobile(BuildContext context, bool isDark, ColorScheme cs) {
    final provider = context.read<DriverDetailProvider>();
    final profile = provider.profile;
    return Stack(
      children: [
        CustomScrollView(
          controller: provider.scroll,
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(child: CoverHeader(isDark: isDark, cs: cs)),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 120.r),
              sliver: SliverList.list(
                children: [
                  StatsCard(profile: profile, isDark: isDark, cs: cs),
                  SizedBox(height: 14.r),
                  TrustCard(isDark: isDark, cs: cs),
                  SizedBox(height: 14.r),
                  PricingCard(profile: profile, isDark: isDark, cs: cs),
                  SizedBox(height: 14.r),
                  AboutCard(profile: profile, isDark: isDark, cs: cs),
                  SizedBox(height: 14.r),
                  ServicesCard(profile: profile, isDark: isDark, cs: cs),
                  SizedBox(height: 14.r),
                  VehiclesCard(profile: profile, isDark: isDark, cs: cs),
                  SizedBox(height: 14.r),
                  AvailabilityCard(profile: profile, isDark: isDark, cs: cs),
                  SizedBox(height: 14.r),
                  LanguagesCard(profile: profile, isDark: isDark, cs: cs),
                  SizedBox(height: 14.r),
                  ReviewsCard(profile: profile, isDark: isDark, cs: cs),
                ],
              ),
            ),
          ],
        ),
        Positioned(left: 0, right: 0, top: 0, child: GlassHeaderOverlay(isDark: isDark, cs: cs)),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: HireBar(
            profile: profile,
            isDark: isDark,
            cs: cs,
            onHire: () => _launchHireFlow(context, profile),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktop(BuildContext context, bool isDark, ColorScheme cs) {
    final profile = context.read<DriverDetailProvider>().profile;
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: 40.r, vertical: 28.r),
      child: Center(
        child: Container(
          constraints: BoxConstraints(maxWidth: 1100.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(CupertinoIcons.back, size: 17.r, color: cs.onSurface),
                    ),
                  ),
                  SizedBox(width: 14.r),
                  Text(
                    'driver_detail_title'.tr(),
                    style: TextStyle(fontSize: 24.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                  ),
                ],
              ),
              SizedBox(height: 20.r),
              CoverHeader(isDark: isDark, cs: cs, isDesktop: true),
              SizedBox(height: 20.r),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        StatsCard(profile: profile, isDark: isDark, cs: cs),
                        SizedBox(height: 16.r),
                        AboutCard(profile: profile, isDark: isDark, cs: cs),
                        SizedBox(height: 16.r),
                        ServicesCard(profile: profile, isDark: isDark, cs: cs),
                        SizedBox(height: 16.r),
                        ReviewsCard(profile: profile, isDark: isDark, cs: cs),
                      ],
                    ),
                  ),
                  SizedBox(width: 20.r),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        TrustCard(isDark: isDark, cs: cs),
                        SizedBox(height: 16.r),
                        PricingCard(profile: profile, isDark: isDark, cs: cs),
                        SizedBox(height: 16.r),
                        VehiclesCard(profile: profile, isDark: isDark, cs: cs),
                        SizedBox(height: 16.r),
                        AvailabilityCard(profile: profile, isDark: isDark, cs: cs),
                        SizedBox(height: 16.r),
                        LanguagesCard(profile: profile, isDark: isDark, cs: cs),
                        SizedBox(height: 16.r),
                        DesktopHireButton(
                          profile: profile,
                          cs: cs,
                          onTap: () => _launchHireFlow(context, profile),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40.r),
            ],
          ),
        ),
      ),
    );
  }
}
