import 'package:flutter/material.dart';

import '../../../../../core/data/repositories/driver_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/models/review/review.dart';
import '../../../../../core/services/review_aggregates.dart';
import '../../favorites/models/fav_driver.dart';
import '../models/driver_profile.dart';
import '../models/driver_review.dart';

/// Loads a single driver from `GET /api/Driver/{id}` and exposes it as the
/// screen's `DriverProfile` view model, enriched with the driver's rating
/// aggregate (`/api/Driver/{id}/stats`) and their reviews (from the shared
/// [ReviewAggregates] cache of `/api/Review/active`, matched by driver id).
class DriverDetailProvider extends ChangeNotifier {
  DriverDetailProvider({
    required this.driverId,
    DriverRepository? repository,
    ReviewAggregates? reviews,
  })  : _repository = repository ?? getIt<DriverRepository>(),
        _reviews = reviews ?? getIt<ReviewAggregates>() {
    scroll.addListener(_onScroll);
    load();
  }

  final int driverId;
  final DriverRepository _repository;
  final ReviewAggregates _reviews;

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
        final rows = await _loadDriverReviews(details.driverId, details.fullName);
        _profile = DriverProfile.fromDetails(
          details,
          stats: stats,
          reviews: rows.map(DriverReview.fromReview).toList(),
          reviewCounts: ReviewAggregates.distribution(rows),
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

  /// Reviews for this driver, matched by the booking's driver entity id
  /// (`review.booking.driverId`). Falls back to the legacy name match for rows
  /// whose nested booking is missing. Best-effort: empty on failure.
  Future<List<Review>> _loadDriverReviews(int? entityDriverId, String? driverName) async {
    await _reviews.ensureLoaded();
    final byId = _reviews.forDriver(entityDriverId);
    if (byId.isNotEmpty) return byId;
    final name = driverName?.trim().toLowerCase();
    if (name == null || name.isEmpty) return const [];
    return _reviews.all
        .where((r) => r.driverId == null && (r.driverName?.trim().toLowerCase() ?? '') == name)
        .toList();
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
