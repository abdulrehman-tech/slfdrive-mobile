import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../widgets/omr_icon.dart';
import '../../../../constants/breakpoints.dart';
import '../../../../constants/color_constants.dart';
import '../../../providers/theme_provider.dart';

// ============================================================
// MOCK DATA
// ============================================================

enum BookingStatus { confirmed, inProgress, completed, cancelled }

class _BookingItem {
  final String carName;
  final String carImageUrl;
  final String pickupDate;
  final String dropoffDate;
  final String pickupLocation;
  final double totalPrice;
  final BookingStatus status;
  final String? driverName;
  final String? driverAvatarUrl;

  const _BookingItem({
    required this.carName,
    required this.carImageUrl,
    required this.pickupDate,
    required this.dropoffDate,
    required this.pickupLocation,
    required this.totalPrice,
    required this.status,
    this.driverName,
    this.driverAvatarUrl,
  });
}

final List<_BookingItem> _mockBookings = [
  _BookingItem(
    carName: 'Mercedes AMG GT',
    carImageUrl: 'https://images.unsplash.com/photo-1617814076367-b759c7d7e738?w=800&q=80',
    pickupDate: 'Jan 15, 2025',
    dropoffDate: 'Jan 18, 2025',
    pickupLocation: 'Muscat Airport',
    totalPrice: 750,
    status: BookingStatus.confirmed,
    driverName: 'Ahmed Al-Farsi',
    driverAvatarUrl: 'https://randomuser.me/api/portraits/men/32.jpg',
  ),
  _BookingItem(
    carName: 'BMW M4 Competition',
    carImageUrl: 'https://images.unsplash.com/photo-1555215695-3004980ad54e?w=800&q=80',
    pickupDate: 'Jan 10, 2025',
    dropoffDate: 'Jan 12, 2025',
    pickupLocation: 'Downtown Muscat',
    totalPrice: 380,
    status: BookingStatus.inProgress,
  ),
  _BookingItem(
    carName: 'Porsche 911 Turbo S',
    carImageUrl: 'https://images.unsplash.com/photo-1503376780353-7e6692767b70?w=800&q=80',
    pickupDate: 'Dec 20, 2024',
    dropoffDate: 'Dec 23, 2024',
    pickupLocation: 'Grand Mall',
    totalPrice: 960,
    status: BookingStatus.completed,
    driverName: 'Mohammed K.',
    driverAvatarUrl: 'https://randomuser.me/api/portraits/men/45.jpg',
  ),
  _BookingItem(
    carName: 'Lamborghini Huracán',
    carImageUrl: 'https://images.unsplash.com/photo-1544636331-e26879cd4d9b?w=800&q=80',
    pickupDate: 'Dec 15, 2024',
    dropoffDate: 'Dec 16, 2024',
    pickupLocation: 'Seeb',
    totalPrice: 500,
    status: BookingStatus.cancelled,
  ),
];

// ============================================================
// BOOKINGS SCREEN
// ============================================================

class BookingsScreen extends StatefulWidget {
  const BookingsScreen({super.key});

  @override
  State<BookingsScreen> createState() => _BookingsScreenState();
}

class _BookingsScreenState extends State<BookingsScreen> {
  int _tabIndex = 0;

  static const _tabs = [
    'bookings_tab_upcoming',
    'bookings_tab_active',
    'bookings_tab_completed',
    'bookings_tab_cancelled',
  ];

  static const _tabIcons = [Iconsax.calendar_tick, Iconsax.timer_1, Iconsax.tick_circle, Iconsax.close_circle];

  static const _tabColors = [Color(0xFF3D5AFE), Color(0xFFFFA726), Color(0xFF4CAF50), Color(0xFFE53935)];

  static const _statusMap = [
    BookingStatus.confirmed,
    BookingStatus.inProgress,
    BookingStatus.completed,
    BookingStatus.cancelled,
  ];

  static const _emptyTitles = [
    'bookings_empty_upcoming',
    'bookings_empty_active',
    'bookings_empty_completed',
    'bookings_empty_cancelled',
  ];

  static const _emptySubs = [
    'bookings_empty_upcoming_sub',
    'bookings_empty_active_sub',
    'bookings_empty_completed_sub',
    'bookings_empty_cancelled_sub',
  ];

