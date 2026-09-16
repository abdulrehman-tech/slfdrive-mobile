import '../data/repositories/lookup_repository.dart';
import '../models/common/general_lookup.dart';
import '../models/vehicle/vehicle_brand.dart';

/// Choices for the vehicle filter UI — active brands plus the
/// `vehicle_type` / `transmission_type` / `fuel_type` rows of `GeneralType` —
/// and the vehicle status ids used to list available cars first.
///
/// Loaded once per session. Both lookups need a signed-in user; for a guest
/// (or on failure) the lists stay empty, the filter UI hides those sections,
/// and the next [ensureLoaded] tries again.
class VehicleFilterOptions {
  VehicleFilterOptions(this._lookups);

  final LookupRepository _lookups;

  List<VehicleBrand> _brands = const [];
  List<GeneralLookup> _types = const [];
  List<GeneralLookup> _statuses = const [];
  Future<void>? _brandsLoad;
  Future<void>? _typesLoad;
  Future<void>? _statusLoad;

  /// Vehicle `statusId` meaning "available" — verified on prod vehicle rows
  /// (`statusId: 1, statusName: "available"`).
  static const availableStatusId = 1;

  /// The other vehicle statuses (rented, maintenance…): rows sharing the
  /// "available" row's `type`. Null when unknown — a guest, or the lookup
  /// doesn't hold that row as expected.

  List<VehicleBrand> get brands => _brands;
  List<GeneralLookup> get vehicleTypes => _ofType('vehicle_type');
  List<GeneralLookup> get transmissions => _ofType('transmission_type');
  List<GeneralLookup> get fuels => _ofType('fuel_type');

  List<int>? get otherVehicleStatusIds {
    GeneralLookup? available;
    for (final s in _statuses) {
      if (s.id == availableStatusId && (s.name ?? '').trim().toLowerCase() == 'available') available = s;
    }
    final type = available?.type;
    if (type == null || type.isEmpty) return null;
    return [
      for (final s in _statuses)
        if (s.type == type && s.id != availableStatusId) s.id,
    ];
  }

  bool get isLoaded => _brands.isNotEmpty || _types.isNotEmpty;

  /// Never throws.
  Future<void> ensureLoaded() => Future.wait([
        _brandsLoad ??= _loadBrands(),
        _typesLoad ??= _loadTypes(),
        _statusLoad ??= _loadStatuses(),
      ]);

  /// The brand whose (localized) name matches [name] — brand tiles and the
  /// home brand row pass names, the API filters by id.
  VehicleBrand? brandNamed(String name, {bool ar = false}) {
    final want = name.trim().toLowerCase();
    for (final b in _brands) {
      if (b.name.trim().toLowerCase() == want || b.displayName(ar: ar).trim().toLowerCase() == want) return b;
    }
    return null;
  }

  VehicleBrand? brandById(int? id) {
    for (final b in _brands) {
      if (b.id == id) return b;
    }
    return null;
  }

  GeneralLookup? typeById(int? id) {
    for (final t in _types) {
      if (t.id == id) return t;
    }
    return null;
  }

  List<GeneralLookup> _ofType(String type) => _types.where((t) => (t.type ?? '').toLowerCase() == type).toList();

  Future<void> _loadBrands() async {
    try {
      _brands = await _lookups.getActiveBrands();
    } catch (_) {
      _brandsLoad = null;
    }
  }

  Future<void> _loadStatuses() async {
    try {
      _statuses = (await _lookups.getActiveGeneralStatuses()).where((s) => s.isActive).toList();
    } catch (_) {
      _statusLoad = null;
    }
  }

  Future<void> _loadTypes() async {
    try {
      _types = (await _lookups.getActiveGeneralTypes()).where((t) => t.isActive).toList();
    } catch (_) {
      _typesLoad = null;
    }
  }
}
