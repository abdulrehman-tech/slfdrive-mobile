import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../models/trip_request.dart';
import '../provider/driver_home_provider.dart';

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
          if (provider.isLoading)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.r),
              child: const Center(child: CircularProgressIndicator()),
            )
          else if (requests.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 24.r),
              child: Text(
                'driver_no_requests'.tr(),
                style: TextStyle(fontSize: 14.r, color: isDark ? Colors.white54 : const Color(0xFF9E9E9E)),
              ),
            )
          else
            ...requests.map((trip) => TripRequestCard(trip: trip, isDark: isDark)),
        ],
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
                  onTap: () => _respond(context, accept: false),
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
                  onTap: () => _respond(context, accept: true),
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
