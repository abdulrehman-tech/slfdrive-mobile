import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../provider/home_provider.dart';
import 'driver_card.dart';
import 'section_header.dart';

class NearbyDriversSection extends StatelessWidget {
  final bool isDesktop;
  final bool isDark;
  const NearbyDriversSection({super.key, this.isDesktop = false, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final home = context.watch<HomeProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'home_nearby_drivers'.tr(),
          cs: cs,
          onViewAll: () => context.pushNamed('driver-listing'),
          isDesktop: isDesktop,
        ),
        if (home.driversLoading)
          _SectionSpinner(isDark: isDark)
        else if (home.driversError != null)
          _SectionError(message: home.driversError!, isDark: isDark, cs: cs, onRetry: home.load)
        else if (home.nearbyDrivers.isEmpty)
          _SectionEmpty(label: 'home_no_drivers'.tr(), isDark: isDark, cs: cs)
        else if (isDesktop)
          ...home.nearbyDrivers.map(
            (d) => Padding(
              padding: EdgeInsets.only(bottom: 12.r),
              child: DriverCard(
                driver: d,
                isDark: isDark,
                cs: cs,
                horizontal: true,
                onTap: () => context.pushNamed('driver-detail', pathParameters: {'id': d.id}),
              ),
            ),
          )
        else
          SizedBox(
            height: 168.r,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: 16.r),
              itemCount: home.nearbyDrivers.length,
              itemBuilder: (_, i) => RepaintBoundary(
                child: Padding(
                  padding: EdgeInsetsDirectional.only(end: 12.r),
                  child: DriverCard(
                    driver: home.nearbyDrivers[i],
                    isDark: isDark,
                    cs: cs,
                    onTap: () => context.pushNamed('driver-detail', pathParameters: {'id': home.nearbyDrivers[i].id}),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ── Shared section-level state widgets ─────────────────────────────────────

class _SectionSpinner extends StatelessWidget {
  final bool isDark;
  const _SectionSpinner({required this.isDark});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100.r,
      child: Center(
        child: CircularProgressIndicator.adaptive(
          valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.primary),
          strokeWidth: 2.5,
        ),
      ),
    );
  }
}

class _SectionError extends StatelessWidget {
  final String message;
  final bool isDark;
  final ColorScheme cs;
  final VoidCallback onRetry;

  const _SectionError({required this.message, required this.isDark, required this.cs, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    // No fixed height — icon + (up to 2 lines) + retry button can exceed a
    // hardcoded box (was overflowing ~6px). Let it size to its content.
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.warning_2_copy, color: cs.error, size: 22.r),
            SizedBox(height: 6.r),
            Text(
              message,
              style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.6)),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4.r),
            TextButton(
              onPressed: onRetry,
              child: Text(
                'retry'.tr(),
                style: TextStyle(fontSize: 12.r, color: cs.primary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionEmpty extends StatelessWidget {
  final String label;
  final bool isDark;
  final ColorScheme cs;

  const _SectionEmpty({required this.label, required this.isDark, required this.cs});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80.r,
      child: Center(
        child: Text(
          label,
          style: TextStyle(fontSize: 13.r, color: cs.onSurface.withValues(alpha: 0.45)),
        ),
      ),
    );
  }
}
