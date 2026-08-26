import 'package:flutter/foundation.dart';

import '../../../../../core/data/repositories/vehicle_repository.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/errors/app_exception.dart';
import '../../../../../core/models/common/entity_stats.dart';
import '../../../../../core/models/vehicle/vehicle.dart';
import '../../../../../core/services/review_aggregates.dart';
import '../../driver_detail/models/driver_review.dart';
import '../../favorites/models/fav_car.dart';

/// Loads a single vehicle by [vehicleId] and owns the image-carousel index
/// and favourite toggle for the car detail screen. Also loads the vehicle's
/// rating aggregate (`Vehicle/{id}/stats`) and its reviews (from the shared
/// [ReviewAggregates] cache), both best-effort.
class CarDetailProvider extends ChangeNotifier {
  final VehicleRepository _vehicleRepo;
  final ReviewAggregates _reviews;
  final int _vehicleId;
  final bool _ar;

  CarDetailProvider({
    required VehicleRepository vehicleRepository,
    required int vehicleId,
    ReviewAggregates? reviewAggregates,
    bool ar = false,
  })  : _vehicleRepo = vehicleRepository,
        _reviews = reviewAggregates ?? getIt<ReviewAggregates>(),
        _vehicleId = vehicleId,
        _ar = ar {
    load();
  }

  // ---- State ----
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  Vehicle? _vehicle;
  Vehicle? get vehicle => _vehicle;

  EntityStats? _stats;
  List<DriverReview> _reviewTiles = const [];
  List<int> _reviewCounts = const [0, 0, 0, 0, 0];

  /// Aggregate rating: the backend stats value, else the client-side average
  /// over loaded reviews, else the (always-null today) listing field.
  double? get rating =>
      _stats?.averageRating ?? _reviews.vehicleAverage(_vehicleId) ?? _vehicle?.rating;

  /// Authoritative review count from stats; falls back to the loaded list.
  int get reviewCount {
    final fromStats = _stats?.totalReviews ?? 0;
    return fromStats > 0 ? fromStats : _reviewTiles.length;
  }

  List<DriverReview> get reviews => _reviewTiles;
  List<int> get reviewCounts => _reviewCounts;

  bool get ar => _ar;

  List<String> get images => _vehicle?.photoUrls ?? const [];

  int _currentImageIndex = 0;
  int get currentImageIndex => _currentImageIndex;

  // ---- Loading ----
  Future<void> load() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _vehicle = await _vehicleRepo.getById(_vehicleId);
      if (_vehicle == null) {
        _error = 'Vehicle not found';
      } else {
        // Rating + reviews are best-effort (guests get 401 on stats); a
        // failure here must not blank the vehicle.
        _stats = await _vehicleRepo.getStats(_vehicleId).catchError((_) => null);
        await _reviews.ensureLoaded();
        final rows = _reviews.forVehicle(_vehicleId);
        _reviewTiles = rows.map(DriverReview.fromReview).toList();
        _reviewCounts = ReviewAggregates.distribution(rows);
      }
    } on AppException catch (e) {
      _error = e.message;
    } catch (_) {
      _error = 'Something went wrong';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ---- Image carousel ----
  void setImageIndex(int i) {
    if (_currentImageIndex == i) return;
    _currentImageIndex = i;
    notifyListeners();
  }

  // ---- Favourite ----
  /// Snapshot of the loaded vehicle for the local favourites store, or null
  /// before the vehicle has loaded.
  FavCar? favSnapshot() {
    final v = _vehicle;
    if (v == null) return null;
    return FavCar(
      id: v.id.toString(),
      name: v.displayTitle(ar: ar),
      imageUrl: v.primaryPhoto ?? '',
      pricePerDay: v.pricePerDay ?? 0,
      brand: v.brandName ?? '',
      rating: rating ?? 0,
    );
  }
}
