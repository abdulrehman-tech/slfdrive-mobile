import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../../../../core/data/repositories/promo_code_repository.dart';
import '../../../../../../core/di/injection_container.dart';
import '../../../../../../core/models/promo/promo_code.dart';
import '../../../../../utils/bidi.dart';
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
          if (!applied) ...[
            SizedBox(height: 4.r),
            Padding(
              padding: EdgeInsetsDirectional.only(start: 40.r),
              child: Text(
                'promo_subtitle'.tr(),
                style: TextStyle(fontSize: 11.r, color: cs.onSurface.withValues(alpha: 0.5), height: 1.35),
              ),
            ),
          ],
          SizedBox(height: 12.r),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            switchInCurve: Curves.easeOut,
            transitionBuilder: (child, a) => FadeTransition(
              opacity: a,
              child: SizeTransition(sizeFactor: a, axisAlignment: -1, child: child),
            ),
            child: applied
                ? KeyedSubtree(
                    key: const ValueKey('applied'),
                    child: _appliedTicket(cs, quote!.promoCode ?? d.promoCode!, quote.discountAmount),
                  )
                : KeyedSubtree(key: const ValueKey('entry'), child: _entryField(cs, d)),
          ),
          if (d.promoError != null) ...[
            SizedBox(height: 8.r),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Iconsax.info_circle_copy, size: 14.r, color: cs.error),
                SizedBox(width: 6.r),
                Expanded(
                  child: Text(
                    // Our own fallbacks are keys; server messages arrive
                    // already localised.
                    d.promoError!.startsWith('promo_') ? d.promoError!.tr() : d.promoError!,
                    style: TextStyle(fontSize: 11.r, color: cs.error, fontWeight: FontWeight.w600, height: 1.35),
                  ),
                ),
              ],
            ),
          ],
          if (!applied && offers.isNotEmpty) ...[
            SizedBox(height: 14.r),
            Text(
              'promo_available'.tr(),
              style: TextStyle(fontSize: 11.r, fontWeight: FontWeight.w700, color: cs.onSurface.withValues(alpha: 0.55)),
            ),
            SizedBox(height: 8.r),
            SizedBox(
              height: 52.r,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: offers.length,
                separatorBuilder: (_, _) => SizedBox(width: 8.r),
                itemBuilder: (_, i) => _offerCoupon(cs, offers[i], d.promoApplying),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// One field with the Apply action built into its end, so the pair can't
  /// squeeze or wrap on narrow screens / long translations.
  Widget _entryField(ColorScheme cs, BookingData d) {
    final fill = widget.isDark ? Colors.white.withValues(alpha: 0.06) : const Color(0xFFF3F4F8);
    OutlineInputBorder border(Color c, [double w = 1]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(14.r),
          borderSide: BorderSide(color: c, width: w),
        );
    return TextField(
      controller: _controller,
      enabled: !d.promoApplying,
      textCapitalization: TextCapitalization.characters,
      // Codes are case-insensitive server-side; show them as they'll be
      // matched, whatever keyboard case the customer types in.
      inputFormatters: [_UpperCaseFormatter()],
      textInputAction: TextInputAction.done,
      onSubmitted: _apply,
      style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w800, letterSpacing: 1.5, color: cs.onSurface),
      decoration: InputDecoration(
        hintText: 'promo_hint'.tr(),
        hintStyle: TextStyle(fontSize: 13.r, letterSpacing: 0, fontWeight: FontWeight.w500, color: cs.onSurface.withValues(alpha: 0.4)),
        filled: true,
        fillColor: fill,
        contentPadding: EdgeInsets.symmetric(horizontal: 4.r, vertical: 16.r),
        prefixIcon: Icon(Iconsax.ticket_copy, size: 18.r, color: cs.onSurface.withValues(alpha: 0.45)),
        suffixIcon: Padding(
          padding: EdgeInsetsDirectional.only(end: 6.r),
          child: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _controller,
            builder: (_, value, _) {
              final ready = value.text.trim().isNotEmpty && !d.promoApplying;
              return FilledButton(
                onPressed: ready ? () => _apply(_controller.text) : null,
                style: FilledButton.styleFrom(
                  backgroundColor: cs.primary,
                  disabledBackgroundColor: cs.primary.withValues(alpha: widget.isDark ? 0.25 : 0.2),
                  disabledForegroundColor: Colors.white.withValues(alpha: 0.8),
                  minimumSize: Size(0, 38.r),
                  padding: EdgeInsets.symmetric(horizontal: 16.r),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
                ),
                child: d.promoApplying
                    ? SizedBox(width: 16.r, height: 16.r, child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : Text('promo_apply'.tr(), style: TextStyle(fontSize: 13.r, fontWeight: FontWeight.w700)),
              );
            },
          ),
        ),
        suffixIconConstraints: BoxConstraints(minHeight: 38.r, maxWidth: 140.r),
        border: border(Colors.transparent),
        enabledBorder: border(d.promoError != null ? cs.error.withValues(alpha: 0.6) : Colors.transparent),
        disabledBorder: border(Colors.transparent),
        focusedBorder: border(cs.primary, 1.4),
      ),
    );
  }

  /// Applied code as a coupon: notched sides, code + saving, remove button.
  Widget _appliedTicket(ColorScheme cs, String code, double saved) {
    final dark = widget.isDark;
    final save = TextStyle(fontSize: 12.r, color: _green, fontWeight: FontWeight.w700);
    return ClipPath(
      clipper: _TicketClipper(notch: 8.r),
      child: Container(
        padding: EdgeInsetsDirectional.fromSTEB(18.r, 12.r, 8.r, 12.r),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.centerStart,
            end: AlignmentDirectional.centerEnd,
            colors: [_green.withValues(alpha: dark ? 0.26 : 0.14), _green.withValues(alpha: dark ? 0.12 : 0.05)],
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: const BoxDecoration(color: _green, shape: BoxShape.circle),
              child: Icon(Icons.check_rounded, size: 20.r, color: Colors.white),
            ),
            SizedBox(width: 12.r),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    code,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: cs.onSurface),
                  ),
                  SizedBox(height: 2.r),
                  Text.rich(
                    TextSpan(style: save, children: [
                      TextSpan(text: '${'promo_applied'.tr()} · ${'promo_you_save'.tr()} '),
                      omrSpan(save, gap: 2),
                      TextSpan(text: saved.toStringAsFixed(2)),
                    ]),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: 'promo_remove'.tr(),
              onPressed: () => context.read<BookingFlowProvider>().removePromo(),
              icon: Icon(Iconsax.close_circle, size: 22.r, color: cs.onSurface.withValues(alpha: 0.45)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _offerCoupon(ColorScheme cs, PromoOffer o, bool busy) {
    final value = o.isPercentage ? '${o.discountValue.toStringAsFixed(0)}%' : o.discountValue.toStringAsFixed(2);
    final valueStyle = TextStyle(fontSize: 13.r, fontWeight: FontWeight.w900, color: _green);
    return Material(
      color: _green.withValues(alpha: widget.isDark ? 0.12 : 0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: BorderSide(color: _green.withValues(alpha: 0.45)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: busy ? null : () => _apply(o.code),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 12.r),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Isolated LTR so the minus stays in front of the value in RTL.
              if (o.isPercentage)
                Text(ltr('−$value'), style: valueStyle)
              else
                OmrAmount(ltr('−$value'), style: valueStyle, gap: 2),
              Container(
                width: 1,
                height: 26.r,
                margin: EdgeInsets.symmetric(horizontal: 10.r),
                color: _green.withValues(alpha: 0.35),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 150.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      o.code,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12.r, fontWeight: FontWeight.w800, letterSpacing: 1, color: cs.onSurface),
                    ),
                    if (o.name.isNotEmpty)
                      Text(
                        o.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10.r, color: cs.onSurface.withValues(alpha: 0.55)),
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

/// Rectangle with rounded corners and a semicircular notch cut into the middle
/// of each side — the classic coupon silhouette.
class _TicketClipper extends CustomClipper<Path> {
  final double notch;
  const _TicketClipper({required this.notch});

  @override
  Path getClip(Size size) {
    final body = Path()..addRRect(RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(notch * 1.5)));
    final cuts = Path()
      ..addOval(Rect.fromCircle(center: Offset(0, size.height / 2), radius: notch))
      ..addOval(Rect.fromCircle(center: Offset(size.width, size.height / 2), radius: notch));
    return Path.combine(PathOperation.difference, body, cuts);
  }

  @override
  bool shouldReclip(_TicketClipper old) => old.notch != notch;
}

class _UpperCaseFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) =>
      newValue.copyWith(text: newValue.text.toUpperCase());
}
