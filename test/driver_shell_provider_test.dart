import 'dart:async';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:slfdrive/src/core/data/repositories/booking_repository.dart';
import 'package:slfdrive/src/core/data/repositories/driver_repository.dart';
import 'package:slfdrive/src/core/errors/app_exception.dart';
import 'package:slfdrive/src/core/models/booking/booking.dart';
import 'package:slfdrive/src/core/models/common/paged_response.dart';
import 'package:slfdrive/src/core/models/common/pagination_params.dart';
import 'package:slfdrive/src/core/models/driver/driver_details.dart';
import 'package:slfdrive/src/core/models/driver/driver_stats.dart';
import 'package:slfdrive/src/core/services/customer_avatars.dart';
import 'package:slfdrive/src/core/services/driver_session.dart';
import 'package:slfdrive/src/core/services/place_namer.dart';
import 'package:slfdrive/src/presentation/screens/driver/shell/driver_shell_provider.dart';

class FakeBookingRepository implements BookingRepository {
  int paginatedCalls = 0;
  int approveCalls = 0;
  int completeCalls = 0;
  List<Booking> bookings = const [];
  bool failPaginated = false;
  Completer<void>? gate; // when set, driverPaginated waits on it

  @override
  Future<PagedResponse<Booking>> driverPaginated(int driverId, PaginationParams params) async {
    paginatedCalls++;
    if (gate != null) await gate!.future;
    if (failPaginated) throw AppException(message: 'server said no');
    return PagedResponse(
      items: bookings,
      totalCount: bookings.length,
      pageNumber: 1,
      pageSize: bookings.length,
      totalPages: 1,
    );
  }

  @override
  Future<bool> approve({required int id, required int confirmedBy}) async {
    approveCalls++;
    await Future<void>.delayed(const Duration(milliseconds: 10));
    return true;
  }

