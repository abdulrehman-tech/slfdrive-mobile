import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../providers/theme_provider.dart';
import 'provider/driver_profile_provider.dart';
import 'widgets/account_section.dart';
import 'widgets/danger_zone_section.dart';
import 'widgets/notifications_section.dart';
import 'widgets/profile_header.dart';
import 'widgets/settings_section.dart';
import 'widgets/stats_row.dart';
import 'widgets/support_section.dart';

class DriverProfileScreen extends StatelessWidget {
  const DriverProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DriverProfileProvider(),
      child: const _DriverProfileView(),
    );
  }
}

class _DriverProfileView extends StatelessWidget {
  const _DriverProfileView();

  bool _isDark(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF121212) : const Color(0xFFF8F9FA),
      body: SafeArea(
        top: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const SliverToBoxAdapter(child: ProfileHeader()),
            SliverToBoxAdapter(child: StatsRow(isDark: isDark)),
            SliverToBoxAdapter(child: AccountSection(isDark: isDark, cs: cs)),
            SliverToBoxAdapter(child: SizedBox(height: 12.r)),
            SliverToBoxAdapter(child: SettingsSection(isDark: isDark, cs: cs)),
            SliverToBoxAdapter(child: SizedBox(height: 12.r)),
            SliverToBoxAdapter(child: NotificationsSection(isDark: isDark, cs: cs)),
            SliverToBoxAdapter(child: SizedBox(height: 12.r)),
            SliverToBoxAdapter(child: SupportSection(isDark: isDark, cs: cs)),
            SliverToBoxAdapter(child: SizedBox(height: 12.r)),
            SliverToBoxAdapter(child: DangerZoneSection(isDark: isDark, cs: cs)),
            SliverToBoxAdapter(child: SizedBox(height: 100.r)),
          ],
        ),
      ),
    );
  }
}
