import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../constants/breakpoints.dart';
import '../../../../constants/color_constants.dart';
import '../../../providers/theme_provider.dart';
import '../../../utils/contact_launcher.dart';
import '../../../widgets/customer/oman_plate.dart';
import '../../../widgets/omr_icon.dart';

// ============================================================
// MOCK DATA
// ============================================================

enum _BookingTimelineStage { confirmed, pickedUp, inTrip, returned }

class _BookingDetailMock {
  final String ref;
  final String carName;
  final String carImageUrl;
  final String brand;
  final String plateNumber;
  final String plateCode;
  final String pickupLocation;
  final String dropoffLocation;
  final DateTime start;
  final DateTime end;
  final double pricePerDay;
  final double extrasPerDay;
  final double deliveryFee;
  final String paymentMethod;
  final String? driverName;
  final String? driverAvatar;
  final String? driverPhone;
  final _BookingTimelineStage stage;

  const _BookingDetailMock({
    required this.ref,
    required this.carName,
    required this.carImageUrl,
    required this.brand,
    required this.plateNumber,
    required this.plateCode,
    required this.pickupLocation,
    required this.dropoffLocation,
    required this.start,
    required this.end,
    required this.pricePerDay,
    required this.extrasPerDay,
    required this.deliveryFee,
    required this.paymentMethod,
    required this.stage,
    this.driverName,
    this.driverAvatar,
    this.driverPhone,
  });

  int get days {
    final d = end.difference(start).inDays;
    return d < 1 ? 1 : d + 1;
  }

  double get subtotal => (pricePerDay + extrasPerDay) * days + deliveryFee;
  double get vat => subtotal * 0.05;
  double get total => subtotal + vat;
}

final _BookingDetailMock _mock = _BookingDetailMock(
  ref: 'SLF542891',
  carName: 'Mercedes AMG GT',
  carImageUrl: 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80',
  brand: 'Mercedes',
  plateNumber: '12345',
  plateCode: 'A',
  pickupLocation: 'Muscat International Airport, Oman',
  dropoffLocation: 'Muscat International Airport, Oman',
  start: DateTime.now().add(const Duration(days: 2)),
  end: DateTime.now().add(const Duration(days: 5)),
  pricePerDay: 250,
  extrasPerDay: 10,
  deliveryFee: 10,
  paymentMethod: 'Visa ••••4242',
  stage: _BookingTimelineStage.confirmed,
  driverName: 'Ahmed Al-Farsi',
  driverAvatar: 'https://randomuser.me/api/portraits/men/32.jpg',
  driverPhone: '+96890000001',
);

// ============================================================
// SCREEN
// ============================================================

class BookingDetailScreen extends StatefulWidget {
  final String bookingId;
  const BookingDetailScreen({super.key, required this.bookingId});

  @override
  State<BookingDetailScreen> createState() => _BookingDetailScreenState();
}

