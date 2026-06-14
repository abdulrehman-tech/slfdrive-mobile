import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../../core/data/repositories/booking_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/services/booking_lookups.dart';
import '../../booking/models/booking_data.dart' show PaymentMethod;

/// Bottom sheet for paying an approved booking: card (OmPay gateway) or cash
/// (recorded via `POST /api/Booking/pay`).
class PayBookingSheet extends StatefulWidget {
  final int bookingId;
  final bool isDark;
  const PayBookingSheet({super.key, required this.bookingId, required this.isDark});

  /// Opens the sheet; returns true when payment was initiated/recorded.
  static Future<bool?> show(BuildContext context, {required int bookingId, required bool isDark}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PayBookingSheet(bookingId: bookingId, isDark: isDark),
    );
  }

  @override
  State<PayBookingSheet> createState() => _PayBookingSheetState();
}

class _PayBookingSheetState extends State<PayBookingSheet> {
  PaymentMethod _method = PaymentMethod.card;
  bool _submitting = false;

  Future<void> _pay() async {
    setState(() => _submitting = true);
    final repo = getIt<BookingRepository>();
    try {
      if (_method == PaymentMethod.card) {
        final init = await repo.omPayInit(widget.bookingId, kIsWeb ? 'web' : 'mobile');
        final url = init.checkoutPageUrl ?? init.redirectUrl ?? init.checkoutJsUrl;
        if (url != null && url.isNotEmpty) {
          final uri = Uri.tryParse(url);
          if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
        if (init.orderId != null) {
          try {
            await repo.omPayVerify(widget.bookingId, init.orderId!);
          } catch (_) {
            // pending/failed verification is reconciled via the backend webhook
          }
        }
      } else {
        final lookups = getIt<BookingLookups>();
        await lookups.ensureLoaded();
        final cashId = lookups.paymentTypeId(PaymentMethod.cash);
        if (cashId == null) throw AppException(message: 'pay_failed'.tr());
        await repo.pay(bookingId: widget.bookingId, paymentTypeId: cashId);
      }
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('pay_started'.tr())));
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('pay_failed'.tr())));
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = widget.isDark ? const Color(0xFF15151F) : Colors.white;
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
        ),
        padding: EdgeInsets.fromLTRB(20.r, 14.r, 20.r, 24.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40.r,
                height: 4.r,
                decoration: BoxDecoration(
                  color: cs.onSurface.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.r),
            Text(
              'pay_title'.tr(),
              style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.bold, color: cs.onSurface),
            ),
            SizedBox(height: 14.r),
            _MethodTile(
              icon: Iconsax.card_copy,
              label: 'pay_method_card'.tr(),
              selected: _method == PaymentMethod.card,
              isDark: widget.isDark,
              onTap: () => setState(() => _method = PaymentMethod.card),
            ),
            SizedBox(height: 8.r),
            _MethodTile(
              icon: Iconsax.money_copy,
              label: 'pay_method_cash'.tr(),
              selected: _method == PaymentMethod.cash,
              isDark: widget.isDark,
              onTap: () => setState(() => _method = PaymentMethod.cash),
            ),
            SizedBox(height: 18.r),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitting ? null : _pay,
                child: _submitting
                    ? SizedBox(
                        width: 18.r,
                        height: 18.r,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text('pay_confirm'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MethodTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;
  const _MethodTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(14.r),
        decoration: BoxDecoration(
          color: selected
              ? cs.primary.withValues(alpha: isDark ? 0.18 : 0.1)
              : (isDark ? Colors.white.withValues(alpha: 0.04) : Colors.black.withValues(alpha: 0.03)),
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected
                ? cs.primary.withValues(alpha: 0.6)
                : (isDark ? Colors.white.withValues(alpha: 0.07) : Colors.black.withValues(alpha: 0.06)),
          ),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20.r, color: cs.primary),
            SizedBox(width: 12.r),
            Expanded(
              child: Text(
                label,
                style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w700, color: cs.onSurface),
              ),
            ),
            if (selected) Icon(Iconsax.tick_circle_copy, size: 20.r, color: cs.primary),
          ],
        ),
      ),
    );
  }
}
