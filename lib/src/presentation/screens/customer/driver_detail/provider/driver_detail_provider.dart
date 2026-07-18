import 'package:flutter/material.dart';

import '../../../../../core/data/repositories/driver_repository.dart';
import '../../../../../core/data/repositories/review_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/models/review/review.dart';
import '../../favorites/models/fav_driver.dart';
import '../models/driver_profile.dart';
import '../models/driver_review.dart';

/// Loads a single driver from `GET /api/Driver/{id}` and exposes it as the
/// screen's `DriverProfile` view model, enriched with the driver's rating
/// aggregate (`/api/Driver/{id}/stats`) and their reviews (filtered from
/// `/api/Review/active`, which is the only review-list endpoint).
class DriverDetailProvider extends ChangeNotifier {
  DriverDetailProvider({
    required this.driverId,
    DriverRepository? repository,
    ReviewRepository? reviews,
  })  : _repository = repository ?? getIt<DriverRepository>(),
        _reviews = reviews ?? getIt<ReviewRepository>() {
    scroll.addListener(_onScroll);
    load();
  }

  final int driverId;
  final DriverRepository _repository;
  final ReviewRepository _reviews;

  DriverProfile? _profile;
  DriverProfile? get profile => _profile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Snapshot of the loaded driver for the local favourites store, or null
  /// before the driver has loaded.
  FavDriver? favSnapshot() {
    final p = _profile;
    if (p == null) return null;
    return FavDriver(
      id: p.id,
      name: p.name,
      avatarUrl: p.avatarUrl,
      rating: p.rating,
      trips: p.trips,
      speciality: p.languages.isNotEmpty ? p.languages.first : '',
    );
  }

  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final details = await _repository.getById(driverId);
      if (details == null) {
        _error = 'Driver not found';
      } else {
        // Rating aggregate + reviews are fetched best-effort; a failure here
        // must not blank the whole profile, so each is guarded independently.
        final stats = await _repository.getStats(driverId).catchError((_) => null);
        final driverReviews = await _loadDriverReviews(details.fullName);
        _profile = DriverProfile.fromDetails(
          details,
          stats: stats,
          reviews: driverReviews,
          reviewCounts: _distribution(driverReviews),
        );
      }
    } on AppException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetches all active reviews and keeps only those whose `driverName`
  /// matches this driver (the backend exposes no per-driver reviews endpoint,
  /// and review rows carry `driverName` but not a driver id). Best-effort:
  /// returns empty on any failure.
  Future<List<DriverReview>> _loadDriverReviews(String? driverName) async {
    final name = driverName?.trim().toLowerCase();
    if (name == null || name.isEmpty) return const [];
    try {
      final all = await _reviews.active();
      return all
          .where((r) => (r.driverName?.trim().toLowerCase() ?? '') == name)
          .map(_toDriverReview)
          .toList();
    } catch (_) {
      return const [];
    }
  }

  DriverReview _toDriverReview(Review r) => DriverReview(
        author: (r.customerName?.trim().isNotEmpty ?? false) ? r.customerName!.trim() : 'Customer',
        rating: r.rating.toDouble(),
        text: r.comment?.trim() ?? '',
        timeAgo: _timeAgo(r.createdAt),
      );

  /// Star-count histogram ordered [5★, 4★, 3★, 2★, 1★] to match `reviews_card`.
  List<int> _distribution(List<DriverReview> reviews) {
    final counts = [0, 0, 0, 0, 0];
    for (final r in reviews) {
      final star = r.rating.round().clamp(1, 5);
      counts[5 - star]++;
    }
    return counts;
  }

  String _timeAgo(String? iso) {
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

  final ScrollController scroll = ScrollController();
  double _scrollOffset = 0;
  double get scrollOffset => _scrollOffset;

  void _onScroll() {
    final next = scroll.offset.clamp(0, 240).toDouble();
    if ((next - _scrollOffset).abs() > 0.5) {
      _scrollOffset = next;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    scroll
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }
}
