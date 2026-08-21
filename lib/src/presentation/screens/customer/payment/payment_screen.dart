import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:provider/provider.dart';

import '../../../providers/theme_provider.dart';
import '../../../widgets/omr_icon.dart';
import '../../../widgets/skeletons/app_shimmer.dart';
import '../booking_detail/widgets/ompay_webview_page.dart';
import 'provider/payment_provider.dart';
import 'widgets/payment_method_tile.dart';

/// Full-screen payment flow for an approved booking. Methods are loaded from
/// the company-scoped payment types (with a cached-defaults fallback), and the
/// pay action reports its stage (starting checkout / verifying) instead of a
/// single opaque spinner. Pops `true` when a payment was initiated/recorded so
/// the caller can refresh.
class PaymentScreen extends StatelessWidget {
  final int bookingId;
  final int? companyId;
  final double? amount;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    this.companyId,
    this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => PaymentProvider(bookingId: bookingId, companyId: companyId),
      child: _PaymentView(amount: amount),
    );
  }
}

class _PaymentView extends StatelessWidget {
  final double? amount;
  const _PaymentView({this.amount});

  bool _isDark(BuildContext context) {
    final tp = context.watch<ThemeProvider>();
    return tp.isDarkMode ||
        (tp.isSystemMode && MediaQuery.of(context).platformBrightness == Brightness.dark);
  }

  Future<void> _pay(BuildContext context) async {
    final provider = context.read<PaymentProvider>();
    final messenger = ScaffoldMessenger.of(context);
    void snack(String msg) => messenger.showSnackBar(SnackBar(content: Text(msg)));

    if (provider.isGateway) {
      final start = await provider.startGateway();
      if (start == null || !context.mounted) return; // error shown inline
      // Root navigator so the checkout covers everything, and popping the
      // WebView can't consume this route's result.
      final result = await Navigator.of(context, rootNavigator: true).push<OmPayWebResult>(
        MaterialPageRoute(
          builder: (_) => OmPayWebViewPage(
            checkoutUrl: start.url,
            returnUrlContains: start.returnUrlMarkers,
          ),
        ),
      );
      final outcome = await provider.finishGateway(result, start.orderId);
      if (!context.mounted) return;
      switch (outcome) {
        case PaymentOutcome.paid:
          snack('pay_success'.tr());
          context.pop(true);
        case PaymentOutcome.pending:
          snack('pay_pending'.tr());
          context.pop(true);
        case PaymentOutcome.cancelled:
          snack('pay_cancelled'.tr());
        case PaymentOutcome.failed:
          snack('pay_failed'.tr());
      }
    } else {
      final ok = await provider.recordPayment();
      if (!context.mounted) return;
      if (ok) {
        snack('pay_started'.tr());
        context.pop(true);
      }
    }
  }

  String _buttonLabel(PaymentPhase phase) {
    switch (phase) {
      case PaymentPhase.startingCheckout:
      case PaymentPhase.awaitingGateway:
        return 'pay_phase_starting'.tr();
      case PaymentPhase.verifying:
        return 'pay_phase_verifying'.tr();
      case PaymentPhase.idle:
      case PaymentPhase.recording:
        return 'pay_confirm'.tr();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = _isDark(context);
    final provider = context.watch<PaymentProvider>();
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('pay_title'.tr()),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 560.r),
            child: _body(context, provider, isDark, cs),
          ),
        ),
      ),
      bottomNavigationBar: _bottomBar(context, provider, cs),
    );
  }

  Widget _body(BuildContext context, PaymentProvider provider, bool isDark, ColorScheme cs) {
    if (provider.isLoadingMethods) return _skeleton(isDark);

    if (provider.methods.isEmpty) {
      final hasError = provider.methodsError != null;
      return Padding(
        padding: EdgeInsets.all(24.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasError ? Iconsax.warning_2_copy : Iconsax.wallet_3_copy,
              size: 44.r,
              color: cs.onSurface.withValues(alpha: 0.35),
            ),
            SizedBox(height: 14.r),
            Text(
              hasError ? 'pay_methods_error'.tr() : 'pay_no_methods'.tr(),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.r, color: cs.onSurface.withValues(alpha: 0.7)),
            ),
            if (hasError) ...[
              SizedBox(height: 16.r),
              FilledButton(
                onPressed: provider.loadMethods,
                child: Text('retry'.tr()),
              ),
            ],
          ],
        ),
      );
    }

    return ListView(
      padding: EdgeInsets.fromLTRB(20.r, 8.r, 20.r, 24.r),
      children: [
        if (amount != null && amount! > 0) ...[
          _amountCard(context, isDark, cs),
          SizedBox(height: 18.r),
        ],
        Text(
          'pay_select_method'.tr(),
          style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.7)),
        ),
        SizedBox(height: 10.r),
        for (final m in provider.methods) ...[
          PaymentMethodTile(
            method: m,
            selected: provider.selectedId == m.id,
            isDark: isDark,
            onTap: provider.isSubmitting ? () {} : () => provider.select(m.id),
          ),
          SizedBox(height: 10.r),
        ],
      ],
    );
  }

  Widget _amountCard(BuildContext context, bool isDark, ColorScheme cs) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.r, vertical: 14.r),
      decoration: BoxDecoration(
        color: cs.primary.withValues(alpha: isDark ? 0.14 : 0.08),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: cs.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'pay_amount_label'.tr(),
              style: TextStyle(fontSize: 14.r, fontWeight: FontWeight.w600, color: cs.onSurface),
            ),
          ),
          Text(
            amount!.toStringAsFixed(2),
            style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.bold, color: cs.primary),
          ),
          SizedBox(width: 6.r),
          OmrIcon(size: 16.r, color: cs.primary),
        ],
      ),
    );
  }

  Widget _skeleton(bool isDark) {
    final base = isDark ? const Color(0xFF1E1E2E) : const Color(0xFFE0E0E0);
    Widget box(double h) => Container(
          height: h,
          decoration: BoxDecoration(color: base, borderRadius: BorderRadius.circular(14.r)),
        );
    return AppShimmer(
      baseColor: base,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.r, 8.r, 20.r, 24.r),
        child: Column(
          children: [
            box(52.r),
            SizedBox(height: 18.r),
            for (var i = 0; i < 3; i++) ...[
              box(56.r),
              SizedBox(height: 10.r),
            ],
          ],
        ),
      ),
    );
  }

  Widget _bottomBar(BuildContext context, PaymentProvider provider, ColorScheme cs) {
    final canPay = !provider.isLoadingMethods &&
        provider.methods.isNotEmpty &&
        provider.selectedId != null &&
        !provider.isSubmitting;
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.r, 8.r, 20.r, 12.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (provider.submitError != null) ...[
              Text(
                provider.submitError!.isEmpty ? 'pay_failed'.tr() : provider.submitError!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.r, color: cs.error),
              ),
              SizedBox(height: 8.r),
            ],
            FilledButton(
              onPressed: canPay ? () => _pay(context) : null,
              style: FilledButton.styleFrom(padding: EdgeInsets.symmetric(vertical: 14.r)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (provider.isSubmitting) ...[
                    SizedBox(
                      width: 16.r,
                      height: 16.r,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 10.r),
                  ],
                  Text(_buttonLabel(provider.phase)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
