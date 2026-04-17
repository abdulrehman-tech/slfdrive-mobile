import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../widgets/omr_icon.dart';
import '../models/booking_data.dart';
import '../widgets/booking_glass_card.dart';

class SummaryStep extends StatefulWidget {
  final BookingData data;
  final bool isDark;
  const SummaryStep({super.key, required this.data, required this.isDark});

  @override
  State<SummaryStep> createState() => _SummaryStepState();
}

class _SummaryStepState extends State<SummaryStep> {
  final _promoController = TextEditingController();
  String? _promoError;

  @override
  void dispose() {
    _promoController.dispose();
    super.dispose();
  }

  void _applyPromo() {
    final code = _promoController.text.trim().toUpperCase();
    if (code.isEmpty) {
      widget.data.applyPromo(null, 0);
      setState(() => _promoError = null);
      return;
    }
    // Mock codes
    final discounts = {
      'SLF10': widget.data.pricing.total * 0.1,
      'WELCOME5': 5.0,
      'VIP20': widget.data.pricing.total * 0.2,
    };
    if (discounts.containsKey(code)) {
      widget.data.applyPromo(code, discounts[code]!);
      setState(() => _promoError = null);
    } else {
      widget.data.applyPromo(null, 0);
      setState(() => _promoError = 'booking_promo_invalid');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final d = widget.data;
    final isDark = widget.isDark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'booking_summary_title'.tr(),
          style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.bold, color: cs.onSurface, height: 1.2),
        ),
        SizedBox(height: 6.r),
        Text(
          'booking_summary_subtitle'.tr(),
          style: TextStyle(fontSize: 13.r, color: cs.onSurface.withValues(alpha: 0.55), height: 1.4),
        ),
        SizedBox(height: 18.r),

        // Service subject summary card (car, driver, both)
        _buildSubjectCard(cs, isDark, d),
        SizedBox(height: 12.r),

