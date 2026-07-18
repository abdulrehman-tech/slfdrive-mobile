import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../models/trip_request.dart';
import '../provider/driver_home_provider.dart';
import 'online_status_dialog.dart';
import 'trip_action_dialog.dart';

class TripRequestsSection extends StatelessWidget {
  final bool isDark;

  const TripRequestsSection({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DriverHomeProvider>();
    final requests = provider.requests;

    return Padding(
      padding: EdgeInsets.all(20.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'driver_new_requests'.tr(),
            style: TextStyle(
              fontSize: 18.r,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          SizedBox(height: 16.r),
          if (requests.isEmpty)
            _EmptyRequests(isDark: isDark, isOnline: provider.isOnline)
          else
            ...requests.map((trip) => TripRequestCard(trip: trip, isDark: isDark)),
        ],
      ),
    );
  }
}

/// Illustrated empty state for the trip-requests list. Adapts to availability:
/// while online it shows a live "listening" radar with a soft pulse; while
/// offline it explains why nothing arrives and offers a one-tap way back online.
class _EmptyRequests extends StatefulWidget {
  final bool isDark;
  final bool isOnline;

  const _EmptyRequests({required this.isDark, required this.isOnline});

  @override
  State<_EmptyRequests> createState() => _EmptyRequestsState();
}

class _EmptyRequestsState extends State<_EmptyRequests> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1800),
  )..repeat();

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final online = widget.isOnline;
    final accent = online ? const Color(0xFF4CAF50) : const Color(0xFF9E9E9E);
    final title = (online ? 'driver_no_requests_online_title' : 'driver_no_requests_offline_title').tr();
    final sub = (online ? 'driver_no_requests_online_sub' : 'driver_no_requests_offline_sub').tr();
    final titleColor = widget.isDark ? Colors.white : Colors.black87;
    final subColor = widget.isDark ? Colors.white54 : const Color(0xFF9E9E9E);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 36.r, horizontal: 24.r),
      decoration: BoxDecoration(
        color: widget.isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: widget.isDark ? Colors.white.withValues(alpha: 0.05) : Colors.black.withValues(alpha: 0.04),
        ),
      ),
      child: Column(
        children: [
          SizedBox(
            width: 108.r,
            height: 108.r,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Pulsing rings — only while online (actively listening).
                if (online)
                  AnimatedBuilder(
                    animation: _pulse,
                    builder: (_, _) => Stack(
                      alignment: Alignment.center,
                      children: [
                        _ring(accent, (_pulse.value) % 1.0),
                        _ring(accent, (_pulse.value + 0.5) % 1.0),
                      ],
                    ),
                  ),
                Container(
                  width: 64.r,
                  height: 64.r,
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: widget.isDark ? 0.18 : 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    online ? Iconsax.radar_2 : Iconsax.moon,
                    color: accent,
                    size: 30.r,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.r),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16.r, fontWeight: FontWeight.w700, color: titleColor),
          ),
          SizedBox(height: 6.r),
          Text(
            sub,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.r, height: 1.4, color: subColor),
          ),
          if (!online) ...[
            SizedBox(height: 20.r),
            GestureDetector(
              onTap: () => showOnlineStatusDialog(
                context,
                isDark: widget.isDark,
                isCurrentlyOnline: false,
                onConfirm: () => context.read<DriverHomeProvider>().toggleOnline(),
              ),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 24.r, vertical: 12.r),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFF4D63DD), Color(0xFF677EF0)]),
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(color: const Color(0xFF4D63DD).withValues(alpha: 0.3), blurRadius: 12.r, offset: Offset(0, 4.r)),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Iconsax.flash_1, color: Colors.white, size: 16.r),
                    SizedBox(width: 8.r),
                    Text(
                      'driver_go_online_confirm'.tr(),
                      style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// A single expanding-and-fading ring; [t] is its 0→1 progress.
  Widget _ring(Color color, double t) {
    final size = 64.r + (44.r * t);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: (1 - t) * 0.18),
      ),
    );
  }
}

class TripRequestCard extends StatelessWidget {
  final TripRequest trip;
  final bool isDark;

  const TripRequestCard({super.key, required this.trip, required this.isDark});

