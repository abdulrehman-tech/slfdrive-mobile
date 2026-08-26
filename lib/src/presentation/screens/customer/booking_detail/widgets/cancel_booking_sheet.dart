import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../core/errors/app_exception.dart';
import '../provider/booking_detail_provider.dart';

/// Bottom sheet that confirms a customer cancellation, collects an optional
/// reason, and submits it through [BookingDetailProvider.cancel].
class CancelBookingSheet extends StatefulWidget {
  final BookingDetailProvider provider;
  final bool isDark;
  const CancelBookingSheet({super.key, required this.provider, required this.isDark});

  /// Opens the sheet; returns true when the booking was cancelled.
  static Future<bool?> show(
    BuildContext context, {
    required BookingDetailProvider provider,
    required bool isDark,
  }) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CancelBookingSheet(provider: provider, isDark: isDark),
    );
  }

  @override
  State<CancelBookingSheet> createState() => _CancelBookingSheetState();
}

class _CancelBookingSheetState extends State<CancelBookingSheet> {
  static const _accent = Color(0xFFE53935);
  final _reason = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await widget.provider.cancel(reason: _reason.text);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('booking_cancelled_success'.tr())));
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('booking_cancel_failed'.tr())));
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
        padding: EdgeInsets.fromLTRB(20.r, 16.r, 20.r, 24.r),
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
            SizedBox(height: 18.r),
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.r),
                  decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Iconsax.close_circle, color: _accent, size: 22.r),
                ),
                SizedBox(width: 12.r),
                Expanded(
                  child: Text(
                    'booking_detail_cancel_title'.tr(),
                    style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.bold, color: cs.onSurface),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.r),
            Text(
              'booking_detail_cancel_body'.tr(),
              style: TextStyle(fontSize: 13.r, height: 1.4, color: cs.onSurface.withValues(alpha: 0.65)),
            ),
            SizedBox(height: 16.r),
            TextField(
              controller: _reason,
              maxLines: 3,
              minLines: 2,
              maxLength: 300,
              enabled: !_submitting,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'booking_cancel_reason_hint'.tr(),
                counterText: '',
                filled: true,
                fillColor: cs.onSurface.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: 18.r),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _submitting ? null : () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.r),
                      backgroundColor: cs.onSurface.withValues(alpha: 0.06),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: Text(
                      'booking_cancel_keep'.tr(),
                      style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w600, color: cs.onSurface.withValues(alpha: 0.75)),
                    ),
                  ),
                ),
                SizedBox(width: 12.r),
                Expanded(
                  child: TextButton(
                    onPressed: _submitting ? null : _submit,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 14.r),
                      backgroundColor: _accent,
                      disabledBackgroundColor: _accent.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                    child: _submitting
                        ? SizedBox(
                            width: 18.r,
                            height: 18.r,
                            child: const CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : Text(
                            'booking_detail_cancel_confirm'.tr(),
                            style: TextStyle(fontSize: 15.r, fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
