import 'dart:convert';

/// What a customer-facing vehicle list asks `Vehicle/paginated` for.
///
/// Only filters the backend applies itself live here — verified on prod
/// (2026-09-16): `name` (contains), `brandId`, `vehicleTypeId`,
/// `transmissionTypeId`, `fuelType`, `isActive`. Sorting, price ranges, seats
/// and year are ignored by the API, so the app doesn't offer them.
class VehicleQuery {
  const VehicleQuery({
    this.text = '',
    this.brandId,
    this.vehicleTypeId,
    this.transmissionTypeId,
    this.fuelTypeId,
  });

  final String text;
  final int? brandId;
  final int? vehicleTypeId;
  final int? transmissionTypeId;
  final int? fuelTypeId;

  static const empty = VehicleQuery();

  bool get isEmpty => text.trim().isEmpty && !hasFilters;

  /// Any filter besides the free text.
  bool get hasFilters => filterCount > 0;

  int get filterCount => [brandId, vehicleTypeId, transmissionTypeId, fuelTypeId].where((v) => v != null).length;

  VehicleQuery withText(String value) => _copy(text: value);
  VehicleQuery withBrand(int? id) => _copy(brandId: () => id);
  VehicleQuery withVehicleType(int? id) => _copy(vehicleTypeId: () => id);
  VehicleQuery withTransmission(int? id) => _copy(transmissionTypeId: () => id);
  VehicleQuery withFuel(int? id) => _copy(fuelTypeId: () => id);

  /// Drops every filter, keeping the text.
  VehicleQuery withoutFilters() => VehicleQuery(text: text);

  /// JSON for `PaginationParams.searchFilter`, or null when nothing is set.
  /// Lists include disabled vehicles (shown with an "Unavailable" badge);
  /// [activeOnly] limits to enabled ones, e.g. for the booking picker.
  /// [extra] adds status keys (`isActive`, `statusId`) for ordered segments.
  String? toSearchFilter({bool activeOnly = false, Map<String, Object> extra = const {}}) {
    final filter = <String, Object>{
      if (activeOnly) 'isActive': true,
      ...extra,
      if (text.trim().isNotEmpty) 'name': text.trim(),
      'brandId': ?brandId,
      'vehicleTypeId': ?vehicleTypeId,
      'transmissionTypeId': ?transmissionTypeId,
      'fuelType': ?fuelTypeId,
    };
    return filter.isEmpty ? null : jsonEncode(filter);
  }

  VehicleQuery _copy({
    String? text,
    int? Function()? brandId,
    int? Function()? vehicleTypeId,
    int? Function()? transmissionTypeId,
    int? Function()? fuelTypeId,
  }) {
    return VehicleQuery(
      text: text ?? this.text,
      brandId: brandId != null ? brandId() : this.brandId,
      vehicleTypeId: vehicleTypeId != null ? vehicleTypeId() : this.vehicleTypeId,
      transmissionTypeId: transmissionTypeId != null ? transmissionTypeId() : this.transmissionTypeId,
      fuelTypeId: fuelTypeId != null ? fuelTypeId() : this.fuelTypeId,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is VehicleQuery &&
      other.text.trim() == text.trim() &&
      other.brandId == brandId &&
      other.vehicleTypeId == vehicleTypeId &&
      other.transmissionTypeId == transmissionTypeId &&
      other.fuelTypeId == fuelTypeId;

  @override
  int get hashCode => Object.hash(text.trim(), brandId, vehicleTypeId, transmissionTypeId, fuelTypeId);
}
