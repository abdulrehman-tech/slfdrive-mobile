import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/corporate/corporate_membership.dart';
import '../../../providers/theme_provider.dart';
import 'provider/corporate_membership_provider.dart';

/// Lists the signed-in customer's corporate memberships with their approval
/// status, and offers a CTA to apply for a new one.
class CorporateMembershipScreen extends StatelessWidget {
  const CorporateMembershipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => CorporateMembershipProvider(),
      child: const _CorporateMembershipView(),
    );
  }
}

class _CorporateMembershipView extends StatelessWidget {
  const _CorporateMembershipView();

  bool _isDark(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode ||
        (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  Future<void> _openApply(BuildContext context) async {
    final result = await context.push<bool>('/profile/corporate/apply');
    if (result == true && context.mounted) {
      context.read<CorporateMembershipProvider>().load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark(context);
    final provider = context.watch<CorporateMembershipProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('corporate_membership_title'.tr()),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openApply(context),
        backgroundColor: const Color(0xFF4D63DD),
        icon: const Icon(Iconsax.add, color: Colors.white),
        label: Text(
          'corporate_membership_apply'.tr(),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => provider.load(),
        child: _body(context, provider, isDark, cs),
      ),
    );
  }

  Widget _body(
    BuildContext context,
    CorporateMembershipProvider provider,
    bool isDark,
    ColorScheme cs,
  ) {
    if (provider.isLoading && !provider.hasLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    if (provider.error != null && provider.memberships.isEmpty) {
      return _Message(
        icon: CupertinoIconsFallback.warning,
        text: provider.error!,
        action: 'retry'.tr(),
        onAction: () => provider.load(),
        cs: cs,
      );
    }
    if (provider.memberships.isEmpty) {
      return _Message(
        icon: Iconsax.briefcase,
        text: 'corporate_membership_empty'.tr(),
        action: 'corporate_membership_apply'.tr(),
        onAction: () => _openApply(context),
        cs: cs,
      );
    }
    return ListView.separated(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 100.r),
      itemCount: provider.memberships.length,
      separatorBuilder: (_, i) => SizedBox(height: 12.r),
      itemBuilder: (_, i) => _MembershipCard(
        membership: provider.memberships[i],
        logoUrl: provider.logoUrlFor(provider.memberships[i].allCompanyId),
        isDark: isDark,
        cs: cs,
      ),
    );
  }
}

class _MembershipCard extends StatelessWidget {
  final CorporateMembership membership;
  final String? logoUrl;
  final bool isDark;
  final ColorScheme cs;
  const _MembershipCard({required this.membership, this.logoUrl, required this.isDark, required this.cs});

  ({Color color, String labelKey, IconData icon}) get _status {
    if (membership.isApprovedActive) {
      return (color: const Color(0xFF4CAF50), labelKey: 'corporate_status_approved', icon: Iconsax.tick_circle);
    }
    if (membership.isRejected) {
      return (color: const Color(0xFFE53935), labelKey: 'corporate_status_rejected', icon: Iconsax.close_circle);
    }
    return (color: const Color(0xFFFFA726), labelKey: 'corporate_status_pending', icon: Iconsax.clock);
  }

  @override
  Widget build(BuildContext context) {
    final s = _status;
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.r,
                height: 44.r,
                decoration: BoxDecoration(
                  color: const Color(0xFF4D63DD).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                clipBehavior: Clip.antiAlias,
                child: (logoUrl != null && logoUrl!.isNotEmpty)
                    ? CachedNetworkImage(
                        imageUrl: logoUrl!,
                        fit: BoxFit.cover,
                        errorWidget: (c, u, e) =>
                            Icon(Iconsax.buildings_copy, size: 22.r, color: const Color(0xFF4D63DD)),
                      )
                    : Icon(Iconsax.buildings_copy, size: 22.r, color: const Color(0xFF4D63DD)),
              ),
              SizedBox(width: 12.r),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      membership.displayCompanyName(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                    ),
                    if ((membership.designation ?? '').trim().isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 2.r),
                        child: Text(
                          membership.designation!,
                          style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.55)),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 6.r),
                decoration: BoxDecoration(
                  color: s.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: s.color.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(s.icon, size: 13.r, color: s.color),
                    SizedBox(width: 5.r),
                    Text(
                      s.labelKey.tr(),
                      style: TextStyle(fontSize: 11.r, fontWeight: FontWeight.w700, color: s.color),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (membership.isRejected && (membership.rejectReason ?? '').trim().isNotEmpty) ...[
            SizedBox(height: 12.r),
            Text(
              '${'corporate_reject_reason'.tr()}: ${membership.rejectReason}',
              style: TextStyle(fontSize: 12.r, color: const Color(0xFFE53935)),
            ),
          ],
        ],
      ),
    );
  }
}

class _Message extends StatelessWidget {
  final IconData icon;
  final String text;
  final String action;
  final VoidCallback onAction;
  final ColorScheme cs;
  const _Message({
    required this.icon,
    required this.text,
    required this.action,
    required this.onAction,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 120.r),
        Icon(icon, size: 48.r, color: cs.onSurface.withValues(alpha: 0.3)),
        SizedBox(height: 14.r),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 32.r),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.r, color: cs.onSurface.withValues(alpha: 0.6)),
          ),
        ),
        SizedBox(height: 18.r),
        Center(
          child: FilledButton(onPressed: onAction, child: Text(action)),
        ),
      ],
    );
  }
}

/// Iconsax has no plain "warning" alias used elsewhere; keep a small indirection
/// so the error state reads clearly.
class CupertinoIconsFallback {
  static const IconData warning = Iconsax.warning_2;
}