        // Dates card
        BookingGlassCard(
          isDark: isDark,
          padding: EdgeInsets.all(14.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookingSectionHeader(
                icon: Iconsax.calendar_2_copy,
                iconColor: const Color(0xFF3D5AFE),
                title: 'booking_summary_schedule'.tr(),
                isDark: isDark,
              ),
              SizedBox(height: 10.r),
              _row(cs, 'booking_summary_pickup_date'.tr(), _formatDate(d.startAt)),
              _row(cs, 'booking_summary_return_date'.tr(), _formatDate(d.endAt)),
              _row(cs, 'booking_summary_days'.tr(), '${d.days}'),
            ],
          ),
        ),
        SizedBox(height: 12.r),

        // Location card
        BookingGlassCard(
          isDark: isDark,
          padding: EdgeInsets.all(14.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookingSectionHeader(
                icon: Iconsax.location_copy,
                iconColor: const Color(0xFFE91E63),
                title: 'booking_summary_logistics'.tr(),
                isDark: isDark,
              ),
              SizedBox(height: 10.r),
              _row(
                cs,
                'booking_summary_mode'.tr(),
                d.pickupMode == PickupMode.selfPickup
                    ? 'booking_pickup_self'.tr()
                    : 'booking_pickup_delivery'.tr(),
              ),
              _row(
                cs,
                d.pickupMode == PickupMode.selfPickup
                    ? 'booking_summary_pickup_at'.tr()
                    : 'booking_summary_delivery_to'.tr(),
                (d.pickupMode == PickupMode.selfPickup
                        ? (d.pickupLocation?.address ?? 'Owner location')
                        : (d.deliveryLocation?.address ?? 'Set address')),
                multi: true,
              ),
              if (d.deliveryNotes.isNotEmpty && d.pickupMode == PickupMode.delivery)
                _row(cs, 'booking_summary_notes'.tr(), d.deliveryNotes, multi: true),
            ],
          ),
        ),

        if (d.selectedExtras.isNotEmpty) ...[
          SizedBox(height: 12.r),
          BookingGlassCard(
            isDark: isDark,
            padding: EdgeInsets.all(14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BookingSectionHeader(
                  icon: Iconsax.additem_copy,
                  iconColor: const Color(0xFF7C4DFF),
                  title: 'booking_summary_extras'.tr(),
                  isDark: isDark,
                ),
                SizedBox(height: 10.r),
                ...d.selectedExtras.map((id) {
                  final extra = kBookingExtras.firstWhere((e) => e.id == id);
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4.r),
                    child: Row(
                      children: [
                        Icon(Iconsax.tick_circle_copy, size: 13.r, color: const Color(0xFF4CAF50)),
                        SizedBox(width: 6.r),
                        Expanded(
                          child: Text(
                            extra.titleKey.tr(),
                            style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.75)),
                          ),
                        ),
                        Row(
                          children: [
                            OmrIcon(size: 10.r, color: cs.onSurface.withValues(alpha: 0.55)),
                            SizedBox(width: 2.r),
                            Text(
                              '${extra.pricePerDay.toStringAsFixed(0)}/d',
                              style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.6)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],

        SizedBox(height: 12.r),

        // Promo code
        BookingGlassCard(
          isDark: isDark,
          padding: EdgeInsets.all(14.r),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BookingSectionHeader(
                icon: Iconsax.discount_shape_copy,
                iconColor: const Color(0xFFFF6D00),
                title: 'booking_summary_promo'.tr(),
                isDark: isDark,
              ),
              SizedBox(height: 10.r),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _promoController,
                      textCapitalization: TextCapitalization.characters,
                      style: TextStyle(fontSize: 13.r, color: cs.onSurface, letterSpacing: 0.8),
                      decoration: InputDecoration(
                        hintText: 'booking_promo_hint'.tr(),
                        hintStyle: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.4)),
                        filled: true,
                        fillColor: isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 10.r),
                      ),
                    ),
                  ),
                  SizedBox(width: 8.r),
                  GestureDetector(
                    onTap: _applyPromo,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 18.r, vertical: 12.r),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF0C2485), Color(0xFF677EF0)]),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'booking_promo_apply'.tr(),
                        style: TextStyle(fontSize: 12.r, color: Colors.white, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
              if (d.promoCode != null) ...[
                SizedBox(height: 8.r),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.r, vertical: 6.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withValues(alpha: isDark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Iconsax.tick_circle_copy, size: 13.r, color: const Color(0xFF4CAF50)),
                      SizedBox(width: 5.r),
                      Text(
                        '${d.promoCode} — ${'booking_promo_applied'.tr()}',
                        style: TextStyle(
                            fontSize: 11.r, color: const Color(0xFF4CAF50), fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
              ],
              if (_promoError != null) ...[
                SizedBox(height: 8.r),
                Text(
                  _promoError!.tr(),
                  style: TextStyle(fontSize: 11.r, color: const Color(0xFFE53935), fontWeight: FontWeight.w600),
                ),
              ],
            ],
          ),
        ),

        SizedBox(height: 14.r),
        _buildPricing(cs, isDark, d),
      ],
    );
  }

  // -----------------------------------------------------------

  Widget _buildSubjectCard(ColorScheme cs, bool isDark, BookingData d) {
    return BookingGlassCard(
      isDark: isDark,
      padding: EdgeInsets.all(14.r),
      child: Column(
        children: [
          if (d.car != null)
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: CachedNetworkImage(
                    imageUrl: d.car!.imageUrl,
                    width: 72.r,
                    height: 56.r,
                    fit: BoxFit.cover,
                    errorWidget: (_, _, _) => Container(
                      width: 72.r,
                      height: 56.r,
                      color: isDark ? const Color(0xFF1E1E2E) : const Color(0xFFEEEEEE),
                      child: Icon(Iconsax.car_copy, size: 24.r, color: cs.primary),
                    ),
                  ),
                ),
                SizedBox(width: 12.r),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.car!.name,
                        style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                      ),
                      SizedBox(height: 2.r),
                      Text(
                        d.car!.brand,
                        style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.55)),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    OmrIcon(size: 12.r, color: cs.primary),
                    SizedBox(width: 3.r),
                    Text(
                      '${d.car!.pricePerDay.toStringAsFixed(0)}/d',
                      style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w800, color: cs.primary),
                    ),
                  ],
                ),
              ],
            ),
          if (d.car != null && d.driver != null)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.r),
              child: Divider(
                height: 1,
                color: isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.05),
              ),
            ),
          if (d.driver != null)
            Row(
              children: [
                CachedNetworkImage(
                  imageUrl: d.driver!.avatarUrl,
                  imageBuilder: (_, img) => Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(image: img, fit: BoxFit.cover),
                    ),
                  ),
                  errorWidget: (_, _, _) => CircleAvatar(
                    radius: 22.r,
                    backgroundColor: isDark ? const Color(0xFF2A2A3A) : const Color(0xFFEEEEEE),
                    child: Icon(Iconsax.user_copy, size: 18.r, color: cs.primary),
                  ),
                ),
                SizedBox(width: 12.r),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        d.driver!.name,
                        style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700, color: cs.onSurface),
                      ),
                      SizedBox(height: 2.r),
                      Row(
                        children: [
                          Icon(Iconsax.star_1_copy, size: 11.r, color: const Color(0xFFFFC107)),
                          SizedBox(width: 2.r),
                          Text(
                            '${d.driver!.rating} · ${d.driver!.speciality}',
                            style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.55)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    OmrIcon(size: 11.r, color: cs.primary),
                    SizedBox(width: 3.r),
                    Text(
                      '${d.driver!.pricePerDay.toStringAsFixed(0)}/d',
                      style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w800, color: cs.primary),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildPricing(ColorScheme cs, bool isDark, BookingData d) {
    final p = d.pricing;
    return BookingGlassCard(
      isDark: isDark,
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookingSectionHeader(
            icon: Iconsax.receipt_item_copy,
            iconColor: const Color(0xFF00BCD4),
            title: 'booking_summary_price'.tr(),
            isDark: isDark,
          ),
          SizedBox(height: 12.r),
          _priceRow(cs, '${p.basePerDay.toStringAsFixed(0)} × ${p.days} ${'booking_dates_days'.tr()}',
              p.basePerDay * p.days),
          if (p.extrasPerDay > 0)
            _priceRow(cs, 'booking_summary_extras'.tr(), p.extrasPerDay * p.days),
          if (p.deliveryFee > 0) _priceRow(cs, 'booking_summary_delivery_fee'.tr(), p.deliveryFee),
          _priceRow(cs, 'booking_summary_vat'.tr(), p.vat),
          if (d.promoCode != null)
            _priceRow(cs, 'booking_summary_discount'.tr() + ' (${d.promoCode})', -d.promoDiscount,
                highlight: const Color(0xFF4CAF50)),
          SizedBox(height: 10.r),
          Divider(
            height: 1,
            color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.06),
          ),
          SizedBox(height: 10.r),
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
                d.totalPrice.toStringAsFixed(2),
                style: TextStyle(fontSize: 22.r, fontWeight: FontWeight.w900, color: cs.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _row(ColorScheme cs, String label, String value, {bool multi = false}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.r),
      child: Row(
        crossAxisAlignment: multi ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: 110.r,
            child: Text(
              label,
              style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.55)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w600, color: cs.onSurface),
            ),
          ),
        ],
      ),
    );
  }

  Widget _priceRow(ColorScheme cs, String label, double amount, {Color? highlight}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.r),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(fontSize: 12.r, color: cs.onSurface.withValues(alpha: 0.6)),
            ),
          ),
          OmrIcon(size: 11.r, color: highlight ?? cs.onSurface.withValues(alpha: 0.7)),
          SizedBox(width: 2.r),
          Text(
            amount.toStringAsFixed(2),
            style: TextStyle(
              fontSize: 12.r,
              fontWeight: FontWeight.w700,
              color: highlight ?? cs.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? d) {
    if (d == null) return '-';
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}