class _BookingDetailScreenState extends State<BookingDetailScreen> {
  bool get _isDark {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(MediaQuery.of(context).size.width);
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  // ==========================================================================
  // MOBILE
  // ==========================================================================

  Widget _buildMobileLayout() {
    final isDark = _isDark;
    final cs = Theme.of(context).colorScheme;
    final b = _mock;

    return Stack(
      children: [
        CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              pinned: true,
              toolbarHeight: 64.r,
              backgroundColor: Colors.transparent,
              surfaceTintColor: Colors.transparent,
              elevation: 0,
              leading: Padding(
                padding: EdgeInsetsDirectional.only(start: 12.r),
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Center(
                    child: Container(
                      width: 38.r,
                      height: 38.r,
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.07),
                        ),
                      ),
                      child: Icon(CupertinoIcons.back, color: cs.onSurface, size: 18.r),
                    ),
                  ),
                ),
              ),
              flexibleSpace: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isDark ? Colors.black.withValues(alpha: 0.55) : Colors.white.withValues(alpha: 0.72),
                      border: Border(
                        bottom: BorderSide(
                          color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.07),
                          width: 0.8,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              title: Text(
                'booking_detail_title'.tr(),
                style: TextStyle(fontSize: 17.r, fontWeight: FontWeight.bold, color: cs.onSurface),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.fromLTRB(16.r, 4.r, 16.r, 140.r),
              sliver: SliverList.list(
                children: [
                  _buildRefCard(cs, isDark, b),
                  SizedBox(height: 14.r),
                  _buildTimeline(cs, isDark, b),
                  SizedBox(height: 14.r),
                  _buildCarCard(cs, isDark, b),
                  SizedBox(height: 14.r),
                  if (b.driverName != null) ...[
                    _buildDriverCard(cs, isDark, b),
                    SizedBox(height: 14.r),
                  ],
                  _buildSchedule(cs, isDark, b),
                  SizedBox(height: 14.r),
                  _buildLocationMap(cs, isDark, b),
                  SizedBox(height: 14.r),
                  _buildPriceCard(cs, isDark, b),
                  SizedBox(height: 14.r),
                  _buildQrCard(cs, isDark, b),
                  SizedBox(height: 14.r),
                  _buildCancelButton(cs, isDark),
                ],
              ),
            ),
          ],
        ),
        Positioned(left: 0, right: 0, bottom: 0, child: _buildActionBar(cs, isDark, b)),
      ],
    );
  }

  // ==========================================================================
  // DESKTOP
  // ==========================================================================

  Widget _buildDesktopLayout() {
    final isDark = _isDark;
    final cs = Theme.of(context).colorScheme;
    final b = _mock;

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
                    'booking_detail_title'.tr(),
                    style: TextStyle(fontSize: 24.r, fontWeight: FontWeight.bold, color: cs.onSurface),
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
                        _buildRefCard(cs, isDark, b),
                        SizedBox(height: 16.r),
                        _buildTimeline(cs, isDark, b),
                        SizedBox(height: 16.r),
                        _buildCarCard(cs, isDark, b),
                        SizedBox(height: 16.r),
                        _buildLocationMap(cs, isDark, b),
                      ],
                    ),
                  ),
                  SizedBox(width: 20.r),
                  Expanded(
                    flex: 2,
                    child: Column(
                      children: [
                        _buildSchedule(cs, isDark, b),
                        SizedBox(height: 16.r),
                        if (b.driverName != null) ...[
                          _buildDriverCard(cs, isDark, b),
                          SizedBox(height: 16.r),
                        ],
                        _buildPriceCard(cs, isDark, b),
                        SizedBox(height: 16.r),
                        _buildQrCard(cs, isDark, b),
                        SizedBox(height: 16.r),
                        _buildActionRow(cs, isDark, b),
                        SizedBox(height: 12.r),
                        _buildCancelButton(cs, isDark),
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

  // ==========================================================================
  // CARDS
  // ==========================================================================

  Widget _buildRefCard(ColorScheme cs, bool isDark, _BookingDetailMock b) {
    return Container(
      padding: EdgeInsets.all(18.r),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.r),
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF1A237E), const Color(0xFF311B92)]
              : [const Color(0xFF0C2485), const Color(0xFF3D5AFE)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: cs.primary.withValues(alpha: 0.3),
            blurRadius: 20.r,
            offset: Offset(0, 8.r),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(right: -20.r, top: -20.r, child: _deco(120.r, 0.06)),
          Positioned(right: 40.r, bottom: -40.r, child: _deco(90.r, 0.04)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 4.r),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6.r),
                      border: Border.all(color: const Color(0xFF4CAF50).withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.r,
                          height: 6.r,
                          decoration: const BoxDecoration(color: Color(0xFF81C784), shape: BoxShape.circle),
                        ),
                        SizedBox(width: 5.r),
                        Text(
                          _stageLabel(b.stage).tr(),
                          style: TextStyle(fontSize: 10.r, color: const Color(0xFF81C784), fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'booking_detail_ref'.tr(),
                    style: TextStyle(
                      fontSize: 10.r,
                      color: Colors.white.withValues(alpha: 0.6),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.r),
              Text(
                b.ref,
                style: TextStyle(
                  fontSize: 24.r,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                  letterSpacing: 1.4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimeline(ColorScheme cs, bool isDark, _BookingDetailMock b) {
    const stages = _BookingTimelineStage.values;
    return _glassCard(
      isDark,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(cs, Iconsax.activity_copy, const Color(0xFF3D5AFE), 'booking_detail_timeline'.tr(), isDark),
            SizedBox(height: 16.r),
            Row(
              children: List.generate(stages.length, (i) {
                final completed = stages.indexOf(b.stage) >= i;
                final active = stages.indexOf(b.stage) == i;
                return Expanded(
                  child: Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 26.r,
                            height: 26.r,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: completed ? cs.primary : (isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05)),
                              boxShadow: active
                                  ? [
                                      BoxShadow(
                                        color: cs.primary.withValues(alpha: 0.4),
                                        blurRadius: 8.r,
                                        offset: Offset(0, 3.r),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              completed ? Iconsax.tick_circle_copy : _stageIcon(stages[i]),
                              size: 13.r,
                              color: completed ? Colors.white : cs.onSurface.withValues(alpha: 0.4),
                            ),
                          ),
                          SizedBox(height: 6.r),
                          Text(
                            _stageLabel(stages[i]).tr(),
                            style: TextStyle(
                              fontSize: 9.r,
                              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                              color: completed ? cs.primary : cs.onSurface.withValues(alpha: 0.5),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                      if (i < stages.length - 1)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsetsDirectional.only(bottom: 22.r, start: 4.r, end: 4.r),
                            child: Container(
                              height: 2,
                              color: completed
                                  ? cs.primary
                                  : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05)),
                            ),
                          ),
                        ),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCarCard(ColorScheme cs, bool isDark, _BookingDetailMock b) {
    return _glassCard(
      isDark,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(14.r),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(14.r),
                  child: CachedNetworkImage(
                    imageUrl: b.carImageUrl,
                    width: 90.r,
                    height: 72.r,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => Container(
                      width: 90.r,
                      height: 72.r,
                      color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFEEEEEE),
                      child: Icon(Iconsax.car_copy, size: 28.r, color: cs.primary),
                    ),
                  ),
                ),
                SizedBox(width: 14.r),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        b.carName,
                        style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                      ),
                      SizedBox(height: 3.r),
                      Text(
                        b.brand,
                        style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.55)),
                      ),
                      SizedBox(height: 6.r),
                      Row(
                        children: [
                          OmrIcon(size: 11.r, color: cs.primary),
                          SizedBox(width: 3.r),
                          Text(
                            '${b.pricePerDay.toInt()}/d',
                            style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w800, color: cs.primary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14.r, 0, 14.r, 14.r),
            child: Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'booking_detail_plate'.tr(),
                      style: TextStyle(
                        fontSize: 11.r,
                        color: cs.onSurface.withValues(alpha: 0.55),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  OmanPlate(number: b.plateNumber, code: b.plateCode, width: 120),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDriverCard(ColorScheme cs, bool isDark, _BookingDetailMock b) {
    return _glassCard(
      isDark,
      child: Padding(
        padding: EdgeInsets.all(14.r),
        child: Row(
          children: [
            CachedNetworkImage(
              imageUrl: b.driverAvatar!,
              imageBuilder: (_, img) => Container(
                width: 48.r,
                height: 48.r,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(image: img, fit: BoxFit.cover),
                  border: Border.all(color: cs.primary.withValues(alpha: 0.3), width: 2),
                ),
              ),
              errorWidget: (_, _, _) => CircleAvatar(
                radius: 24.r,
                backgroundColor: isDark ? const Color(0xFF2A2A3A) : const Color(0xFFEEEEEE),
                child: Icon(Iconsax.user_copy, size: 20.r, color: cs.primary),
              ),
            ),
            SizedBox(width: 12.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'booking_detail_driver'.tr(),
                    style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.5)),
                  ),
                  SizedBox(height: 2.r),
                  Text(
                    b.driverName!,
                    style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => ContactLauncher.openWhatsApp(b.driverPhone ?? '', message: 'Hi, regarding booking ${b.ref}'),
              child: Container(
                width: 40.r,
                height: 40.r,
                margin: EdgeInsetsDirectional.only(end: 8.r),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366).withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(Iconsax.message_copy, color: const Color(0xFF25D366), size: 17.r),
              ),
            ),
            GestureDetector(
              onTap: () => ContactLauncher.openPhoneCall(b.driverPhone ?? ''),
              child: Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(
                  color: cs.primary.withValues(alpha: isDark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(11.r),
                ),
                child: Icon(Iconsax.call_copy, color: cs.primary, size: 17.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSchedule(ColorScheme cs, bool isDark, _BookingDetailMock b) {
    return _glassCard(
      isDark,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(cs, Iconsax.calendar_2_copy, const Color(0xFF7C4DFF), 'booking_summary_schedule'.tr(), isDark),
            SizedBox(height: 12.r),
            Row(
              children: [
                Expanded(
                  child: _miniBlock(cs, isDark, 'booking_summary_pickup_date'.tr(), _formatDate(b.start)),
                ),
                SizedBox(width: 10.r),
                Expanded(
                  child: _miniBlock(cs, isDark, 'booking_summary_return_date'.tr(), _formatDate(b.end)),
                ),
              ],
            ),
            SizedBox(height: 10.r),
            _miniBlock(cs, isDark, 'booking_summary_days'.tr(), '${b.days} ${'booking_dates_days'.tr()}'),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationMap(ColorScheme cs, bool isDark, _BookingDetailMock b) {
    return _glassCard(
      isDark,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(cs, Iconsax.location_copy, const Color(0xFFE91E63), 'booking_detail_logistics'.tr(), isDark),
            SizedBox(height: 12.r),
            Container(
              height: 160.r,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(
                  color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
                ),
              ),
              child: Stack(
                children: [
                  Center(
                    child: Icon(Iconsax.map_1_copy, size: 48.r, color: cs.primary.withValues(alpha: 0.2)),
                  ),
                  Positioned(
                    left: 12.r,
                    bottom: 12.r,
                    right: 12.r,
                    child: Container(
                      padding: EdgeInsets.all(10.r),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.black.withValues(alpha: 0.7) : Colors.white.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        b.pickupLocation,
                        style: TextStyle(fontSize: 11.r, color: cs.onSurface, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.r),
            _row(cs, 'booking_summary_pickup_at'.tr(), b.pickupLocation),
            _row(cs, 'booking_summary_delivery_to'.tr(), b.dropoffLocation),
          ],
        ),
      ),
    );
  }

  Widget _buildPriceCard(ColorScheme cs, bool isDark, _BookingDetailMock b) {
    return _glassCard(
      isDark,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _sectionHeader(cs, Iconsax.receipt_item_copy, const Color(0xFF00BCD4), 'booking_summary_price'.tr(), isDark),
            SizedBox(height: 12.r),
            _priceRow(cs, '${b.pricePerDay.toInt()} × ${b.days} ${'booking_dates_days'.tr()}', b.pricePerDay * b.days),
            if (b.extrasPerDay > 0)
              _priceRow(cs, 'booking_summary_extras'.tr(), b.extrasPerDay * b.days),
            if (b.deliveryFee > 0) _priceRow(cs, 'booking_summary_delivery_fee'.tr(), b.deliveryFee),
            _priceRow(cs, 'booking_summary_vat'.tr(), b.vat),
            Divider(
              height: 20.r,
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
            ),
            Row(
              children: [
                Text(
                  'booking_summary_total'.tr(),
                  style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                ),
                const Spacer(),
                OmrIcon(size: 14.r, color: cs.primary),
                SizedBox(width: 3.r),
                Text(
                  b.total.toStringAsFixed(2),
                  style: TextStyle(fontSize: 20.r, fontWeight: FontWeight.w900, color: cs.primary),
                ),
              ],
            ),
            SizedBox(height: 10.r),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 6.r),
              decoration: BoxDecoration(
                color: cs.primary.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Iconsax.card_copy, size: 12.r, color: cs.primary),
                  SizedBox(width: 5.r),
                  Text(
                    'booking_detail_paid_with'.tr(args: [b.paymentMethod]),
                    style: TextStyle(fontSize: 10.r, color: cs.primary, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQrCard(ColorScheme cs, bool isDark, _BookingDetailMock b) {
    return _glassCard(
      isDark,
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'booking_detail_qr_title'.tr(),
                    style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                  ),
                  SizedBox(height: 4.r),
                  Text(
                    'booking_detail_qr_subtitle'.tr(),
                    style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.55), height: 1.4),
                  ),
                ],
              ),
            ),
            SizedBox(width: 14.r),
            Container(
              width: 80.r,
              height: 80.r,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.black12),
              ),
              child: CustomPaint(painter: _QrMockPainter(seed: b.ref.hashCode)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBar(ColorScheme cs, bool isDark, _BookingDetailMock b) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: EdgeInsets.fromLTRB(20.r, 12.r, 20.r, 12.r + MediaQuery.of(context).padding.bottom),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1A1A28).withValues(alpha: 0.92) : Colors.white.withValues(alpha: 0.92),
            border: Border(
              top: BorderSide(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
              ),
            ),
          ),
          child: _buildActionRow(cs, isDark, b),
        ),
      ),
    );
  }

  Widget _buildActionRow(ColorScheme cs, bool isDark, _BookingDetailMock b) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => context.push('/profile/edit'),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14.r),
              decoration: BoxDecoration(
                color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(14.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.calendar_edit_copy, size: 16.r, color: cs.onSurface),
                  SizedBox(width: 6.r),
                  Text(
                    'booking_detail_reschedule'.tr(),
                    style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(width: 10.r),
        Expanded(
          child: GestureDetector(
            onTap: () =>
                ContactLauncher.openPhoneCall(b.driverPhone ?? '+96890000000'),
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14.r),
              decoration: BoxDecoration(
                gradient: primaryGradient,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0C2485).withValues(alpha: 0.3),
                    blurRadius: 10.r,
                    offset: Offset(0, 4.r),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Iconsax.call_copy, size: 16.r, color: Colors.white),
                  SizedBox(width: 6.r),
                  Text(
                    'booking_detail_contact'.tr(),
                    style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w700, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCancelButton(ColorScheme cs, bool isDark) {
    return GestureDetector(
      onTap: () => _confirmCancel(),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 14.r),
        decoration: BoxDecoration(
          color: const Color(0xFFE53935).withValues(alpha: isDark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: const Color(0xFFE53935).withValues(alpha: 0.25)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Iconsax.close_circle_copy, size: 16.r, color: const Color(0xFFE53935)),
            SizedBox(width: 6.r),
            Text(
              'booking_detail_cancel'.tr(),
              style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: const Color(0xFFE53935)),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================================
  // HELPERS
  // ==========================================================================

  Widget _glassCard(bool isDark, {required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _sectionHeader(ColorScheme cs, IconData icon, Color color, String title, bool isDark) {
    return Row(
      children: [
        Container(
          width: 30.r,
          height: 30.r,
          decoration: BoxDecoration(
            color: color.withValues(alpha: isDark ? 0.2 : 0.12),
            borderRadius: BorderRadius.circular(9.r),
          ),
          child: Icon(icon, size: 15.r, color: color),
        ),
        SizedBox(width: 10.r),
        Text(
          title,
          style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
        ),
      ],
    );
  }

  Widget _miniBlock(ColorScheme cs, bool isDark, String label, String value) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.5))),
          SizedBox(height: 4.r),
          Text(value, style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface)),
        ],
      ),
    );
  }

  Widget _row(ColorScheme cs, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.r),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.r,
            child: Text(label, style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.55))),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w600, color: cs.onSurface)),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(ColorScheme cs, String label, double amount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 3.r),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.6))),
          ),
          OmrIcon(size: 11.r, color: cs.onSurface.withValues(alpha: 0.7)),
          SizedBox(width: 2.r),
          Text(amount.toStringAsFixed(2), style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w700, color: cs.onSurface)),
        ],
      ),
    );
  }

  Widget _deco(double size, double alpha) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: alpha),
        ),
      );

  String _stageLabel(_BookingTimelineStage s) {
    switch (s) {
      case _BookingTimelineStage.confirmed:
        return 'booking_detail_stage_confirmed';
      case _BookingTimelineStage.pickedUp:
        return 'booking_detail_stage_pickedup';
      case _BookingTimelineStage.inTrip:
        return 'booking_detail_stage_intrip';
      case _BookingTimelineStage.returned:
        return 'booking_detail_stage_returned';
    }
  }

  IconData _stageIcon(_BookingTimelineStage s) {
    switch (s) {
      case _BookingTimelineStage.confirmed:
        return Iconsax.tick_circle_copy;
      case _BookingTimelineStage.pickedUp:
        return Iconsax.key_copy;
      case _BookingTimelineStage.inTrip:
        return Iconsax.route_square_copy;
      case _BookingTimelineStage.returned:
        return Iconsax.flag_copy;
    }
  }

  String _formatDate(DateTime d) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  void _confirmCancel() {
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
}