  @override
  Future<bool> complete(int id) async {
    completeCalls++;
    return true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

class FakeDriverRepository implements DriverRepository {
  DriverDetails? details;
  Completer<void>? getByIdGate;
  bool toggleResult = true;

  @override
  Future<DriverDetails?> getById(int id) async {
    if (getByIdGate != null) await getByIdGate!.future;
    return details;
  }

  @override
  Future<DriverStats?> getStats(int id) async => null;

  @override
  Future<bool> toggleOnline(int userId) async => toggleResult;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError('${invocation.memberName}');
}

class FakeStorage implements FlutterSecureStorage {
  final Map<String, String> data = {'user_id': '42'};
  final List<String> writtenKeys = [];

  @override
  Future<String?> read({
    required String key,
    dynamic iOptions,
    dynamic aOptions,
    dynamic lOptions,
    dynamic webOptions,
    dynamic mOptions,
    dynamic wOptions,
  }) async =>
      data[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    dynamic iOptions,
    dynamic aOptions,
    dynamic lOptions,
    dynamic webOptions,
    dynamic mOptions,
    dynamic wOptions,
  }) async {
    writtenKeys.add(key);
    if (value != null) data[key] = value;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class FakeDriverSession implements DriverSession {
  @override
  Future<int?> driverId() async => 7;

  @override
  void clear() {}

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakePlaceNamer implements PlaceNamer {
  @override
  Future<String> describe(double? lat, double? lon) async => 'Somewhere';

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

class FakeAvatars implements CustomerAvatars {
  @override
  Future<String?> photoUrl(int? userId) async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

Booking pending(int id) => Booking(id: id, statusId: 5, status: 'Pending');

DriverShellProvider makeShell(FakeBookingRepository repo, {FakeDriverRepository? drivers}) =>
    DriverShellProvider(
      repository: repo,
      drivers: drivers ?? FakeDriverRepository(),
      storage: FakeStorage(),
      session: FakeDriverSession(),
      placeNamer: FakePlaceNamer(),
      avatars: FakeAvatars(),
    );

void main() {
  test('concurrent ensureLoaded calls share one fetch', () async {
    final repo = FakeBookingRepository()..bookings = [pending(1)];
    final shell = makeShell(repo);
    await Future.wait([shell.ensureLoaded(), shell.ensureLoaded(), shell.ensureLoaded()]);
    expect(repo.paginatedCalls, 1);
    expect(shell.requests.length, 1);
    expect(shell.hasLoaded, isTrue);
  });

  test('ensureLoaded after a fresh load is a no-op', () async {
    final repo = FakeBookingRepository()..bookings = [pending(1)];
    final shell = makeShell(repo);
    await shell.ensureLoaded();
    await shell.ensureLoaded();
    expect(repo.paginatedCalls, 1);
  });

  test('a FAILED load also enters the cooldown — no refetch storm from build', () async {
    final repo = FakeBookingRepository()..failPaginated = true;
    final shell = makeShell(repo);
    await shell.ensureLoaded();
    expect(shell.error, 'server said no');
    // Rebuild-driven ensureLoaded calls must not hammer the backend.
    await shell.ensureLoaded();
    await shell.ensureLoaded();
    expect(repo.paginatedCalls, 1);
    // Explicit retry still works.
    repo.failPaginated = false;
    await shell.refresh();
    expect(repo.paginatedCalls, 2);
    expect(shell.error, isNull);
  });

  test('double-tap accept sends a single approve call', () async {
    final repo = FakeBookingRepository()..bookings = [pending(1)];
    final shell = makeShell(repo);
    await shell.ensureLoaded();
    final results = await Future.wait([shell.accept(1), shell.accept(1)]);
    expect(repo.approveCalls, 1);
    // The blocked duplicate reports failure without side effects.
    expect(results.where((ok) => ok).length, 1);
  });

  test('isBusy reflects an in-flight action', () async {
    final repo = FakeBookingRepository()..bookings = [pending(1)];
    final shell = makeShell(repo);
    await shell.ensureLoaded();
    final future = shell.accept(1);
    expect(shell.isBusy(1), isTrue);
    await future;
    expect(shell.isBusy(1), isFalse);
  });

  test('accept during an in-flight load chains a FRESH fetch (no stale snapshot)', () async {
    final repo = FakeBookingRepository()..bookings = [pending(1)];
    final shell = makeShell(repo);
    await shell.ensureLoaded();
    expect(shell.requests.length, 1);

    // A pull-to-refresh style load is in flight (gated), holding pre-action data.
    repo.gate = Completer<void>();
    final staleLoad = shell.refresh();
    // Driver accepts while that load is stuck; the backend now reports the
    // booking as approved.
    final acceptFuture = shell.accept(1);
    await Future<void>.delayed(const Duration(milliseconds: 30));
    repo.bookings = const []; // post-approval server state
    repo.gate!.complete();
    repo.gate = null;
    await staleLoad;
    await acceptFuture;

    // The post-action state must reflect the approval, not the stale load.
    expect(shell.requests, isEmpty);
    expect(repo.paginatedCalls, 3); // initial + stale + chained fresh
  });

  test('reset during an in-flight load discards its results', () async {
    final repo = FakeBookingRepository()
      ..bookings = [pending(1)]
      ..gate = Completer<void>();
    final shell = makeShell(repo);
    final load = shell.ensureLoaded();
    shell.reset(); // e.g. logout while loading
    repo.gate!.complete();
    repo.gate = null;
    await load;
    expect(shell.hasLoaded, isFalse);
    expect(shell.requests, isEmpty);
  });

  test('orphaned load finishing late cannot free a newer load\'s in-flight slot', () async {
    final repo = FakeBookingRepository()
      ..bookings = [pending(1)]
      ..gate = Completer<void>();
    final shell = makeShell(repo);
    final orphan = shell.ensureLoaded();
    shell.reset();

    // A new session starts loading while the orphan is still stuck.
    final gate2 = Completer<void>();
    final oldGate = repo.gate!;
    repo.gate = gate2;
    final fresh = shell.ensureLoaded();
    // Orphan completes late — must NOT clear the in-flight slot of `fresh`.
    oldGate.complete();
    await orphan;
    expect(shell.ensureLoaded(), same(fresh)); // still deduped onto fresh load
    gate2.complete();
    repo.gate = null;
    await fresh;
    expect(shell.hasLoaded, isTrue);
  });

  test('a concurrent load cannot stomp a freshly-toggled online state', () async {
    final drivers = FakeDriverRepository()
      ..details = const DriverDetails(id: 42, driverId: 7, isOnline: false)
      ..toggleResult = true;
    final repo = FakeBookingRepository();
    final shell = makeShell(repo, drivers: drivers);
    await shell.ensureLoaded();
    expect(shell.isOnline, isFalse);

    // A refresh is stuck on the (pre-toggle) driver read...
    drivers.getByIdGate = Completer<void>();
    final load = shell.refresh();
    // ...while the driver goes online.
    await shell.toggleOnline();
    expect(shell.isOnline, isTrue);
    // The stale read resolves with isOnline:false — must be ignored.
    drivers.getByIdGate!.complete();
    drivers.getByIdGate = null;
    await load;
    expect(shell.isOnline, isTrue);
  });
}
