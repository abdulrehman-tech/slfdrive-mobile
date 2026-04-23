import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../constants/breakpoints.dart';
import '../../../providers/theme_provider.dart';
import 'provider/bookings_provider.dart';
import 'widgets/booking_card.dart';
import 'widgets/bookings_app_bar.dart';
import 'widgets/bookings_empty.dart';
import 'widgets/bookings_tab_bar.dart';

class BookingsScreen extends StatelessWidget {
  const BookingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookingsProvider(),
      child: const _BookingsView(),
    );
  }
}

class _BookingsView extends StatelessWidget {
  const _BookingsView();

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(MediaQuery.of(context).size.width);
    return isDesktop ? const _DesktopLayout() : const _MobileLayout();
  }
}

bool _isDarkMode(BuildContext context) {
  final tp = context.watch<ThemeProvider>();
  return tp.isDarkMode ||
      (tp.isSystemMode &&
          MediaQuery.of(context).platformBrightness == Brightness.dark);
}

class _MobileLayout extends StatelessWidget {
  const _MobileLayout();

  @override
  Widget build(BuildContext context) {
    final isDark = _isDarkMode(context);
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<BookingsProvider>();
    final bookings = provider.filteredBookings;
    final tabIndex = provider.tabIndex;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        BookingsAppBar(isDark: isDark, cs: cs),
        SliverToBoxAdapter(child: BookingsTabBar(isDark: isDark, cs: cs)),
        if (bookings.isEmpty)
          SliverFillRemaining(
            child: BookingsEmpty(
              isDark: isDark,
              cs: cs,
              title: BookingsProvider.emptyTitles[tabIndex].tr(),
              subtitle: BookingsProvider.emptySubs[tabIndex].tr(),
              icon: BookingsProvider.tabIcons[tabIndex],
              color: BookingsProvider.tabColors[tabIndex],
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.r, 8.r, 16.r, 100.r),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: EdgeInsets.only(bottom: 14.r),
                  child: BookingCard(
                    booking: bookings[i],
                    isDark: isDark,
                    cs: cs,
                  ),
                ),
                childCount: bookings.length,
              ),
            ),
          ),
      ],
    );
  }
}

class _DesktopLayout extends StatelessWidget {
  const _DesktopLayout();

  @override
  Widget build(BuildContext context) {
    final isDark = _isDarkMode(context);
    final cs = Theme.of(context).colorScheme;
    final provider = context.watch<BookingsProvider>();
    final bookings = provider.filteredBookings;
    final tabIndex = provider.tabIndex;

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
                  Text(
                    'bookings_title'.tr(),
                    style: TextStyle(
                      fontSize: 24.r,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                  const Spacer(),
                  BookingsTabBar(isDark: isDark, cs: cs, compact: true),
                ],
              ),
              SizedBox(height: 24.r),
              if (bookings.isEmpty)
                SizedBox(
                  height: 400.r,
                  child: BookingsEmpty(
                    isDark: isDark,
                    cs: cs,
                    title: BookingsProvider.emptyTitles[tabIndex].tr(),
                    subtitle: BookingsProvider.emptySubs[tabIndex].tr(),
                    icon: BookingsProvider.tabIcons[tabIndex],
                    color: BookingsProvider.tabColors[tabIndex],
                  ),
                )
              else
                Wrap(
                  spacing: 16.r,
                  runSpacing: 16.r,
                  children: bookings
                      .map(
                        (b) => SizedBox(
                          width: 520.r,
                          child: BookingCard(
                            booking: b,
                            isDark: isDark,
                            cs: cs,
                          ),
                        ),
                      )
                      .toList(),
                ),
              SizedBox(height: 40.r),
            ],
          ),
        ),
      ),
    );
  }
}
