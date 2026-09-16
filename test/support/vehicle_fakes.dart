import 'dart:convert';

import 'package:slfdrive/src/core/data/repositories/driver_listing_repository.dart';
import 'package:slfdrive/src/core/data/repositories/lookup_repository.dart';
import 'package:slfdrive/src/core/data/repositories/vehicle_repository.dart';
import 'package:slfdrive/src/core/models/common/general_lookup.dart';
import 'package:slfdrive/src/core/models/common/paged_response.dart';
import 'package:slfdrive/src/core/models/common/pagination_params.dart';
import 'package:slfdrive/src/core/models/driver/driver_listing_item.dart';
import 'package:slfdrive/src/core/models/vehicle/vehicle.dart';
import 'package:slfdrive/src/core/models/vehicle/vehicle_brand.dart';
import 'package:slfdrive/src/core/services/review_aggregates.dart';

PagedResponse<T> pageOf<T>(List<T> rows, PaginationParams p) => PagedResponse(
      items: rows.skip((p.pageNumber - 1) * p.pageSize).take(p.pageSize).toList(),
      totalCount: rows.length,
      pageNumber: p.pageNumber,
      pageSize: p.pageSize,
      totalPages: (rows.length / p.pageSize).ceil(),
    );

Vehicle vehicle(
  int id, {
  int brandId = 1,
  String brand = 'Toyota',
  String? name,
  int typeId = 4,
  int companyId = 9,
  double? price = 12,
  bool active = true,
  String status = 'available',
  bool photo = true,
}) =>
    Vehicle.fromJson({
      'id': id,
      'brandId': brandId,
      'brandName': brand,
      'name': name ?? '$brand $id',
      'vehicleTypeId': typeId,
      'companyId': companyId,
      'pricePerDay': price,
      'isActive': active,
      'statusId': status == 'available' ? 1 : 2,
      'statusName': status,
      'photoUrls': photo ? ['https://img.test/$id.jpg'] : <String>[],
    });

/// Mirrors prod `Vehicle/paginated`: newest first; applies `searchFilter`
/// keys `name` (contains), `brandId`, `vehicleTypeId`, `isActive`,
/// `statusId`; ignores sorting.
class FakeVehicleRepository implements VehicleRepository {
  FakeVehicleRepository(this.vehicles);

  final List<Vehicle> vehicles;
  final requests = <PaginationParams>[];

  List<Vehicle> matching(String? searchFilter) {
    final f = searchFilter == null ? const <String, dynamic>{} : jsonDecode(searchFilter) as Map<String, dynamic>;
    return vehicles.where((v) {
      if (f['isActive'] != null && v.isActive != f['isActive']) return false;
      if (f['statusId'] != null && v.statusId != f['statusId']) return false;
      if (f['name'] != null && !(v.name ?? '').toLowerCase().contains((f['name'] as String).toLowerCase())) return false;
      if (f['brandId'] != null && v.brandId != f['brandId']) return false;
      if (f['vehicleTypeId'] != null && v.vehicleTypeId != f['vehicleTypeId']) return false;
      return true;
    }).toList();
  }

  @override
  Future<PagedResponse<Vehicle>> getPaginated(PaginationParams params) async {
    requests.add(params);
    return pageOf(matching(params.searchFilter), params);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

class FakeLookupRepository implements LookupRepository {
  bool fail = false;
  int brandCalls = 0;

  @override
  Future<List<GeneralLookup>> getActiveGeneralStatuses() async {
    if (fail) throw Exception('401');
    return const [
      GeneralLookup(id: 1, name: 'available', type: 'vehicle_status'),
      GeneralLookup(id: 2, name: 'rented', type: 'vehicle_status'),
      GeneralLookup(id: 5, name: 'pending', type: 'booking_status'),
    ];
  }

  @override
  Future<List<VehicleBrand>> getActiveBrands() async {
    brandCalls++;
    if (fail) throw Exception('401');
    return const [VehicleBrand(id: 1, name: 'Toyota'), VehicleBrand(id: 2, name: 'Nissan', nameAr: 'نيسان')];
  }

  @override
  Future<List<GeneralLookup>> getActiveGeneralTypes() async {
    if (fail) throw Exception('401');
    return const [
      GeneralLookup(id: 1, name: 'petrol', type: 'fuel_type'),
      GeneralLookup(id: 4, name: 'sedan', type: 'vehicle_type'),
      GeneralLookup(id: 5, name: 'SUV', type: 'vehicle_type'),
      GeneralLookup(id: 7, name: 'auto', type: 'transmission_type'),
      GeneralLookup(id: 20, name: 'cash', type: 'payment_type'),
      GeneralLookup(id: 6, name: 'truck', type: 'vehicle_type', isActive: false),
    ];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

class NoRatings implements ReviewAggregates {
  @override
  bool get isLoaded => true;

  @override
  double? vehicleAverage(int? vehicleId) => null;

  @override
  double? driverAverage(int? driverId) => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

class FakeDriverRepository implements DriverListingRepository {
  FakeDriverRepository(int count)
      : drivers = [
          for (var i = 1; i <= count; i++)
            DriverListingItem.fromJson({
              'id': i,
              'driverId': 1000 + i,
              'fullName': i.isEven ? 'Ali $i' : 'Sara $i',
              // Every third driver belongs to a rental company.
              'allCompanyId': i % 3 == 0 ? 1 : null,
            }),
        ];

  final List<DriverListingItem> drivers;
  final requests = <PaginationParams>[];

  @override
  Future<PagedResponse<DriverListingItem>> getPaginated(PaginationParams params) async {
    requests.add(params);
    final f = params.searchFilter == null ? const {} : jsonDecode(params.searchFilter!) as Map;
    final q = (f['fullName'] as String? ?? '').toLowerCase();
    return pageOf(drivers.where((d) => (d.fullName ?? '').toLowerCase().contains(q)).toList(), params);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

Future<void> settle() => Future<void>.delayed(Duration.zero);
