import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../core/data/repositories/booking_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/services/booking_lookups.dart';
import '../../booking/models/booking_data.dart' show PaymentMethod;
import 'ompay_webview_page.dart';

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
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    void snack(String msg) => messenger.showSnackBar(SnackBar(content: Text(msg)));

    try {
      if (_method == PaymentMethod.card) {
        await _payWithCard(repo, navigator, snack);
      } else {
        final lookups = getIt<BookingLookups>();
        await lookups.ensureLoaded();
        final cashId = lookups.paymentTypeId(PaymentMethod.cash);
        if (cashId == null) throw AppException(message: 'pay_failed'.tr());
        await repo.pay(bookingId: widget.bookingId, paymentTypeId: cashId);
        if (!mounted) return;
        navigator.pop(true);
        snack('pay_started'.tr());
      }
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      snack(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      snack('pay_failed'.tr());
    }
  }

  /// Card → OmPay: start the session, open the checkout in a secure in-app
  /// WebView, then confirm the order on its return.
  Future<void> _payWithCard(
    BookingRepository repo,
    NavigatorState navigator,
    void Function(String) snack,
  ) async {
    final init = await repo.omPayInit(widget.bookingId, 'mobile');
    final url = init.checkoutPageUrl ?? init.redirectUrl ?? init.checkoutJsUrl;
    if (url == null || url.isEmpty) {
      throw AppException(message: 'pay_failed'.tr());
    }

    // The gateway redirects to the backend result page when the flow ends;
    // detect it (plus the future slfdrive:// deep link) to close the WebView.
    final markers = <String>{
      '/ompay/result',
      if (init.redirectUrl != null && init.redirectUrl!.isNotEmpty) init.redirectUrl!,
    }.toList();

    // Root navigator so the WebView covers this bottom sheet.
    final result = await navigator.push<OmPayWebResult>(
      MaterialPageRoute(
        builder: (_) => OmPayWebViewPage(checkoutUrl: url, returnUrlContains: markers),
      ),
    );
    if (!mounted) return;

    final outcome = result?.outcome ?? OmPayWebOutcome.cancelled;
    if (outcome == OmPayWebOutcome.success) {
      // Confirm with the backend; payment may still settle via the webhook.
      bool paid = false;
      final orderId = result?.orderId ?? init.orderId;
      if (orderId != null) {
        try {
          paid = await repo.omPayVerify(widget.bookingId, orderId);
        } catch (_) {
          // treated as pending — reconciled by the backend webhook
        }
      }
      navigator.pop(true); // closes the sheet → booking detail reloads
      snack((paid ? 'pay_success' : 'pay_pending').tr());
    } else {
      // Cancelled / failed — keep the sheet open so the user can retry.
      setState(() => _submitting = false);
      snack((outcome == OmPayWebOutcome.failed ? 'pay_failed' : 'pay_cancelled').tr());
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
