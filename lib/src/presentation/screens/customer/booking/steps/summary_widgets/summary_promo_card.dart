import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../models/booking_data.dart';
import '../../widgets/booking_glass_card.dart';

class SummaryPromoCard extends StatefulWidget {
  final BookingData data;
  final bool isDark;
  final VoidCallback onApplied;
  const SummaryPromoCard({
    super.key,
    required this.data,
    required this.isDark,
    required this.onApplied,
  });

  @override
  State<SummaryPromoCard> createState() => _SummaryPromoCardState();
}

class _SummaryPromoCardState extends State<SummaryPromoCard> {
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
      widget.onApplied();
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
    widget.onApplied();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final isDark = widget.isDark;
    final d = widget.data;

    return BookingGlassCard(
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
    );
  }
}