// ============================================================
// DECORATIVE QR (pattern only — not a real code)
// ============================================================

class _QrMockPainter extends CustomPainter {
  final int seed;
  _QrMockPainter({required this.seed});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.black;
    final s = size.width;
    const grid = 12;
    final cell = s / grid;
    final rng = _Rand(seed);
    for (var y = 0; y < grid; y++) {
      for (var x = 0; x < grid; x++) {
        if (rng.nextBool()) {
          canvas.drawRect(Rect.fromLTWH(x * cell, y * cell, cell, cell), paint);
        }
      }
    }
    // Draw corner markers
    final markerPaint = Paint()..color = Colors.black;
    void marker(double dx, double dy) {
      canvas.drawRect(Rect.fromLTWH(dx, dy, cell * 3, cell * 3), markerPaint);
      canvas.drawRect(Rect.fromLTWH(dx + cell * 0.6, dy + cell * 0.6, cell * 1.8, cell * 1.8),
          Paint()..color = Colors.white);
      canvas.drawRect(Rect.fromLTWH(dx + cell, dy + cell, cell, cell), markerPaint);
    }
    marker(0, 0);
    marker(s - cell * 3, 0);
    marker(0, s - cell * 3);
  }

  @override
  bool shouldRepaint(covariant _QrMockPainter oldDelegate) => false;
}

class _Rand {
  int _state;
  _Rand(int seed) : _state = seed == 0 ? 1 : seed;
  bool nextBool() {
    _state = (_state * 1103515245 + 12345) & 0x7fffffff;
    return (_state % 2) == 0;
  }
}
