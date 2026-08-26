import '../../../../../core/models/review/review.dart';

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
    if (diff.inDays >= 365) return '${(diff.inDays / 365).floor()}y';
    if (diff.inDays >= 30) return '${(diff.inDays / 30).floor()}mo';
    if (diff.inDays >= 1) return '${diff.inDays}d';
    if (diff.inHours >= 1) return '${diff.inHours}h';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m';
    return 'now';
  }
}