  bool get _isDark {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode || (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  List<_BookingItem> get _filteredBookings => _mockBookings.where((b) => b.status == _statusMap[_tabIndex]).toList();

  @override
  Widget build(BuildContext context) {
    final isDesktop = Breakpoints.isDesktop(MediaQuery.of(context).size.width);
    return isDesktop ? _buildDesktopLayout() : _buildMobileLayout();
  }

  // ==========================================================================
  // MOBILE LAYOUT
  // ==========================================================================

  Widget _buildMobileLayout() {
    final isDark = _isDark;
    final cs = Theme.of(context).colorScheme;
    final bookings = _filteredBookings;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // App bar
        SliverAppBar(
          pinned: true,
          floating: false,
          expandedHeight: 0,
          toolbarHeight: 64.r,
          backgroundColor: Colors.transparent,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
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
          title: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.r),
            child: Text(
              'bookings_title'.tr(),
              style: TextStyle(fontSize: 20.r, fontWeight: FontWeight.bold, color: cs.onSurface),
            ),
          ),
        ),
        // Tabs
        SliverToBoxAdapter(child: _buildTabBar(isDark, cs)),
        // Content
        if (bookings.isEmpty)
          SliverFillRemaining(
            child: _BookingEmpty(
              isDark: isDark,
              cs: cs,
              title: _emptyTitles[_tabIndex].tr(),
              subtitle: _emptySubs[_tabIndex].tr(),
              icon: _tabIcons[_tabIndex],
              color: _tabColors[_tabIndex],
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.fromLTRB(16.r, 8.r, 16.r, 100.r),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (_, i) => Padding(
                  padding: EdgeInsets.only(bottom: 14.r),
                  child: _BookingCard(booking: bookings[i], isDark: isDark, cs: cs),
                ),
                childCount: bookings.length,
              ),
            ),
          ),
      ],
    );
  }

  // ==========================================================================
  // DESKTOP LAYOUT
  // ==========================================================================

  Widget _buildDesktopLayout() {
    final isDark = _isDark;
    final cs = Theme.of(context).colorScheme;
    final bookings = _filteredBookings;

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
                    style: TextStyle(fontSize: 24.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                  ),
                  const Spacer(),
                  _buildTabBar(isDark, cs, compact: true),
                ],
              ),
              SizedBox(height: 24.r),
              if (bookings.isEmpty)
                SizedBox(
                  height: 400.r,
                  child: _BookingEmpty(
                    isDark: isDark,
                    cs: cs,
                    title: _emptyTitles[_tabIndex].tr(),
                    subtitle: _emptySubs[_tabIndex].tr(),
                    icon: _tabIcons[_tabIndex],
                    color: _tabColors[_tabIndex],
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
                          child: _BookingCard(booking: b, isDark: isDark, cs: cs),
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

  // ==========================================================================
  // TAB BAR
  // ==========================================================================

  Widget _buildTabBar(bool isDark, ColorScheme cs, {bool compact = false}) {
    return Padding(
      padding: compact ? EdgeInsets.zero : EdgeInsets.fromLTRB(16.r, 16.r, 16.r, 8.r),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _tabs.asMap().entries.map((e) {
            final i = e.key;
            final active = _tabIndex == i;
            final col = _tabColors[i];
            final count = _mockBookings.where((b) => b.status == _statusMap[i]).length;

            return Padding(
              padding: EdgeInsets.only(right: 10.r),
              child: GestureDetector(
                onTap: () => setState(() => _tabIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  padding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 8.r),
                  decoration: BoxDecoration(
                    color: active
                        ? col.withValues(alpha: isDark ? 0.2 : 0.12)
                        : (isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04)),
                    borderRadius: BorderRadius.circular(14.r),
                    border: active ? Border.all(color: col.withValues(alpha: 0.3)) : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(_tabIcons[i], size: 15.r, color: active ? col : cs.onSurface.withValues(alpha: 0.5)),
                      SizedBox(width: 6.r),
                      Text(
                        e.value.tr(),
                        style: TextStyle(
                          fontSize: 12.r,
                          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          color: active ? col : cs.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      if (count > 0) ...[
                        SizedBox(width: 6.r),
                        Container(
                          width: 18.r,
                          height: 18.r,
                          decoration: BoxDecoration(
                            color: active ? col.withValues(alpha: 0.2) : cs.onSurface.withValues(alpha: 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '$count',
                              style: TextStyle(
                                fontSize: 9.r,
                                fontWeight: FontWeight.w700,
                                color: active ? col : cs.onSurface.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// ============================================================
// BOOKING CARD
// ============================================================

class _BookingCard extends StatelessWidget {
  final _BookingItem booking;
  final bool isDark;
  final ColorScheme cs;

  const _BookingCard({required this.booking, required this.isDark, required this.cs});

  Color get _statusColor {
    switch (booking.status) {
      case BookingStatus.confirmed:
        return const Color(0xFF3D5AFE);
      case BookingStatus.inProgress:
        return const Color(0xFFFFA726);
      case BookingStatus.completed:
        return const Color(0xFF4CAF50);
      case BookingStatus.cancelled:
        return const Color(0xFFE53935);
    }
  }

  String get _statusLabel {
    switch (booking.status) {
      case BookingStatus.confirmed:
        return 'bookings_status_confirmed'.tr();
      case BookingStatus.inProgress:
        return 'bookings_status_in_progress'.tr();
      case BookingStatus.completed:
        return 'bookings_status_completed'.tr();
      case BookingStatus.cancelled:
        return 'bookings_status_cancelled'.tr();
    }
  }

  IconData get _statusIcon {
    switch (booking.status) {
      case BookingStatus.confirmed:
        return Iconsax.calendar_tick;
      case BookingStatus.inProgress:
        return Iconsax.timer_1;
      case BookingStatus.completed:
        return Iconsax.tick_circle;
      case BookingStatus.cancelled:
        return Iconsax.close_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? Colors.white.withValues(alpha: 0.07) : Colors.white.withValues(alpha: 0.82),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: isDark ? Colors.white.withValues(alpha: 0.1) : Colors.black.withValues(alpha: 0.06),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                blurRadius: 20.r,
                offset: Offset(0, 6.r),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image + status badge
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(20.r), topRight: Radius.circular(20.r)),
                    child: CachedNetworkImage(
                      imageUrl: booking.carImageUrl,
                      height: 140.r,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        height: 140.r,
                        color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F0),
                        child: Center(
                          child: Icon(Iconsax.car_copy, color: cs.primary.withValues(alpha: 0.4), size: 36.r),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        height: 140.r,
                        color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFF0F0F0),
                        child: Center(
                          child: Icon(Iconsax.car_copy, color: cs.primary.withValues(alpha: 0.4), size: 36.r),
                        ),
                      ),
                    ),
                  ),
                  // Status badge
                  Positioned(
                    top: 10.r,
                    left: 10.r,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 5.r),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: isDark ? 0.3 : 0.2),
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(color: _statusColor.withValues(alpha: 0.3)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(_statusIcon, size: 12.r, color: _statusColor),
                              SizedBox(width: 4.r),
                              Text(
                                _statusLabel,
                                style: TextStyle(fontSize: 10.r, fontWeight: FontWeight.w700, color: _statusColor),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Price
                  Positioned(
                    top: 10.r,
                    right: 10.r,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.r),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 5.r),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.45),
                            borderRadius: BorderRadius.circular(10.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              OmrIcon(size: 11.r, color: Colors.white),
                              SizedBox(width: 3.r),
                              Text(
                                '${booking.totalPrice.toInt()}',
                                style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // Details
              Padding(
                padding: EdgeInsets.all(14.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Car name + driver
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            booking.carName,
                            style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (booking.driverName != null) ...[
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 8.r, vertical: 3.r),
                            decoration: BoxDecoration(
                              color: const Color(0xFF7C4DFF).withValues(alpha: isDark ? 0.15 : 0.08),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Iconsax.driver_copy, size: 11.r, color: const Color(0xFF7C4DFF)),
                                SizedBox(width: 4.r),
                                Text(
                                  'bookings_with_driver'.tr(),
                                  style: TextStyle(
                                    fontSize: 9.r,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF7C4DFF),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 12.r),
                    // Date range
                    Container(
                      padding: EdgeInsets.all(12.r),
                      decoration: BoxDecoration(
                        color: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: _DateColumn(
                              label: 'bookings_pickup'.tr(),
                              date: booking.pickupDate,
                              icon: Iconsax.calendar_add,
                              color: const Color(0xFF3D5AFE),
                              isDark: isDark,
                              cs: cs,
                            ),
                          ),
                          // Arrow
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 8.r),
                            child: Container(
                              width: 28.r,
                              height: 28.r,
                              decoration: BoxDecoration(
                                color: cs.primary.withValues(alpha: isDark ? 0.15 : 0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(CupertinoIcons.forward, size: 14.r, color: cs.primary),
                            ),
                          ),
                          Expanded(
                            child: _DateColumn(
                              label: 'bookings_dropoff'.tr(),
                              date: booking.dropoffDate,
                              icon: Iconsax.calendar_remove,
                              color: const Color(0xFFE91E63),
                              isDark: isDark,
                              cs: cs,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 12.r),
                    // Location + driver
                    Row(
                      children: [
                        Icon(Iconsax.location_copy, size: 14.r, color: cs.onSurface.withValues(alpha: 0.5)),
                        SizedBox(width: 5.r),
                        Expanded(
                          child: Text(
                            booking.pickupLocation,
                            style: TextStyle(
                              fontSize: 12.r,
                              color: cs.onSurface.withValues(alpha: 0.6),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (booking.driverName != null) ...[
                          CachedNetworkImage(
                            imageUrl: booking.driverAvatarUrl!,
                            imageBuilder: (_, img) => CircleAvatar(radius: 12.r, backgroundImage: img),
                            placeholder: (_, __) =>
                                CircleAvatar(radius: 12.r, backgroundColor: const Color(0xFFEEEEEE)),
                            errorWidget: (_, __, ___) =>
                                CircleAvatar(radius: 12.r, backgroundColor: const Color(0xFFEEEEEE)),
                          ),
                          SizedBox(width: 6.r),
                          Text(
                            booking.driverName!,
                            style: TextStyle(
                              fontSize: 11.r,
                              fontWeight: FontWeight.w600,
                              color: cs.onSurface.withValues(alpha: 0.7),
                            ),
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 14.r),
                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              if (booking.status == BookingStatus.completed ||
                                  booking.status == BookingStatus.cancelled) {
                                context.pushNamed('car-listing');
                              } else {
                                context.pushNamed(
                                  'booking-detail',
                                  pathParameters: {'id': booking.carName.hashCode.toString()},
                                );
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10.r),
                              decoration: BoxDecoration(
                                gradient: primaryGradient,
                                borderRadius: BorderRadius.circular(12.r),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF0C2485).withValues(alpha: 0.3),
                                    blurRadius: 8.r,
                                    offset: Offset(0, 3.r),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  booking.status == BookingStatus.completed || booking.status == BookingStatus.cancelled
                                      ? 'bookings_rebook'.tr()
                                      : 'bookings_view_details'.tr(),
                                  style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w700, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                        if (booking.status == BookingStatus.confirmed) ...[
                          SizedBox(width: 10.r),
                          GestureDetector(
                            onTap: () {},
                            child: Container(
                              padding: EdgeInsets.symmetric(vertical: 10.r, horizontal: 16.r),
                              decoration: BoxDecoration(
                                color: const Color(0xFFE53935).withValues(alpha: isDark ? 0.15 : 0.08),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(color: const Color(0xFFE53935).withValues(alpha: 0.2)),
                              ),
                              child: Text(
                                'bookings_cancel'.tr(),
                                style: TextStyle(
                                  fontSize: 12.r,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFFE53935),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DATE COLUMN
// ============================================================

class _DateColumn extends StatelessWidget {
  final String label;
  final String date;
  final IconData icon;
  final Color color;
  final bool isDark;
  final ColorScheme cs;

  const _DateColumn({
    required this.label,
    required this.date,
    required this.icon,
    required this.color,
    required this.isDark,
    required this.cs,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 13.r, color: color),
            SizedBox(width: 4.r),
            Text(
              label,
              style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.5), fontWeight: FontWeight.w500),
            ),
          ],
        ),
        SizedBox(height: 3.r),
        Text(
          date,
          style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w700, color: cs.onSurface),
        ),
      ],
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _BookingEmpty extends StatelessWidget {
  final bool isDark;
  final ColorScheme cs;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;

  const _BookingEmpty({
    required this.isDark,
    required this.cs,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90.r,
            height: 90.r,
            decoration: BoxDecoration(
              color: color.withValues(alpha: isDark ? 0.12 : 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color.withValues(alpha: 0.6), size: 40.r),
          ),
          SizedBox(height: 20.r),
          Text(
            title,
            style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.bold, color: cs.onSurface),
          ),
          SizedBox(height: 8.r),
          SizedBox(
            width: 260.r,
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.r, color: cs.onSurface.withValues(alpha: 0.5), height: 1.5),
            ),
          ),
          SizedBox(height: 24.r),
          GestureDetector(
            onTap: () => context.pushNamed('car-listing'),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 28.r, vertical: 12.r),
              decoration: BoxDecoration(
                gradient: primaryGradient,
                borderRadius: BorderRadius.circular(14.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0C2485).withValues(alpha: 0.35),
                    blurRadius: 12.r,
                    offset: Offset(0, 4.r),
                  ),
                ],
              ),
              child: Text(
                'explore_cars'.tr(),
                style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
