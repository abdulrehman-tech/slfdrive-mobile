import 'dart:math';

import '../data/repositories/vehicle_repository.dart';
import '../models/common/pagination_params.dart';
import '../models/vehicle/vehicle.dart';
import '../models/vehicle/vehicle_query.dart';
import 'vehicle_filter_options.dart';

/// Picks the home screen's featured row: a varied, shuffled sample instead of
/// the newest N (which on prod is always one company's latest upload).
///
/// The API can't sort or randomize, so this samples [_samplePages] random
/// pages of *available* cars (after a 1-row request that reveals how many
/// there are, cached for the picker's lifetime), topping up from all cars only
/// when that's not enough, then [diversify]s the pool.
class FeaturedVehiclePicker {
  FeaturedVehiclePicker(this._repo, {Random? random}) : _random = random ?? Random();

  final VehicleRepository _repo;
  final Random _random;

  static const _pageSize = 20;
  static const _samplePages = 2;

  static final _availableOnly = VehicleQuery.empty.toSearchFilter(
    extra: {'isActive': true, 'statusId': VehicleFilterOptions.availableStatusId},
  );

  int? _availablePages;

  Future<List<Vehicle>> pick({int count = 10}) async {
    var pages = _availablePages;
    if (pages == null) {
      final probe = await _repo.getPaginated(PaginationParams(pageSize: 1, searchFilter: _availableOnly));
      pages = _availablePages = (probe.totalCount / _pageSize).ceil();
    }

    final pool = <Vehicle>[];
    final seen = <int>{};
    void add(Iterable<Vehicle> rows) {
      for (final v in rows) {
        if (seen.add(v.id)) pool.add(v);
      }
    }

    final picked = (List.generate(pages, (i) => i + 1)..shuffle(_random)).take(_samplePages);
    final results = await Future.wait([
      for (final page in picked)
        _repo.getPaginated(PaginationParams(pageNumber: page, pageSize: _pageSize, searchFilter: _availableOnly)),
    ]);
    for (final r in results) {
      add(r.items);
    }
    if (pool.length < count) {
      // Few available cars: fill the row with the rest (shown as unavailable).
      add((await _repo.getPaginated(const PaginationParams(pageSize: _pageSize))).items);
    }
    return diversify(pool, count: count, random: _random);
  }

  /// Available cars with a price and a photo first, then other available
  /// cars, then unavailable ones. Within each tier the companies take turns
  /// (each company's cars shuffled) so no single fleet fills the row.
  static List<Vehicle> diversify(List<Vehicle> pool, {required int count, required Random random}) {
    int tier(Vehicle v) {
      if (!v.isAvailable) return 2;
      return v.hasPrice && v.primaryPhoto != null ? 0 : 1;
    }

    final out = <Vehicle>[];
    for (var t = 0; t < 3 && out.length < count; t++) {
      out.addAll(_roundRobin(pool.where((v) => tier(v) == t).toList(), random));
    }
    return out.take(count).toList();
  }

  static List<Vehicle> _roundRobin(List<Vehicle> vehicles, Random random) {
    final byCompany = <int?, List<Vehicle>>{};
    for (final v in vehicles) {
      byCompany.putIfAbsent(v.companyId, () => []).add(v);
    }
    final queues = byCompany.values.map((list) => list..shuffle(random)).toList()..shuffle(random);
    final out = <Vehicle>[];
    for (var i = 0; out.length < vehicles.length; i++) {
      for (final q in queues) {
        if (i < q.length) out.add(q[i]);
      }
    }
    return out;
  }
}
