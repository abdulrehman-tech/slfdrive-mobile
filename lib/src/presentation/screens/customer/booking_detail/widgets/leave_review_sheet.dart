import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../../../../core/data/repositories/review_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../widgets/confirm_dialog.dart';

/// Bottom sheet that lets a customer rate + comment a completed booking and
/// submits it via `POST /api/Review`.
class LeaveReviewSheet extends StatefulWidget {
  final int bookingId;
  final bool isDark;
  const LeaveReviewSheet({super.key, required this.bookingId, required this.isDark});

  /// Opens the sheet; returns true when a review was submitted.
  static Future<bool?> show(BuildContext context, {required int bookingId, required bool isDark}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => LeaveReviewSheet(bookingId: bookingId, isDark: isDark),
    );
  }

  @override
  State<LeaveReviewSheet> createState() => _LeaveReviewSheetState();
}

class _LeaveReviewSheetState extends State<LeaveReviewSheet> {
  int _rating = 5;
  final _comment = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await getIt<ReviewRepository>().submit(bookingId: widget.bookingId, rating: _rating, comment: _comment.text);
      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('review_submitted'.tr())));
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (_) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('review_failed'.tr())));
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
            Text(
              'review_title'.tr(),
              style: TextStyle(fontSize: 18.r, fontWeight: FontWeight.bold, color: cs.onSurface),
            ),
            SizedBox(height: 16.r),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final filled = i < _rating;
                  return GestureDetector(
                    onTap: () => setState(() => _rating = i + 1),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.r),
                      child: Icon(
                        filled ? Iconsax.star : Iconsax.star_1_copy,
                        size: 34.r,
                        color: const Color(0xFFFFC107),
                      ),
                    ),
                  );
                }),
              ),
            ),
            SizedBox(height: 18.r),
            TextField(
              controller: _comment,
              maxLines: 4,
              minLines: 3,
              decoration: InputDecoration(
                hintText: 'review_comment_hint'.tr(),
                filled: true,
                fillColor: cs.onSurface.withValues(alpha: 0.05),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14.r), borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: 18.r),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _submitting
                    ? null
                    : () => showConfirmDialog(
                          context,
                          isDark: widget.isDark,
                          icon: Iconsax.star_1,
                          accent: const Color(0xFF4D63DD),
                          title: 'review_confirm_title',
                          message: 'review_confirm_msg',
                          confirmLabelKey: 'review_submit',
                          onConfirm: _submit,
                        ),
                child: _submitting
                    ? SizedBox(width: 18.r, height: 18.r, child: const CircularProgressIndicator(strokeWidth: 2))
                    : Text('review_submit'.tr()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
