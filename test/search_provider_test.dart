import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:slfdrive/src/core/services/vehicle_filter_options.dart';
import 'package:slfdrive/src/presentation/providers/vehicle_catalog.dart';
import 'package:slfdrive/src/presentation/screens/customer/search/provider/search_provider.dart';

import 'support/vehicle_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FakeVehicleRepository vehicles;
  late FakeDriverRepository drivers;

  SearchProvider build() => SearchProvider(
        cars: VehicleCatalog(
          repository: vehicles,
          options: VehicleFilterOptions(FakeLookupRepository()),
          ratings: NoRatings(),
        ),
        driverRepository: drivers,
      );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    vehicles = FakeVehicleRepository([
      for (var i = 45; i >= 1; i--) vehicle(i, name: i.isEven ? 'Toyota Corolla $i' : 'Nissan Sunny $i', typeId: i % 3 == 0 ? 5 : 4),
    ]);
    drivers = FakeDriverRepository(30);
  });

  test('starts in discover without loading anything', () async {
    final p = build();
    await settle();
    expect(p.showDiscover, isTrue);
    expect(vehicles.requests, isEmpty);
    expect(drivers.requests, isEmpty);
    expect(p.cars.options.vehicleTypes, isNotEmpty);
    p.dispose();
  });

  test('typing searches cars and drivers on the server after a pause', () async {
    final p = build();
    p.setText('coro');
    expect(p.showDiscover, isFalse);
    await Future<void>.delayed(const Duration(milliseconds: 400));
    await settle();
    expect(jsonDecode(vehicles.requests.last.searchFilter!), {'name': 'coro'});
    expect(jsonDecode(drivers.requests.last.searchFilter!), {'fullName': 'coro'});
    expect(p.cars.totalCount, 22);
    p.dispose();
  });

  test('a car-type chip opens results; drivers are freelance only and page on', () async {
    final p = build();
    p.browseVehicleType(5);
    await settle();
    expect(p.showDiscover, isFalse);
    expect(p.cars.totalCount, 15);
    expect(drivers.requests.single.searchFilter, isNull);
    // 20 loaded, every third a company driver → 14 freelancers, more to come.
    expect(p.drivers.length, 14);
    expect(p.driverCount, isNull);
    await p.loadMoreDrivers();
    expect(p.drivers.length, 20);
    expect(p.driverCount, 20);

    // Changing a car filter doesn't refetch drivers.
    p.cars.setQuery(p.cars.query.withVehicleType(4));
    await settle();
    expect(drivers.requests.length, 2);
    p.dispose();
  });

  test('keyboard search is remembered; clearing text returns to discover', () async {
    final p = build();
    p.searchController.text = 'nissan';
    p.submit('nissan');
    await settle();
    await settle();
    expect(p.recent, ['nissan']);
    expect((await SharedPreferences.getInstance()).getStringList('recent_searches_v1'), ['nissan']);

    p.clearText();
    expect(p.showDiscover, isTrue);

    p.useRecent('nissan');
    await settle();
    expect(p.showDiscover, isFalse);
    expect(p.cars.query.text, 'nissan');
    p.dispose();
  });
}
