import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../../../../constants/breakpoints.dart';
import '../../../providers/theme_provider.dart';
import 'models/booking_detail.dart';
import 'provider/booking_detail_provider.dart';
import 'widgets/action_bar.dart';
import 'widgets/action_row.dart';
import 'widgets/booking_app_bar.dart';
import 'widgets/cancel_button.dart';
import 'widgets/car_card.dart';
import 'widgets/driver_card.dart';
import 'widgets/location_map_card.dart';
import 'widgets/price_card.dart';
import 'widgets/qr_card.dart';
import 'widgets/ref_card.dart';
import 'widgets/schedule_card.dart';
import 'widgets/timeline_card.dart';

class BookingDetailScreen extends StatelessWidget {
  final String bookingId;
  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BookingDetailProvider(),
      child: const _BookingDetailView(),
    );
  }
}

class _BookingDetailView extends StatelessWidget {
  const _BookingDetailView();

  bool _isDark(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode ||
        (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('booking_detail_cancel_title'.tr()),
        content: Text('booking_detail_cancel_body'.tr()),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('cancel'.tr())),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: const Color(0xFFE53935)),
            child: Text('booking_detail_cancel_confirm'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(MediaQuery.of(context).size.width);
    final isDark = _isDark(context);
    final cs = Theme.of(context).colorScheme;
    final booking = context.read<BookingDetailProvider>().booking;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: isDesktop
          ? _buildDesktop(context, isDark, cs, booking)
          : _buildMobile(context, isDark, cs, booking),
    );
  }

  Widget _buildMobile(BuildContext context, bool isDark, ColorScheme cs, BookingDetail b) {
    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            BookingSliverAppBar(isDark: isDark, cs: cs),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.r, 4.r, 16.r, 140.r),
              sliver: SliverList.list(
                children: [
                  BookingRefCard(booking: b, isDark: isDark, cs: cs),
                  SizedBox(height: 14.r),
                  BookingTimelineCard(booking: b, isDark: isDark, cs: cs),
                  SizedBox(height: 14.r),
                  BookingCarCard(booking: b, isDark: isDark, cs: cs),
                  SizedBox(height: 14.r),
                  if (b.driverName != null) ...[
                    BookingDriverCard(booking: b, isDark: isDark, cs: cs),
                    SizedBox(height: 14.r),
                  ],
                  BookingScheduleCard(booking: b, isDark: isDark, cs: cs),
                  SizedBox(height: 14.r),
                  BookingLocationMapCard(booking: b, isDark: isDark, cs: cs),
                  SizedBox(height: 14.r),
                  BookingPriceCard(booking: b, isDark: isDark, cs: cs),
                  SizedBox(height: 14.r),
                  BookingQrCard(booking: b, isDark: isDark, cs: cs),
                  SizedBox(height: 14.r),
                  BookingCancelButton(isDark: isDark, onTap: () => _confirmCancel(context)),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: BookingActionBar(booking: b, isDark: isDark, cs: cs),
        ),
      ],
    );
  }

  Widget _buildDesktop(BuildContext context, bool isDark, ColorScheme cs, BookingDetail b) {
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
                        color: isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Icon(CupertinoIcons.back, size: 17.r, color: cs.onSurface),
                    ),
                  ),
                  SizedBox(width: 14.r),
                  Text(
                    'booking_detail_title'.tr(),
                    style: TextStyle(
                      fontSize: 24.r,
                      fontWeight: FontWeight.bold,
                      color: cs.onSurface,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 22.r),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        BookingRefCard(booking: b, isDark: isDark, cs: cs),
                        SizedBox(height: 16.r),
                        BookingTimelineCard(booking: b, isDark: isDark, cs: cs),
                        SizedBox(height: 16.r),
                        BookingCarCard(booking: b, isDark: isDark, cs: cs),
                        SizedBox(height: 16.r),
                        BookingLocationMapCard(booking: b, isDark: isDark, cs: cs),
                      ],
                    ),
                  ),
                  SizedBox(width: 20.r),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        BookingScheduleCard(booking: b, isDark: isDark, cs: cs),
                        SizedBox(height: 16.r),
                        if (b.driverName != null) ...[
                          BookingDriverCard(booking: b, isDark: isDark, cs: cs),
                          SizedBox(height: 16.r),
                        ],
                        BookingPriceCard(booking: b, isDark: isDark, cs: cs),
                        SizedBox(height: 16.r),
                        BookingQrCard(booking: b, isDark: isDark, cs: cs),
                        SizedBox(height: 16.r),
                        BookingActionRow(booking: b, isDark: isDark, cs: cs),
                        SizedBox(height: 12.r),
                        BookingCancelButton(isDark: isDark, onTap: () => _confirmCancel(context)),
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
