import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slfdrive/src/core/models/vehicle/vehicle_query.dart';
import 'package:slfdrive/src/core/services/featured_vehicles.dart';
import 'package:slfdrive/src/core/services/vehicle_filter_options.dart';
import 'package:slfdrive/src/presentation/providers/vehicle_catalog.dart';
import 'package:slfdrive/src/presentation/widgets/vehicles/vehicle_filter_sheet.dart';

import 'support/vehicle_fakes.dart';

void main() {
  group('Vehicle availability', () {
    test('inactive or non-available status is unavailable; unpriced is not bookable', () {
      expect(vehicle(1).isAvailable, isTrue);
      expect(vehicle(1).isBookable, isTrue);
      expect(vehicle(2, active: false).isAvailable, isFalse);
      expect(vehicle(3, status: 'rented').isAvailable, isFalse);
      expect(vehicle(4, price: null).isAvailable, isTrue);
      expect(vehicle(4, price: null).isBookable, isFalse);
      expect(vehicle(5, price: 0).hasPrice, isFalse);
    });
  });

  group('VehicleQuery', () {
    test('only sends set filters; active-only is opt-in', () {
      expect(VehicleQuery.empty.toSearchFilter(), isNull);
      expect(jsonDecode(VehicleQuery.empty.toSearchFilter(activeOnly: true)!), {'isActive': true});
      final q = const VehicleQuery(text: ' corolla ').withBrand(1).withVehicleType(5).withFuel(1);
      expect(jsonDecode(q.toSearchFilter()!), {
        'name': 'corolla',
        'brandId': 1,
        'vehicleTypeId': 5,
        'fuelType': 1,
      });
      expect(q.filterCount, 3);
      expect(jsonDecode(q.withoutFilters().toSearchFilter(extra: {'isActive': false})!), {
        'isActive': false,
        'name': 'corolla',
      });
      expect(q.withBrand(null).filterCount, 2);
      expect(q.withoutFilters(), const VehicleQuery(text: ' corolla '));
    });
  });

  group('VehicleFilterOptions', () {
    test('splits general types by discriminator and skips inactive rows', () async {
      final o = VehicleFilterOptions(FakeLookupRepository());
      await o.ensureLoaded();
      expect(o.vehicleTypes.map((t) => t.name), ['sedan', 'SUV']);
      expect(o.transmissions.map((t) => t.name), ['auto']);
      expect(o.fuels.map((t) => t.name), ['petrol']);
      expect(o.brandNamed(' toyota ')?.id, 1);
      expect(o.brandNamed('نيسان', ar: true)?.id, 2);
      expect(o.otherVehicleStatusIds, [2]);
    });

    test('a failed load (guest) stays empty and retries next time', () async {
      final lookup = FakeLookupRepository()..fail = true;
      final o = VehicleFilterOptions(lookup);
      await o.ensureLoaded();
      expect(o.brands, isEmpty);
      expect(o.otherVehicleStatusIds, isNull);
      lookup.fail = false;
      await o.ensureLoaded();
      expect(o.brands.length, 2);
      expect(lookup.brandCalls, 2);
    });
  });

  group('VehicleCatalog', () {
    late FakeVehicleRepository repo;
    late FakeLookupRepository lookup;

    VehicleCatalog build() =>
        VehicleCatalog(repository: repo, options: VehicleFilterOptions(lookup), ratings: NoRatings());

    setUp(() {
      repo = FakeVehicleRepository([
        for (var i = 50; i >= 1; i--)
          vehicle(i, brandId: i.isEven ? 1 : 2, brand: i.isEven ? 'Toyota' : 'Nissan', typeId: i % 5 == 0 ? 5 : 4),
        vehicle(99, active: false),
      ]);
      lookup = FakeLookupRepository();
    });

    test('loads 20 at a time and lists inactive vehicles as unavailable', () async {
      final c = build();
      await c.start();
      expect(c.vehicles.length, 20);
      expect(c.totalCount, 51);
      // A 1-row count over everything, and the first page of available cars.
      expect(repo.requests.map((r) => r.pageSize), unorderedEquals([20, 1]));
      expect(repo.requests.firstWhere((r) => r.pageSize == 1).searchFilter, isNull);
      expect(jsonDecode(repo.requests.firstWhere((r) => r.pageSize == 20).searchFilter!),
          {'isActive': true, 'statusId': 1});
      while (c.canLoadMore) {
        await c.loadMore();
      }
      expect(c.vehicles.length, 51);
      expect(c.vehicles.last.id, 99); // unavailable last
      expect(c.vehicles.last.isAvailable, isFalse);
      expect(repo.requests.where((r) => r.pageSize != 20).length, 1); // just the count
    });

    test('a brand name from a tile becomes a server brand filter', () async {
      final c = build();
      await c.start(brandName: 'Nissan');
      expect(c.query.brandId, 2);
      expect(c.totalCount, 25);
      expect(jsonDecode(repo.requests.firstWhere((r) => r.pageSize == 1).searchFilter!), {'brandId': 2});
    });

    test('without the brand list (guest) the brand name is searched as text', () async {
      lookup.fail = true;
      final c = build();
      await c.start(brandName: 'Toyota');
      expect(c.query.brandId, isNull);
      expect(c.query.text, 'Toyota');
      expect(c.totalCount, 26); // 25 Toyotas + the inactive one
    });

    test('filters reload from page 1; typing is debounced', () async {
      final c = build();
      await c.start();
      await c.loadMore();
      c.setQuery(c.query.withVehicleType(5));
      await settle();
      expect(repo.requests.last.pageNumber, 1);
      expect(c.totalCount, 10);

      final before = repo.requests.length;
      c.setText('1');
      c.setText('10');
      await settle();
      expect(repo.requests.length, before); // still waiting for the pause
      await Future<void>.delayed(const Duration(milliseconds: 400));
      expect(repo.requests.length, before + 2); // count + first page
      expect(repo.requests.skip(before).every((r) => jsonDecode(r.searchFilter!)['name'] == '10'), isTrue);
      c.dispose();
    });

    test('a page for an old query never lands in the new results', () async {
      final c = build();
      await c.start();
      final pending = c.loadMore(); // page 2, all brands
      c.setQuery(c.query.withBrand(1));
      await pending;
      await settle();
      expect(c.vehicles.every((v) => v.brandId == 1), isTrue);
      expect(c.vehicles.length, 20);
      expect(c.totalCount, 26);
    });
  });

  group('Available first', () {
    List<int> ids(VehicleCatalog c) => c.vehicles.map((v) => v.id).toList();

    Future<void> loadAll(VehicleCatalog c) async {
      while (c.canLoadMore) {
        await c.loadMore();
      }
    }

    // Newest first on the server, statuses interleaved.
    final mixed = [
      for (var i = 30; i >= 1; i--)
        vehicle(i, active: i % 10 != 0, status: i % 7 == 0 ? 'rented' : 'available'),
    ];
    final available = [for (final v in mixed) if (v.isAvailable) v.id];
    final rented = [for (final v in mixed) if (v.isActive && !v.isAvailable) v.id];
    final off = [for (final v in mixed) if (!v.isActive) v.id];

    test('signed in: available, then other statuses, then switched off', () async {
      final repo = FakeVehicleRepository(mixed);
      final c = VehicleCatalog(repository: repo, options: VehicleFilterOptions(FakeLookupRepository()), ratings: NoRatings());
      await c.start();
      expect(ids(c), available.take(20).toList());
      await loadAll(c);
      expect(ids(c), [...available, ...rented, ...off]);
      expect(c.totalCount, 30);
      expect(c.vehicles.where((v) => v.isAvailable).length, available.length);
    });

    test('guest (no status list): same order via a filtered fallback', () async {
      final repo = FakeVehicleRepository(mixed);
      final lookup = FakeLookupRepository()..fail = true;
      final c = VehicleCatalog(repository: repo, options: VehicleFilterOptions(lookup), ratings: NoRatings());
      await c.start();
      await loadAll(c);
      expect(ids(c), [...available, ...off, ...rented]);
    });

    test('no extra queries when every match is already listed', () async {
      final repo = FakeVehicleRepository([for (var i = 25; i >= 1; i--) vehicle(i)]);
      final c = VehicleCatalog(repository: repo, options: VehicleFilterOptions(FakeLookupRepository()), ratings: NoRatings());
      await c.start();
      await loadAll(c);
      expect(c.vehicles.length, 25);
      expect(c.hasMore, isFalse);
      // count + 2 pages of available cars; the rented/off queries are skipped.
      expect(repo.requests.length, 3);
    });

    test('only unavailable matches: the first load moves on to them', () async {
      final repo = FakeVehicleRepository([vehicle(1, active: false), vehicle(2, status: 'rented')]);
      final c = VehicleCatalog(repository: repo, options: VehicleFilterOptions(FakeLookupRepository()), ratings: NoRatings());
      await c.start();
      expect(c.isLoading, isFalse);
      expect(ids(c), isNotEmpty);
      await loadAll(c);
      expect(ids(c), [2, 1]);
    });
  });

  group('FeaturedVehiclePicker', () {
    test('mixes companies and puts bookable, photographed cars first', () {
      final pool = [
        // One company's newest upload: no price (like prod's 75 ALFARIH cars).
        for (var i = 1; i <= 12; i++) vehicle(100 + i, companyId: 8, price: null),
        for (var i = 1; i <= 4; i++) vehicle(200 + i, companyId: 9),
        for (var i = 1; i <= 3; i++) vehicle(300 + i, companyId: 1),
        vehicle(400, companyId: 7, photo: false),
        vehicle(500, companyId: 9, active: false),
      ];
      final picked = FeaturedVehiclePicker.diversify(pool, count: 10, random: Random(1));
      expect(picked.length, 10);
      expect(picked.take(7).every((v) => v.isBookable && v.primaryPhoto != null), isTrue);
      // Round-robin: the first two picks come from different companies.
      expect(picked[0].companyId, isNot(picked[1].companyId));
      expect(picked.skip(7).every((v) => !v.hasPrice || v.primaryPhoto == null), isTrue);
      final all = FeaturedVehiclePicker.diversify(pool, count: 99, random: Random(1));
      expect(all.last.id, 500); // unavailable comes last
    });

    test('samples two random pages after a one-row count request', () async {
      final repo = FakeVehicleRepository([for (var i = 100; i >= 1; i--) vehicle(i, companyId: i % 4)]);
      final picker = FeaturedVehiclePicker(repo, random: Random(3));
      final first = await picker.pick();
      expect(first.length, 10);
      expect(repo.requests.first.pageSize, 1);
      expect(repo.requests.skip(1).map((r) => r.pageSize), [20, 20]);
      expect(repo.requests.every((r) => r.searchFilter == '{"isActive":true,"statusId":1}'), isTrue);

      repo.requests.clear();
      await picker.pick();
      expect(repo.requests.length, 2); // total is cached
    });
  });

  testWidgets('filter sheet: Clear all clears the filters and closes the sheet', (tester) async {
    final options = VehicleFilterOptions(FakeLookupRepository());
    await options.ensureLoaded();
    VehicleQuery? result;
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(390, 844),
      builder: (_, _) => MaterialApp(
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await showVehicleFilterSheet(
                context,
                query: const VehicleQuery(text: 'land').withBrand(1).withVehicleType(5),
                options: options,
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(FilterPill), findsWidgets);

    await tester.tap(find.text('clear_all'));
    await tester.pumpAndSettle();
    expect(find.byType(FilterPill), findsNothing); // sheet closed
    expect(result, const VehicleQuery(text: 'land'));
  });
}