  Widget _avatar() {
    final url = trip.avatarUrl;
    final fallback = Icon(Iconsax.user, color: const Color(0xFF4D63DD), size: 20.r);
    return Container(
      width: 44.r,
      height: 44.r,
      decoration: BoxDecoration(
        color: const Color(0xFF4D63DD).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      clipBehavior: Clip.antiAlias,
      child: (url != null && url.isNotEmpty)
          ? CachedNetworkImage(
              imageUrl: url,
              fit: BoxFit.cover,
              errorWidget: (c, u, e) => fallback,
            )
          : fallback,
    );
  }

  String _daysLabel() =>
      'driver_request_days'.tr(namedArgs: {'n': trip.days.toString()});

  Widget _serviceChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 5.r),
      decoration: BoxDecoration(
        color: const Color(0xFF4D63DD).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        trip.serviceKey.tr(),
        style: TextStyle(fontSize: 11.r, fontWeight: FontWeight.w600, color: const Color(0xFF4D63DD)),
      ),
    );
  }

  Widget _infoRow(IconData icon, Color iconColor, String text, Color textColor) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.r, color: iconColor),
        SizedBox(width: 8.r),
        Expanded(
          child: Text(text, style: TextStyle(fontSize: 13.r, color: textColor)),
        ),
      ],
    );
  }

  /// Fare presentation. The headline is the total the customer will pay; the
  /// subtitle makes its composition explicit (duration × derived per-day rate).
  Widget _priceBlock(Color muted) {
    final perDay = trip.perDay;
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'driver_request_total'.tr(),
                  style: TextStyle(fontSize: 12.r, color: muted),
                ),
                if (perDay != null) ...[
                  SizedBox(height: 2.r),
                  Text(
                    '${_daysLabel()} × OMR ${perDay.toStringAsFixed(2)} ${'driver_request_per_day'.tr()}',
                    style: TextStyle(fontSize: 11.r, color: muted),
                  ),
                ],
                if (trip.isCorporate) ...[
                  SizedBox(height: 4.r),
                  Text(
                    'driver_request_billed_company'.tr(),
                    style: TextStyle(fontSize: 11.r, fontWeight: FontWeight.w600, color: const Color(0xFF00BFA5)),
                  ),
                ],
              ],
            ),
          ),
          Text(
            'OMR ${trip.fare.toStringAsFixed(2)}',
            style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.w800, color: const Color(0xFF4CAF50)),
          ),
        ],
      ),
    );
  }

  /// Opens the accept/decline confirmation; the actual call runs only if the
  /// driver confirms.
  void _confirm(BuildContext context, {required bool accept}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showTripActionDialog(
      context,
      isDark: isDark,
      accept: accept,
      customer: trip.customer,
      onConfirm: () => _respond(context, accept: accept),
    );
  }

  Future<void> _respond(BuildContext context, {required bool accept}) async {
    final messenger = ScaffoldMessenger.of(context);
    final provider = context.read<DriverHomeProvider>();
    final ok = accept ? await provider.accept(trip) : await provider.decline(trip);
    if (!context.mounted) return;
    final msg = ok
        ? (accept ? 'driver_accept_snack'.tr() : 'driver_decline_snack'.tr())
        : 'driver_request_failed'.tr();
    messenger.showSnackBar(
      SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    final muted = isDark ? Colors.white60 : const Color(0xFF757575);
    final body = isDark ? Colors.white70 : const Color(0xFF555555);
    return Container(
      margin: EdgeInsets.only(bottom: 12.r),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10.r, offset: Offset(0, 4.r))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer + requested service
          Row(
            children: [
              _avatar(),
              SizedBox(width: 12.r),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trip.customer,
                      style: TextStyle(
                        fontSize: 15.r,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    SizedBox(height: 2.r),
                    Text(
                      trip.customerPhone ?? trip.reference,
                      style: TextStyle(fontSize: 12.r, color: muted),
                    ),
                  ],
                ),
              ),
              _serviceChip(),
            ],
          ),
          SizedBox(height: 14.r),
          // When + duration
          _infoRow(
            Iconsax.calendar_1,
            const Color(0xFF4D63DD),
            trip.dateRange.isEmpty
                ? _daysLabel()
                : '${trip.dateRange}  •  ${_daysLabel()}',
            body,
          ),
          if (trip.hasPickup) ...[
            SizedBox(height: 8.r),
            _infoRow(Iconsax.location, const Color(0xFF4D63DD),
                '${'driver_request_pickup'.tr()}: ${trip.pickup}', body),
          ],
          if (trip.hasDropoff) ...[
            SizedBox(height: 8.r),
            _infoRow(Iconsax.location_tick, const Color(0xFF4CAF50),
                '${'driver_request_dropoff'.tr()}: ${trip.dropoff}', body),
          ],
          SizedBox(height: 14.r),
          _priceBlock(muted),
          SizedBox(height: 16.r),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _confirm(context, accept: false),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.r),
                    decoration: BoxDecoration(
                      color: Colors.red.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'driver_decline'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w600, color: Colors.red),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.r),
              Expanded(
                child: GestureDetector(
                  onTap: () => _confirm(context, accept: true),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 12.r),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF4D63DD), Color(0xFF677EF0)]),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      'driver_accept'.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
