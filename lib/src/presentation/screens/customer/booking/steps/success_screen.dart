import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../constants/breakpoints.dart';
import '../../../../../constants/color_constants.dart';
import '../../../../providers/theme_provider.dart';
import '../../../../widgets/omr_icon.dart';
import '../models/booking_data.dart';

class BookingSuccessScreen extends StatefulWidget {
  final BookingData data;
  const BookingSuccessScreen({super.key, required this.data});

  @override
  State<BookingSuccessScreen> createState() => _BookingSuccessScreenState();
}

class _BookingSuccessScreenState extends State<BookingSuccessScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _tick;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..forward();
    _tick = CurvedAnimation(parent: _ctrl, curve: const Interval(0.0, 0.55, curve: Curves.easeOutBack));
    _pulse = CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 1.0, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  bool get _isDark {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(MediaQuery.of(context).size.width);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: Container(
            constraints: BoxConstraints(maxWidth: isDesktop ? 620.r : double.infinity),
            padding: EdgeInsets.symmetric(horizontal: isDesktop ? 32.r : 20.r, vertical: 24.r),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: isDesktop ? 12.r : 32.r),
                  _buildSuccessIcon(),
                  SizedBox(height: 22.r),
                  _buildTitle(),
                  SizedBox(height: 22.r),
                  _buildReferenceCard(),
                  SizedBox(height: 16.r),
                  _buildSummaryCard(),
                  SizedBox(height: 22.r),
                  _buildActions(),
                  SizedBox(height: 24.r),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessIcon() {
    return Center(
      child: SizedBox(
        width: 130.r,
        height: 130.r,
        child: Stack(
          alignment: Alignment.center,
          children: [
            ScaleTransition(
              scale: _pulse,
              child: Container(
                width: 130.r,
                height: 130.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                ),
              ),
            ),
            ScaleTransition(
              scale: _pulse,
              child: Container(
                width: 100.r,
                height: 100.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF4CAF50).withValues(alpha: 0.18),
                ),
              ),
            ),
            ScaleTransition(
              scale: _tick,
              child: Container(
                width: 72.r,
                height: 72.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4CAF50), Color(0xFF66BB6A)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.4),
                      blurRadius: 22.r,
                      offset: Offset(0, 8.r),
                    ),
                  ],
                ),
                child: Icon(Iconsax.tick_circle_copy, size: 40.r, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTitle() {
    final cs = Theme.of(context).colorScheme;
    return Column(
      children: [
        Text(
          'booking_success_title'.tr(),
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.bold, color: cs.onSurface, letterSpacing: -0.2),
        ),
        SizedBox(height: 6.r),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.r),
          child: Text(
            'booking_success_subtitle'.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13.r, color: cs.onSurface.withValues(alpha: 0.6), height: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _buildReferenceCard() {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark;
    final ref = widget.data.bookingRef ?? 'SLF000';

    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.all(18.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1A237E), const Color(0xFF311B92)]
                  : [const Color(0xFF0C2485), const Color(0xFF3D5AFE)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: cs.primary.withValues(alpha: 0.3),
                blurRadius: 20.r,
                offset: Offset(0, 8.r),
              ),
            ],
          ),
          child: Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'booking_success_ref'.tr(),
                    style: TextStyle(
                      fontSize: 11.r,
                      color: Colors.white.withValues(alpha: 0.65),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4.r),
                  Text(
                    ref,
                    style: TextStyle(
                      fontSize: 22.r,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              GestureDetector(
                onTap: () async {
                  await Clipboard.setData(ClipboardData(text: ref));
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('booking_success_copied'.tr())),
                  );
                },
                child: Container(
                  width: 42.r,
                  height: 42.r,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                  ),
                  child: Icon(Iconsax.copy_copy, color: Colors.white, size: 18.r),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    final cs = Theme.of(context).colorScheme;
    final isDark = _isDark;
    final d = widget.data;

    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: Column(
            children: [
              _row(cs, 'booking_summary_pickup_date'.tr(), _formatDate(d.startAt)),
              Divider(
                height: 18.r,
                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
              ),
              _row(cs, 'booking_summary_mode'.tr(),
                  d.pickupMode == PickupMode.selfPickup ? 'booking_pickup_self'.tr() : 'booking_pickup_delivery'.tr()),
              Divider(
                height: 18.r,
                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
              ),
              Row(
                children: [
                  Text(
                    'booking_summary_total'.tr(),
                    style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                  ),
                  const Spacer(),
                  OmrIcon(size: 14.r, color: cs.primary),
                  SizedBox(width: 3.r),
                  Text(
                    d.totalPrice.toStringAsFixed(2),
                    style: TextStyle(fontSize: 20.r, fontWeight: FontWeight.w900, color: cs.primary),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActions() {
    return Column(
      children: [
        GestureDetector(
          onTap: () => context.go('/home'),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 16.r),
            decoration: BoxDecoration(
              gradient: primaryGradient,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0C2485).withValues(alpha: 0.35),
                  blurRadius: 16.r,
                  offset: Offset(0, 6.r),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'booking_success_home'.tr(),
                style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w800, color: Colors.white),
              ),
            ),
          ),
        ),
        SizedBox(height: 10.r),
        GestureDetector(
          onTap: () {
            context.go('/home');
            // Further: navigate to bookings detail — wired in phase 3.
          },
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 14.r),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
            ),
            child: Center(
              child: Text(
                'booking_success_view_booking'.tr(),
                style: TextStyle(
                  fontSize: 13.r,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(ColorScheme cs, String label, String value) {
    return Row(
      children: [
        Text(label, style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.55))),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface)),
      ],
    );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '-';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
