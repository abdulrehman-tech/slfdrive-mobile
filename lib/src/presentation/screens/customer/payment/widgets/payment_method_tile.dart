import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../core/models/common/general_lookup.dart';

/// Icon for a payment-type row, mapped by name (backend rows: card / cash /
/// OmPay); unknown types get a generic wallet icon.
IconData paymentMethodIcon(GeneralLookup m) {
  final n = (m.name ?? '').toLowerCase();
  if (n.contains('card') || n.contains('ompay')) return Iconsax.card_copy;
  if (n.contains('cash')) return Iconsax.money_copy;
  return Iconsax.wallet_3_copy;
}

/// Label for a payment-type row: known names reuse the translated keys, unknown
/// ones show the backend name (Arabic name for the ar locale when present).
String paymentMethodLabel(BuildContext context, GeneralLookup m) {
  final n = (m.name ?? '').toLowerCase();
  if (n.contains('card') || n.contains('ompay')) return 'pay_method_card'.tr();
  if (n.contains('cash')) return 'pay_method_cash'.tr();
  final isAr = context.locale.languageCode == 'ar';
  if (isAr && (m.nameAr ?? '').trim().isNotEmpty) return m.nameAr!.trim();
  return (m.name ?? '').trim();
}

/// Selectable payment-method tile (icon + label + selected checkmark) — same
/// visual language as the old pay sheet's tiles.
class PaymentMethodTile extends StatelessWidget {
  final GeneralLookup method;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const PaymentMethodTile({
    super.key,
    required this.method,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.all(16.r),
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
            Icon(paymentMethodIcon(method), size: 22.r, color: cs.primary),
            SizedBox(width: 12.r),
            Expanded(
              child: Text(
                paymentMethodLabel(context, method),
                style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w700, color: cs.onSurface),
              ),
            ),
            if (selected) Icon(Iconsax.tick_circle_copy, size: 20.r, color: cs.primary),
          ],
        ),
      ),
    );
  }
}
