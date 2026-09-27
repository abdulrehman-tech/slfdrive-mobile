import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/data/repositories/promo_code_repository.dart';
import '../../../../../../core/di/injection_container.dart';
import '../../../../../../core/models/promo/promo_code.dart';
import '../../../../../widgets/omr_icon.dart';
import '../../models/booking_data.dart';
import '../../provider/booking_flow_provider.dart';
import '../../widgets/booking_glass_card.dart';

/// Promo code entry on the review step. The code is validated with the server,
/// then re-quoted so the price card shows the server's discount; offers the
/// customer can use are listed as tappable chips when the API exposes them.
class SummaryPromoCard extends StatefulWidget {
  final BookingData data;
  final bool isDark;
  const SummaryPromoCard({super.key, required this.data, required this.isDark});

  @override
  State<SummaryPromoCard> createState() => _SummaryPromoCardState();
}

class _SummaryPromoCardState extends State<SummaryPromoCard> {
  final _controller = TextEditingController();
  List<PromoOffer> _offers = const [];

  static const _green = Color(0xFF2E9E57);

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    try {
      final offers = await getIt<PromoCodeRepository>().active();
      if (mounted) setState(() => _offers = offers);
    } catch (_) {
      // Listing offers is optional; manual entry still works.
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _apply(String code) async {
    FocusScope.of(context).unfocus();
    final ok = await context.read<BookingFlowProvider>().applyPromo(code);
    if (ok && mounted) _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final d = widget.data;
    final quote = d.quote;
    final applied = d.promoCode != null && (quote?.hasPromo ?? false);
    final now = DateTime.now();
    final offers = _offers.where((o) => o.appliesTo(quote?.rentalCompanyId, now) && o.code != d.promoCode).toList();

    return BookingGlassCard(
      isDark: widget.isDark,
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          BookingSectionHeader(
            icon: Iconsax.ticket_discount_copy,
            iconColor: _green,
            title: 'promo_title'.tr(),
            isDark: widget.isDark,
          ),
          SizedBox(height: 12.r),
          if (applied) _appliedRow(cs, quote!.promoCode ?? d.promoCode!, quote.discountAmount) else _entryRow(cs, d),
          if (d.promoError != null) ...[
            SizedBox(height: 8.r),
            Row(
              children: [
                Icon(Iconsax.info_circle_copy, size: 14.r, color: cs.error),
                SizedBox(width: 6.r),
                Expanded(
                  child: Text(
                    d.promoError!.tr(),
                    style: TextStyle(fontSize: 11.r, color: cs.error, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
          if (!applied && offers.isNotEmpty) ...[
            SizedBox(height: 12.r),
            Text(
              'promo_available'.tr(),
              style: TextStyle(fontSize: 11.r, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.55)),
            ),
            SizedBox(height: 8.r),
            Wrap(
              spacing: 8.r,
              runSpacing: 8.r,
              children: [for (final o in offers) _offerChip(cs, o, d.promoApplying)],
            ),
          ],
        ],
      ),
    );
  }

  Widget _entryRow(ColorScheme cs, BookingData d) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _controller,
            enabled: !d.promoApplying,
            textCapitalization: TextCapitalization.characters,
            // Codes are case-insensitive server-side; show them as they'll be
            // matched, whatever keyboard case the customer types in.
            inputFormatters: [_UpperCaseFormatter()],
            textInputAction: TextInputAction.done,
            onSubmitted: _apply,
            style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: cs.onSurface),
            decoration: InputDecoration(
              isDense: true,
              hintText: 'promo_hint'.tr(),
              hintStyle: TextStyle(fontSize: 13.r, letterSpacing: 0, fontWeight: FontWeight.w500, color: cs.onSurface.withValues(alpha: 0.4)),
              filled: true,
              fillColor: widget.isDark ? Colors.white.withValues(alpha: 0.06) : Colors.black.withValues(alpha: 0.04),
              contentPadding: EdgeInsets.symmetric(horizontal: 14.r, vertical: 13.r),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r), borderSide: BorderSide.none),
            ),
          ),
        ),
        SizedBox(width: 10.r),
        SizedBox(
          height: 46.r,
          child: FilledButton(
            onPressed: d.promoApplying ? null : () => _apply(_controller.text),
            style: FilledButton.styleFrom(
              backgroundColor: cs.primary,
              padding: EdgeInsets.symmetric(horizontal: 18.r),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: d.promoApplying
                ? SizedBox(width: 18.r, height: 18.r, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text('promo_apply'.tr(), style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700)),
          ),
        ),
      ],
    );
  }

  Widget _appliedRow(ColorScheme cs, String code, double saved) {
    final style = TextStyle(fontSize: 12.r, color: _green, fontWeight: FontWeight.w600);
    return Container(
      padding: EdgeInsets.fromLTRB(14.r, 10.r, 6.r, 10.r),
      decoration: BoxDecoration(
        color: _green.withValues(alpha: widget.isDark ? 0.16 : 0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: _green.withValues(alpha: 0.35)),
      ),
      child: Row(
        children: [
          Icon(Iconsax.tick_circle, size: 18.r, color: _green),
          SizedBox(width: 10.r),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(code, style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: cs.onSurface)),
                SizedBox(height: 2.r),
                Text.rich(
                  TextSpan(style: style, children: [
                    TextSpan(text: '${'promo_you_save'.tr()} '),
                    omrSpan(style, gap: 2),
                    TextSpan(text: saved.toStringAsFixed(2)),
                  ]),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.read<BookingFlowProvider>().removePromo(),
            child: Text('promo_remove'.tr(), style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w700, color: cs.error)),
          ),
        ],
      ),
    );
  }

  Widget _offerChip(ColorScheme cs, PromoOffer o, bool busy) {
    final label = o.isPercentage ? '${o.discountValue.toStringAsFixed(0)}%' : o.discountValue.toStringAsFixed(2);
    return InkWell(
      borderRadius: BorderRadius.circular(20.r),
      onTap: busy ? null : () => _apply(o.code),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.r, vertical: 7.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: _green.withValues(alpha: 0.5), style: BorderStyle.solid),
          color: _green.withValues(alpha: widget.isDark ? 0.1 : 0.05),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Iconsax.ticket_discount_copy, size: 14.r, color: _green),
            SizedBox(width: 6.r),
            Text(o.code, style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w800, color: cs.onSurface)),
            SizedBox(width: 6.r),
            if (o.isPercentage)
              Text('−$label', style: TextStyle(fontSize: 11.r, fontWeight: FontWeight.w700, color: _green))
            else
              OmrAmount('−$label', style: TextStyle(fontSize: 11.r, fontWeight: FontWeight.w700, color: _green), gap: 2),
          ],
        ),
      ),
    );
  }
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}
