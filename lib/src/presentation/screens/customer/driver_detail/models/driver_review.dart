import 'package:easy_localization/easy_localization.dart';

import '../../../../../core/models/review/review.dart';
import '../../../../utils/date_labels.dart';

/// Display model for one review tile (shared by the driver and car detail
/// screens).
class DriverReview {
  final String author;
  final double rating;
  final String text;
  final String timeAgo;

  const DriverReview({
    required this.author,
    required this.rating,
    required this.text,
    required this.timeAgo,
  });

  factory DriverReview.fromReview(Review r) => DriverReview(
        author: (r.customerName?.trim().isNotEmpty ?? false) ? r.customerName!.trim() : 'Customer',
        rating: r.rating.toDouble(),
        text: r.comment?.trim() ?? '',
        timeAgo: relativeTime(r.createdAt),
      );

  static String relativeTime(String? iso) {
    final t = DateTime.tryParse(iso ?? '')?.toLocal();
    if (t == null) return '';
    final diff = DateTime.now().difference(t);
    // Older than a month: show the date itself rather than an untranslated
    // "3mo" / "1y" suffix.
    if (diff.inDays >= 30) return formatDayMonthYear(t);
    if (diff.inDays >= 1) return 'notif_time_days'.tr(namedArgs: {'n': '${diff.inDays}'});
    if (diff.inHours >= 1) return 'notif_time_hours'.tr(namedArgs: {'n': '${diff.inHours}'});
    if (diff.inMinutes >= 1) return 'notif_time_minutes'.tr(namedArgs: {'n': '${diff.inMinutes}'});
    return 'notif_time_now'.tr();
  }
}
