import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../core/models/company/company_profile.dart';
import '../../../../utils/bidi.dart';
import '../../../../utils/contact_launcher.dart';

Color _cardColor(bool isDark) => isDark ? const Color(0xFF1E1E2E) : Colors.white;

List<BoxShadow> _cardShadow(bool isDark) => [
      BoxShadow(color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05), blurRadius: 16.r, offset: Offset(0, 6.r)),
    ];

/// Headline numbers in equal columns: rating, fleet size, completed trips and
/// (when known) branches. Values scale down rather than wrap on narrow screens.
class CompanyStatsCard extends StatelessWidget {
  final CompanyProfile profile;
  final bool isDark;

  const CompanyStatsCard({super.key, required this.profile, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final s = profile.stats;
    final branches = profile.company.numberOfBranches ?? 0;
    final items = <_Stat>[
      _Stat(
        icon: Icons.star_rounded,
        color: const Color(0xFFFFB300),
        value: s.averageRating?.toStringAsFixed(1) ?? 'company_new'.tr(),
        label: s.totalReviews > 0 ? '${'company_stat_rating'.tr()} (${s.totalReviews})' : 'company_stat_rating'.tr(),
      ),
      _Stat(
        icon: Iconsax.car,
        color: cs.primary,
        value: '${profile.vehicles.length}',
        label: 'company_tab_vehicles'.tr(),
      ),
      _Stat(
        icon: Iconsax.tick_circle,
        color: const Color(0xFF2E9E57),
        value: '${s.completedBookings}',
        label: 'company_stat_trips'.tr(),
      ),
      if (branches > 0)
        _Stat(
          icon: Iconsax.building_4,
          color: const Color(0xFF8E24AA),
          value: '$branches',
          label: 'company_stat_branches'.tr(),
        ),
    ];

    final divider = Container(width: 1, height: 36.r, color: cs.onSurface.withValues(alpha: 0.08));
    return Container(
      padding: EdgeInsets.symmetric(vertical: 14.r, horizontal: 6.r),
      decoration: BoxDecoration(
        color: _cardColor(isDark),
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: _cardShadow(isDark),
      ),
      child: Row(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) divider,
            Expanded(child: _StatCell(stat: items[i], cs: cs)),
          ],
        ],
      ),
    );
  }
}

class _Stat {
  final IconData icon;
  final Color color;
  final String value;
  final String label;
  const _Stat({required this.icon, required this.color, required this.value, required this.label});
}

class _StatCell extends StatelessWidget {
  final _Stat stat;
  final ColorScheme cs;
  const _StatCell({required this.stat, required this.cs});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 4.r),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(stat.icon, size: 16.r, color: stat.color),
                SizedBox(width: 4.r),
                Text(
                  ltr(stat.value),
                  style: TextStyle(fontSize: 17.r, fontWeight: FontWeight.w800, color: cs.onSurface, height: 1.2),
                ),
              ],
            ),
          ),
          SizedBox(height: 3.r),
          Text(
            stat.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11.r, fontWeight: FontWeight.w500, color: cs.onSurface.withValues(alpha: 0.55)),
          ),
        ],
      ),
    );
  }
}

/// Call / Email / Website as equal-width action tiles. Hidden when the company
/// published none of them.
class CompanyActions extends StatelessWidget {
  final CompanyInfo company;
  final bool isDark;

  const CompanyActions({super.key, required this.company, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final c = company;
    // (icon, label key, value, launcher). If nothing on the device can handle
    // the link (iPad, simulator, no Mail account), copy the value instead of
    // failing silently.
    final website = c.website == null ? null : (c.website!.startsWith('http') ? c.website! : 'https://${c.website!}');
    final actions = <(IconData, String, String, Future<bool> Function())>[
      if (c.contactPhone != null)
        (Iconsax.call, 'company_action_call', c.contactPhone!, () => ContactLauncher.openPhoneCall(c.contactPhone!)),
      if (c.contactEmail != null)
        (Iconsax.sms, 'company_action_email', c.contactEmail!, () => ContactLauncher.openEmail(c.contactEmail!)),
      if (website != null) (Iconsax.global, 'company_action_website', website, () => ContactLauncher.openWebsite(website)),
    ];
    if (actions.isEmpty) return const SizedBox.shrink();
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        for (var i = 0; i < actions.length; i++) ...[
          if (i > 0) SizedBox(width: 10.r),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r), boxShadow: _cardShadow(isDark)),
              child: Material(
                color: _cardColor(isDark),
                borderRadius: BorderRadius.circular(16.r),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16.r),
                  onTap: () => _open(context, actions[i].$3, actions[i].$4),
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.r, horizontal: 6.r),
                    child: Column(
                      children: [
                        Container(
                          width: 38.r,
                          height: 38.r,
                          decoration: BoxDecoration(
                            color: cs.primary.withValues(alpha: isDark ? 0.2 : 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(actions[i].$1, size: 18.r, color: cs.primary),
                        ),
                        SizedBox(height: 6.r),
                        Text(
                          actions[i].$2.tr(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _open(BuildContext context, String value, Future<bool> Function() launch) async {
    final messenger = ScaffoldMessenger.of(context);
    if (await launch()) return;
    await Clipboard.setData(ClipboardData(text: value));
    messenger.showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      content: Text('company_contact_copied'.tr(namedArgs: {'value': ltr(value)})),
    ));
  }
}
